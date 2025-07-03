import Foundation

// MARK: - Workflow Models

struct Workflow: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let hotkey: String?
    let steps: [WorkflowStep]
    var filePath: String?
    
    // Computed properties
    var totalDuration: TimeInterval? {
        let durations = steps.compactMap { $0.duration }
        guard !durations.isEmpty else { return nil }
        return durations.reduce(0, +)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case hotkey
        case steps
        case filePath
    }
    
    init(name: String, description: String, hotkey: String? = nil, 
         steps: [WorkflowStep], filePath: String? = nil) {
        self.name = name
        self.description = description
        self.hotkey = hotkey
        self.steps = steps
        self.filePath = filePath
    }
}

struct WorkflowStep: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let link: String?
    let command: String?
    let duration: TimeInterval?
    let automations: [WorkflowAutomation]?
    let isFinishStep: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case link
        case command
        case duration
        case automations
        case isFinishStep
    }
    
    init(name: String, description: String, link: String? = nil, command: String? = nil, 
         duration: TimeInterval? = nil, automations: [WorkflowAutomation]? = nil, 
         isFinishStep: Bool = false) {
        self.name = name
        self.description = description
        self.link = link
        self.command = command
        self.duration = duration
        self.automations = automations
        self.isFinishStep = isFinishStep
    }
    
    // Factory method to create the finish step
    static func createFinishStep() -> WorkflowStep {
        return WorkflowStep(
            name: "Finish Workflow",
            description: "All tasks completed",
            isFinishStep: true
        )
    }
}

struct WorkflowAutomation: Codable {
    let type: AutomationType
    let webhook: String?
    let parameters: [String: String]?
    
    enum AutomationType: String, Codable {
        case n8n
        case zapier
        case webhook
    }
}

// MARK: - YAML Compatible Models

extension Workflow {
    // Create from YAML-parsed dictionary
    init?(from yamlDict: [String: Any]) {
        guard let name = yamlDict["name"] as? String,
              let description = yamlDict["description"] as? String,
              let stepsArray = yamlDict["steps"] as? [[String: Any]] else {
            return nil
        }
        
        self.name = name
        self.description = description
        self.hotkey = yamlDict["hotkey"] as? String
        
        self.steps = stepsArray.compactMap { WorkflowStep(from: $0) }
    }
}

extension WorkflowStep {
    // Create from YAML-parsed dictionary
    init?(from dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let description = dict["description"] as? String else {
            return nil
        }
        
        self.name = name
        self.description = description
        self.link = dict["link"] as? String
        self.command = dict["command"] as? String
        self.isFinishStep = dict["isFinishStep"] as? Bool ?? false
        
        // Parse duration (in seconds from YAML)
        if let durationSeconds = dict["duration"] as? Double {
            self.duration = durationSeconds
        } else if let durationInt = dict["duration"] as? Int {
            self.duration = TimeInterval(durationInt)
        } else {
            self.duration = nil
        }
        
        // Parse automations
        if let automationsArray = dict["automations"] as? [[String: Any]] {
            self.automations = automationsArray.compactMap { WorkflowAutomation(from: $0) }
        } else {
            self.automations = nil
        }
    }
}

extension WorkflowAutomation {
    // Create from YAML-parsed dictionary
    init?(from dict: [String: Any]) {
        guard let typeString = dict["type"] as? String,
              let type = AutomationType(rawValue: typeString) else {
            return nil
        }
        
        self.type = type
        self.webhook = dict["webhook"] as? String
        self.parameters = dict["parameters"] as? [String: String]
    }
}

// MARK: - Sample Data

extension Workflow {
    static let sampleWorkflows = [
        Workflow(
            name: "Daily Planning",
            description: "Review calendar and plan the day",
            hotkey: "cmd+1",
            steps: [
                WorkflowStep(
                    name: "Check Calendar",
                    description: "Review today's meetings and events",
                    link: "notion-calendar://",
                    command: nil,
                    duration: 180,
                    automations: nil
                ),
                WorkflowStep(
                    name: "Review Tasks",
                    description: "Check Linear for today's priorities",
                    link: "https://linear.app/team/inbox",
                    command: nil,
                    duration: nil,
                    automations: [
                        WorkflowAutomation(
                            type: .n8n,
                            webhook: "https://n8n.example.com/webhook/daily-tasks",
                            parameters: nil
                        )
                    ]
                ),
                WorkflowStep(
                    name: "Update Status",
                    description: "Post daily plan to Slack",
                    link: "slack://channel?team=T123&id=C456",
                    command: nil,
                    duration: nil,
                    automations: nil
                )
            ]
        )
    ]
}