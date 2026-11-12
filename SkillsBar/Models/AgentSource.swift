import Foundation

enum AgentSource: Hashable {
    case user
    case plugin
    case project(ProjectSkillRoot)

    var sectionTitle: String {
        switch self {
        case .user: return "用户助手"
        case .plugin: return "插件助手"
        case .project(let root): return "\(root.name) Project Agents"
        }
    }

    var groupTitle: String {
        "助手"
    }

    var iconName: String {
        "ClaudeLogo"
    }

    var badgeColor: String {
        "cyan"
    }

    var projectName: String? {
        switch self {
        case .project(let root):
            return root.name
        case .user, .plugin:
            return nil
        }
    }

    var projectRootPath: String? {
        switch self {
        case .project(let root):
            return root.path
        case .user, .plugin:
            return nil
        }
    }

    var isProjectAgent: Bool {
        projectRootPath != nil
    }
}
