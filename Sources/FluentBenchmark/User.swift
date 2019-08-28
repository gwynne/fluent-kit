import FluentKit

final class User: Model {
    struct Pet: Codable {
        enum Animal: String, Codable {
            case cat, dog
        }
        var name: String
        var type: Animal
    }
    static let schema = "users"
    
    @ID(key: "id")
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "pet")
    var pet: Pet

    @Parent(key: "agency_id")
    var agency: Agency?

    init() { }

    init(id: Int? = nil, name: String, pet: Pet, agency: Agency?) {
        self.id = id
        self.name = name
        self.pet = pet
        self.$agency.id = agency?.id
    }
}

struct UserMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("pet", .json, .required)
            .field("agency_id", .int)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}


final class UserSeed: Migration {
    init() { }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let tanner = User(name: "Tanner", pet: .init(name: "Ziz", type: .cat), agency: .qutheory)
        let logan = User(name: "Logan", pet: .init(name: "Runa", type: .dog), agency: nil)
        return logan.save(on: database)
            .and(tanner.save(on: database))
            .map { _ in }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededFuture(())
    }
}
