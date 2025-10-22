import Foundation

/// Assignment model representing a canvassing assignment
struct Assignment: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let assignedDate: Date
    let dueDate: Date?
    let status: AssignmentStatus
    let voterCount: Int
    let completedCount: Int
    var voters: [Voter]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case assignedDate = "assigned_date"
        case dueDate = "due_date"
        case status
        case voterCount = "voter_count"
        case completedCount = "completed_count"
        case voters
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard voterCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(voterCount)
    }
    
    /// Whether the assignment is overdue
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && status != .completed
    }
}

/// Assignment status enumeration
enum AssignmentStatus: String, Codable {
    case pending
    case inProgress = "in_progress"
    case completed
    case cancelled
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}
