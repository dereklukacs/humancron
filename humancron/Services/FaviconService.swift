import SwiftUI
import Combine

@MainActor
class FaviconService: ObservableObject {
    static let shared = FaviconService()
    
    @Published private(set) var favicons: [String: NSImage] = [:]
    private var loadingTasks: [String: Task<Void, Never>] = [:]
    private let cache = NSCache<NSString, NSImage>()
    
    private init() {
        cache.countLimit = 100
    }
    
    func favicon(for urlString: String) -> NSImage? {
        // Check memory cache first
        if let cached = favicons[urlString] {
            return cached
        }
        
        // Check NSCache
        if let cached = cache.object(forKey: urlString as NSString) {
            favicons[urlString] = cached
            return cached
        }
        
        // Start loading if not already in progress
        if loadingTasks[urlString] == nil {
            loadFavicon(for: urlString)
        }
        
        return nil
    }
    
    func prefetchFavicons(for workflows: [Workflow]) {
        for workflow in workflows {
            for step in workflow.steps {
                if let link = step.link {
                    _ = favicon(for: link)
                }
            }
        }
    }
    
    private func loadFavicon(for urlString: String) {
        let task = Task { @MainActor in
            guard let favicon = await fetchFavicon(for: urlString) else { return }
            
            // Store in both caches
            self.favicons[urlString] = favicon
            self.cache.setObject(favicon, forKey: urlString as NSString)
            self.loadingTasks[urlString] = nil
        }
        
        loadingTasks[urlString] = task
    }
    
    private func fetchFavicon(for urlString: String) async -> NSImage? {
        // Parse URL to get domain
        guard let url = URL(string: urlString),
              let host = url.host else { return nil }
        
        // Try multiple favicon URLs in order of preference
        let faviconURLs = [
            "https://\(host)/favicon.ico",
            "https://\(host)/favicon.png",
            "https://www.google.com/s2/favicons?domain=\(host)&sz=64"
        ]
        
        for faviconURLString in faviconURLs {
            if let faviconURL = URL(string: faviconURLString),
               let image = await downloadImage(from: faviconURL) {
                return image
            }
        }
        
        return nil
    }
    
    private func downloadImage(from url: URL) async -> NSImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = NSImage(data: data) else {
                return nil
            }
            
            // Resize to standard size
            return resizeImage(image, to: NSSize(width: 16, height: 16))
        } catch {
            return nil
        }
    }
    
    private func resizeImage(_ image: NSImage, to size: NSSize) -> NSImage {
        let resized = NSImage(size: size)
        resized.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: size))
        
        resized.unlockFocus()
        return resized
    }
}