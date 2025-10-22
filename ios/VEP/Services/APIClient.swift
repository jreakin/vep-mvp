import Foundation

/// API Client for communicating with the backend REST API
@MainActor
class APIClient: ObservableObject {
    static let shared = APIClient()
    
    @Published var isOnline = true
    private var authToken: String?
    private let baseURL: String
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(baseURL: String = "https://your-project.supabase.co") {
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Authentication
    
    /// Set the authentication token
    func setAuthToken(_ token: String) {
        self.authToken = token
        UserDefaults.standard.set(token, forKey: "auth_token")
    }
    
    /// Clear the authentication token
    func clearAuthToken() {
        self.authToken = nil
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }
    
    /// Load saved auth token
    func loadAuthToken() {
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            self.authToken = token
        }
    }
    
    // MARK: - Assignments
    
    /// Get all assignments for the authenticated user
    func getAssignments() async throws -> [Assignment] {
        let response: AssignmentsResponse = try await request(
            endpoint: "/assignments",
            method: "GET"
        )
        return response.assignments
    }
    
    /// Get a specific assignment with voters
    func getAssignment(id: UUID) async throws -> Assignment {
        return try await request(
            endpoint: "/assignments/\(id.uuidString)",
            method: "GET"
        )
    }
    
    /// Update assignment status
    func updateAssignmentStatus(id: UUID, status: AssignmentStatus) async throws -> Assignment {
        let body = ["status": status.rawValue]
        return try await request(
            endpoint: "/assignments/\(id.uuidString)",
            method: "PATCH",
            body: body
        )
    }
    
    // MARK: - Voters
    
    /// Get a specific voter
    func getVoter(id: UUID) async throws -> Voter {
        return try await request(
            endpoint: "/voters/\(id.uuidString)",
            method: "GET"
        )
    }
    
    /// Search voters with filters
    func searchVoters(zip: String? = nil, limit: Int = 50, offset: Int = 0) async throws -> [Voter] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        if let zip = zip {
            queryItems.append(URLQueryItem(name: "zip", value: zip))
        }
        
        let response: VotersResponse = try await request(
            endpoint: "/voters",
            method: "GET",
            queryItems: queryItems
        )
        return response.voters
    }
    
    // MARK: - Contact Logs
    
    /// Create a new contact log
    func createContactLog(_ log: ContactLog) async throws -> ContactLog {
        let body: [String: Any] = [
            "assignment_id": log.assignmentId.uuidString,
            "voter_id": log.voterId.uuidString,
            "contact_type": log.contactType.rawValue,
            "result": log.result as Any,
            "support_level": log.supportLevel as Any,
            "location": [
                "latitude": log.location.latitude,
                "longitude": log.location.longitude
            ]
        ]
        
        return try await request(
            endpoint: "/contact-logs",
            method: "POST",
            body: body
        )
    }
    
    /// Get contact logs with filters
    func getContactLogs(assignmentId: UUID? = nil, startDate: Date? = nil) async throws -> [ContactLog] {
        var queryItems: [URLQueryItem] = []
        if let assignmentId = assignmentId {
            queryItems.append(URLQueryItem(name: "assignment_id", value: assignmentId.uuidString))
        }
        if let startDate = startDate {
            let formatter = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "start_date", value: formatter.string(from: startDate)))
        }
        
        let response: ContactLogsResponse = try await request(
            endpoint: "/contact-logs",
            method: "GET",
            queryItems: queryItems
        )
        return response.logs
    }
    
    // MARK: - Generic Request Handler
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem]? = nil,
        body: [String: Any]? = nil
    ) async throws -> T {
        var urlComponents = URLComponents(string: baseURL + endpoint)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Update online status
        DispatchQueue.main.async {
            self.isOnline = true
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 400:
            throw APIError.badRequest(String(data: data, encoding: .utf8))
        case 422:
            throw APIError.unprocessableEntity(String(data: data, encoding: .utf8))
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unknownError(httpResponse.statusCode)
        }
    }
}

// MARK: - API Response Models

private struct AssignmentsResponse: Decodable {
    let assignments: [Assignment]
}

private struct VotersResponse: Decodable {
    let voters: [Voter]
    let total: Int?
    let limit: Int?
    let offset: Int?
}

private struct ContactLogsResponse: Decodable {
    let logs: [ContactLog]
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case badRequest(String?)
    case unprocessableEntity(String?)
    case serverError(Int)
    case unknownError(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - please log in again"
        case .forbidden:
            return "Forbidden - you don't have permission"
        case .notFound:
            return "Resource not found"
        case .badRequest(let message):
            return "Bad request: \(message ?? "unknown error")"
        case .unprocessableEntity(let message):
            return "Validation error: \(message ?? "unknown error")"
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknownError(let code):
            return "Unknown error (\(code))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
