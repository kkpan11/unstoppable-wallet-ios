import Foundation
import GRDB

class RecentAddressStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Recreate RecentAddress") { db in
            if try db.tableExists(RecentAddress.databaseTableName) {
                try db.drop(table: RecentAddress.databaseTableName)
            }

            try db.create(table: RecentAddress.databaseTableName) { t in
                t.column(RecentAddress.Columns.blockchainUid.name, .text).primaryKey(onConflict: .replace)
                t.column(RecentAddress.Columns.address.name, .text).notNull()
            }
        }

        return migrator
    }
}

extension RecentAddressStorage {
    func save(address: String, blockchainUid: String) throws {
        try dbPool.write { db in
            try RecentAddress(blockchainUid: blockchainUid, address: address).insert(db)
        }
    }

    func address(blockchainUid: String) throws -> String? {
        try dbPool.read { db in
            try RecentAddress.filter(RecentAddress.Columns.blockchainUid == blockchainUid).fetchOne(db)?.address
        }
    }
}
