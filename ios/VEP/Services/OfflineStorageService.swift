import Foundation
import CoreData

/// Offline storage service using Core Data for caching and offline support
@MainActor
class OfflineStorageService: ObservableObject {
    static let shared = OfflineStorageService()
    
    @Published var pendingLogsCount: Int = 0
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VEP")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init() {
        updatePendingLogsCount()
    }
    
    // MARK: - Assignment Caching
    
    /// Cache an assignment with its voters
    func cacheAssignment(_ assignment: Assignment) throws {
        let fetchRequest: NSFetchRequest<CDAssignment> = CDAssignment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", assignment.id as CVarArg)
        
        let cdAssignment: CDAssignment
        if let existing = try context.fetch(fetchRequest).first {
            cdAssignment = existing
        } else {
            cdAssignment = CDAssignment(context: context)
            cdAssignment.id = assignment.id
        }
        
        cdAssignment.name = assignment.name
        cdAssignment.assignmentDescription = assignment.description
        cdAssignment.assignedDate = assignment.assignedDate
        cdAssignment.dueDate = assignment.dueDate
        cdAssignment.status = assignment.status.rawValue
        cdAssignment.voterCount = Int32(assignment.voterCount)
        cdAssignment.completedCount = Int32(assignment.completedCount)
        
        // Cache voters if present
        if let voters = assignment.voters {
            for voter in voters {
                try cacheVoter(voter)
            }
        }
        
        try context.save()
    }
    
    /// Get cached assignment
    func getCachedAssignment(id: UUID) throws -> Assignment? {
        let fetchRequest: NSFetchRequest<CDAssignment> = CDAssignment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let cdAssignment = try context.fetch(fetchRequest).first else {
            return nil
        }
        
        return Assignment(
            id: cdAssignment.id ?? UUID(),
            name: cdAssignment.name ?? "",
            description: cdAssignment.assignmentDescription,
            assignedDate: cdAssignment.assignedDate ?? Date(),
            dueDate: cdAssignment.dueDate,
            status: AssignmentStatus(rawValue: cdAssignment.status ?? "pending") ?? .pending,
            voterCount: Int(cdAssignment.voterCount),
            completedCount: Int(cdAssignment.completedCount),
            voters: nil
        )
    }
    
    /// Get all cached assignments
    func getAllCachedAssignments() throws -> [Assignment] {
        let fetchRequest: NSFetchRequest<CDAssignment> = CDAssignment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "assignedDate", ascending: false)]
        
        let cdAssignments = try context.fetch(fetchRequest)
        
        return cdAssignments.compactMap { cdAssignment in
            Assignment(
                id: cdAssignment.id ?? UUID(),
                name: cdAssignment.name ?? "",
                description: cdAssignment.assignmentDescription,
                assignedDate: cdAssignment.assignedDate ?? Date(),
                dueDate: cdAssignment.dueDate,
                status: AssignmentStatus(rawValue: cdAssignment.status ?? "pending") ?? .pending,
                voterCount: Int(cdAssignment.voterCount),
                completedCount: Int(cdAssignment.completedCount),
                voters: nil
            )
        }
    }
    
    // MARK: - Voter Caching
    
    /// Cache a voter
    func cacheVoter(_ voter: Voter) throws {
        let fetchRequest: NSFetchRequest<CDVoter> = CDVoter.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", voter.id as CVarArg)
        
        let cdVoter: CDVoter
        if let existing = try context.fetch(fetchRequest).first {
            cdVoter = existing
        } else {
            cdVoter = CDVoter(context: context)
            cdVoter.id = voter.id
        }
        
        cdVoter.voterId = voter.voterId
        cdVoter.firstName = voter.firstName
        cdVoter.lastName = voter.lastName
        cdVoter.address = voter.address
        cdVoter.city = voter.city
        cdVoter.state = voter.state
        cdVoter.zip = voter.zip
        cdVoter.latitude = voter.location.latitude
        cdVoter.longitude = voter.location.longitude
        cdVoter.partyAffiliation = voter.partyAffiliation
        cdVoter.supportLevel = voter.supportLevel.map { Int16($0) } ?? 0
        cdVoter.phone = voter.phone
        cdVoter.email = voter.email
        
        try context.save()
    }
    
    /// Get cached voter
    func getCachedVoter(id: UUID) throws -> Voter? {
        let fetchRequest: NSFetchRequest<CDVoter> = CDVoter.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let cdVoter = try context.fetch(fetchRequest).first else {
            return nil
        }
        
        return Voter(
            id: cdVoter.id ?? UUID(),
            voterId: cdVoter.voterId ?? "",
            firstName: cdVoter.firstName ?? "",
            lastName: cdVoter.lastName ?? "",
            address: cdVoter.address ?? "",
            city: cdVoter.city ?? "",
            state: cdVoter.state ?? "TX",
            zip: cdVoter.zip ?? "",
            location: Coordinate(latitude: cdVoter.latitude, longitude: cdVoter.longitude),
            partyAffiliation: cdVoter.partyAffiliation,
            supportLevel: cdVoter.supportLevel != 0 ? Int(cdVoter.supportLevel) : nil,
            phone: cdVoter.phone,
            email: cdVoter.email
        )
    }
    
    // MARK: - Contact Log Queue
    
    /// Queue a contact log for syncing
    func queueContactLog(_ log: ContactLog) throws {
        let cdLog = CDContactLog(context: context)
        cdLog.id = log.id
        cdLog.assignmentId = log.assignmentId
        cdLog.voterId = log.voterId
        cdLog.contactType = log.contactType.rawValue
        cdLog.result = log.result
        cdLog.supportLevel = log.supportLevel.map { Int16($0) } ?? 0
        cdLog.latitude = log.location.latitude
        cdLog.longitude = log.location.longitude
        cdLog.contactedAt = log.contactedAt
        cdLog.synced = false
        
        try context.save()
        updatePendingLogsCount()
    }
    
    /// Get all pending (unsynced) contact logs
    func getPendingLogs() throws -> [ContactLog] {
        let fetchRequest: NSFetchRequest<CDContactLog> = CDContactLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "synced == NO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "contactedAt", ascending: true)]
        
        let cdLogs = try context.fetch(fetchRequest)
        
        return cdLogs.compactMap { cdLog in
            guard let id = cdLog.id,
                  let assignmentId = cdLog.assignmentId,
                  let voterId = cdLog.voterId,
                  let contactTypeStr = cdLog.contactType,
                  let contactType = ContactType(rawValue: contactTypeStr),
                  let contactedAt = cdLog.contactedAt else {
                return nil
            }
            
            return ContactLog(
                id: id,
                assignmentId: assignmentId,
                voterId: voterId,
                contactType: contactType,
                result: cdLog.result,
                supportLevel: cdLog.supportLevel != 0 ? Int(cdLog.supportLevel) : nil,
                location: Coordinate(latitude: cdLog.latitude, longitude: cdLog.longitude),
                contactedAt: contactedAt
            )
        }
    }
    
    /// Mark a contact log as synced
    func markLogAsSynced(id: UUID) throws {
        let fetchRequest: NSFetchRequest<CDContactLog> = CDContactLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let cdLog = try context.fetch(fetchRequest).first {
            cdLog.synced = true
            try context.save()
            updatePendingLogsCount()
        }
    }
    
    /// Clear all synced logs
    func clearSyncedLogs() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDContactLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "synced == YES")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
        updatePendingLogsCount()
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clearAllCache() throws {
        let entities = ["CDAssignment", "CDVoter", "CDContactLog", "CDUser"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        }
        
        try context.save()
        updatePendingLogsCount()
    }
    
    // MARK: - Private Helpers
    
    private func updatePendingLogsCount() {
        let fetchRequest: NSFetchRequest<CDContactLog> = CDContactLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "synced == NO")
        
        do {
            let count = try context.count(for: fetchRequest)
            DispatchQueue.main.async {
                self.pendingLogsCount = count
            }
        } catch {
            print("Failed to update pending logs count: \(error)")
        }
    }
}
