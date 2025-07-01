import SwiftUI
import DesignSystem

struct SimpleContentView: View {
    @State private var isVisible = false
    
    var body: some View {
        VStack {
            Text("HumanCron")
                .font(.largeTitle)
                .padding()
            
            Text("Press Cmd+Shift+H to toggle")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Toggle Visibility") {
                isVisible.toggle()
            }
            .padding()
            
            if isVisible {
                VStack {
                    Text("Workflows would appear here")
                    Text("Current state: Visible")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            Spacer()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .padding()
        }
        .frame(width: 400, height: 300)
        .background(Color.white)
        .onAppear {
            print("App started successfully!")
            print("Window should be visible now")
            
            // Make sure window is visible
            if let window = NSApplication.shared.windows.first {
                window.makeKeyAndOrderFront(nil)
                window.center()
                NSApp.activate(ignoringOtherApps: true)
            }
            
            // Setup basic hotkey monitoring
            NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
                // Check for Cmd+Shift+H (keyCode 4 is 'H')
                if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 4 {
                    print("Cmd+Shift+H detected!")
                    DispatchQueue.main.async {
                        isVisible.toggle()
                        
                        // Ensure window comes to front
                        if let window = NSApplication.shared.windows.first {
                            window.makeKeyAndOrderFront(nil)
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }
                }
            }
        }
    }
}