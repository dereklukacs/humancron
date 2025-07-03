import Foundation

enum YAMLParserError: Error {
    case invalidFormat
    case missingRequiredField(String)
    case invalidFieldType(field: String, expected: String)
}

class YAMLParser {
    static let shared = YAMLParser()
    
    private init() {}
    
    // Simple YAML parser for our specific schema
    func parseWorkflow(from yamlString: String) throws -> Workflow {
        let lines = yamlString.components(separatedBy: .newlines)
        var currentDict: [String: Any] = [:]
        var currentSteps: [[String: Any]] = []
        var currentStep: [String: Any]? = nil
        var currentAutomations: [[String: Any]]? = nil
        var currentAutomation: [String: Any]? = nil
        var inSteps = false
        var inAutomations = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            
            // Count indentation
            let indent = line.prefix(while: { $0 == " " }).count
            
            // Parse key-value pairs
            if let colonIndex = trimmed.firstIndex(of: ":") {
                let key = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let value = String(trimmed[trimmed.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                
                // Remove quotes if present
                let cleanValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                
                // Handle different indentation levels
                if indent == 0 {
                    // Top level
                    if key == "steps" {
                        inSteps = true
                        inAutomations = false
                    } else {
                        currentDict[key] = cleanValue.isEmpty ? nil : cleanValue
                        inSteps = false
                        inAutomations = false
                    }
                } else if indent == 2 && inSteps {
                    // Step level
                    if key == "-" || key == "- name" {
                        // New step
                        if let step = currentStep {
                            if let automations = currentAutomations, !automations.isEmpty {
                                currentStep?["automations"] = automations
                            }
                            currentSteps.append(step)
                        }
                        currentStep = [:]
                        currentAutomations = nil
                        inAutomations = false
                        
                        if key == "- name" {
                            currentStep?["name"] = cleanValue
                        }
                    } else if key == "automations" {
                        inAutomations = true
                        currentAutomations = []
                    } else {
                        currentStep?[key] = cleanValue.isEmpty ? nil : cleanValue
                    }
                } else if indent == 4 && inSteps {
                    // Step property or automation level
                    if inAutomations {
                        if key == "-" || key == "- type" {
                            // New automation
                            if let automation = currentAutomation {
                                currentAutomations?.append(automation)
                            }
                            currentAutomation = [:]
                            
                            if key == "- type" {
                                currentAutomation?["type"] = cleanValue
                            }
                        } else {
                            currentStep?[key] = cleanValue.isEmpty ? nil : cleanValue
                        }
                    } else {
                        currentStep?[key] = cleanValue.isEmpty ? nil : cleanValue
                    }
                } else if indent == 6 && inAutomations {
                    // Automation property
                    currentAutomation?[key] = cleanValue.isEmpty ? nil : cleanValue
                }
            }
        }
        
        // Add the last step
        if let step = currentStep {
            if let automations = currentAutomations, !automations.isEmpty {
                currentStep?["automations"] = automations
            } else if let automation = currentAutomation {
                currentStep?["automations"] = [automation]
            }
            currentSteps.append(step)
        }
        
        // Add steps to main dict
        if !currentSteps.isEmpty {
            currentDict["steps"] = currentSteps
        }
        
        guard let workflow = Workflow(from: currentDict) else {
            throw YAMLParserError.invalidFormat
        }
        
        return workflow
    }
    
    // Parse multiple workflows from a YAML string containing an array
    func parseWorkflows(from yamlString: String) throws -> [Workflow] {
        // For now, just parse single workflow
        // TODO: Implement multiple workflow parsing
        let workflow = try parseWorkflow(from: yamlString)
        return [workflow]
    }
    
    // Validate a workflow structure
    func validateWorkflow(_ workflow: Workflow) throws {
        // Check required fields
        if workflow.name.isEmpty {
            throw YAMLParserError.missingRequiredField("name")
        }
        
        if workflow.description.isEmpty {
            throw YAMLParserError.missingRequiredField("description")
        }
        
        if workflow.steps.isEmpty {
            throw YAMLParserError.missingRequiredField("steps")
        }
        
        // Validate each step
        for (index, step) in workflow.steps.enumerated() {
            if step.name.isEmpty {
                throw YAMLParserError.missingRequiredField("steps[\(index)].name")
            }
            
            if step.description.isEmpty {
                throw YAMLParserError.missingRequiredField("steps[\(index)].description")
            }
            
            // Validate link format if present
            if let link = step.link, !link.isEmpty {
                // Basic URL validation
                if !link.contains("://") && !link.hasPrefix("/") {
                    throw YAMLParserError.invalidFieldType(
                        field: "steps[\(index)].link",
                        expected: "valid URL or path"
                    )
                }
            }
        }
    }
    
    // Load and parse a workflow from a file
    func loadWorkflow(from fileURL: URL) throws -> Workflow {
        let yamlString = try String(contentsOf: fileURL, encoding: .utf8)
        var workflow = try parseWorkflow(from: yamlString)
        workflow.filePath = fileURL.path
        
        // Append the finish step to all workflows
        var modifiedSteps = workflow.steps
        modifiedSteps.append(WorkflowStep.createFinishStep())
        
        // Create a new workflow with the modified steps
        let modifiedWorkflow = Workflow(
            name: workflow.name,
            description: workflow.description,
            hotkey: workflow.hotkey,
            steps: modifiedSteps,
            filePath: workflow.filePath
        )
        
        try validateWorkflow(workflow) // Validate original workflow (without finish step)
        return modifiedWorkflow
    }
}

// MARK: - Sample YAML Generation

extension YAMLParser {
    // Generate sample YAML for testing/templates
    func generateSampleYAML() -> String {
        let sampleYAML = """
        name: "Daily Planning"
        description: "Review calendar and plan the day"
        hotkey: "cmd+1"
        steps:
          - name: "Check Calendar"
            description: "Review today's meetings and events"
            link: "notion-calendar://"
            duration: 180
            
          - name: "Review Tasks"
            description: "Check Linear for today's priorities"
            link: "https://linear.app/team/inbox"
            automations:
              - type: "n8n"
                webhook: "https://n8n.example.com/webhook/daily-tasks"
                
          - name: "Update Status"
            description: "Post daily plan to Slack"
            link: "slack://channel?team=T123&id=C456"
        """
        
        return sampleYAML
    }
    
    func generateWorkflowTemplate() -> String {
        let template = """
        # Workflow Template
        # Replace the values below with your workflow details
        
        name: "Workflow Name"
        description: "Brief description of what this workflow does"
        hotkey: "cmd+1"  # Optional: keyboard shortcut for this specific workflow
        steps:
          - name: "Step 1"
            description: "What to do in this step"
            link: "app://path"  # Optional: URL or app scheme to open
            duration: 300  # Optional: expected duration in seconds
            
          - name: "Step 2"
            description: "Next action to take"
            link: "https://example.com"
            automations:  # Optional: automations to trigger
              - type: "n8n"
                webhook: "https://your-n8n-instance.com/webhook/xyz"
                parameters:
                  key: "value"
        """
        
        return template
    }
}