import MySQLKit
import Foundation

let dbPassword = ProcessInfo.processInfo.environment["DB_PASSWORD"] ?? ""

class DatabaseManager {
    static let shared = DatabaseManager()
    var pool: EventLoopGroupConnectionPool<MySQLConnectionSource>?

    // 데이터베이스 설정
    func setupDatabase() {
        let configuration = MySQLConfiguration(
            hostname: "127.0.0.1",        // 로컬 데이터베이스
            port: 3306,                  // MySQL 기본 포트
            username: "root",            // 사용자 이름
            password: dbPassword,        // 비밀번호
            database: "docApple"         // 스키마 이름
        )

        let connectionSource = MySQLConnectionSource(configuration: configuration)
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        self.pool = EventLoopGroupConnectionPool(
            source: connectionSource,
            on: eventLoopGroup
        )
        print("Database setup complete.")
    }

    // 도서 데이터 삽입 (비동기 방식)
    func insertBook(_ book: Book) {
        guard let pool = pool else {
            print("Database connection pool is not configured.")
            return
        }

        // 비동기 작업을 Task로 실행
        Task {
            do {
                try await pool.withConnection { conn in
                    let query = """
                    INSERT INTO books (title, author, publisher, pubDate, isbn, cover)
                    VALUES (?, ?, ?, ?, ?, ?)
                    """

                    // 쿼리 실행
                    try await conn.query(query, [
                        .init(string: book.title),
                        .init(string: book.author),
                        .init(string: book.publisher),
                        .init(string: book.pubDate),
                        .init(string: book.isbn),
                        .init(string: book.cover)
                    ])
                    print("Book inserted: \(book.title)")
                }
            } catch {
                print("Failed to insert book: \(error.localizedDescription)")
            }
        }
    }

    // 데이터베이스 연결 종료
    func shutdown() {
        Task {
            do {
                try await pool?.shutdown()
                print("Database connection pool shut down successfully.")
            } catch {
                print("Failed to shut down database connection pool: \(error.localizedDescription)")
            }
        }
    }
}
