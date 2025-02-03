import Foundation
import FirebaseFirestore



// MARK: - APIManager 클래스
class APIManager: NSObject, XMLParserDelegate {
    static let shared = APIManager()
    private let apiKey = "ttbxowkdcks0942001"
    private let firestore = Firestore.firestore()
    
    // XML 파싱을 위한 변수들
    private var books: [Book] = []
    private var currentElement = ""
    private var currentBook: [String: String] = [:]
    private var foundCharacters: String = ""
    private var completionHandler: (([Book]?) -> Void)?
    
    // Aladin API로 도서 데이터 가져오기
    func fetchBooks(query: String, completion: @escaping ([Book]?) -> Void) {
        self.completionHandler = completion
        let urlString = """
        https://www.aladin.co.kr/ttb/api/ItemSearch.aspx?ttbkey=\(apiKey)&Query=\(query)&QueryType=Title&MaxResults=10&Output=xml&Version=20131101
        """
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            // 응답 데이터 출력 (디버깅용)
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }

            // XML 파서 초기화 및 파싱 시작
            let parser = XMLParser(data: data)
            parser.delegate = self
            if !parser.parse() {
                print("Failed to parse XML")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    // Firestore에 도서 데이터 저장
    private func saveBooksToFirestore(_ books: [Book]) {
        for book in books {
            // documentID를 설정할 때 isbn13이 존재하고 비어 있지 않으면 사용, 아니면 isbn을 사용
            // 둘 다 비어 있으면 Firestore에서 자동으로 생성
            let isbn13 = book.isbn13.trimmingCharacters(in: .whitespacesAndNewlines)
            let isbn = book.isbn.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // documentID가 유효한지 확인
            var documentID: String? = nil
            if !isbn13.isEmpty {
                documentID = isbn13
            } else if !isbn.isEmpty {
                documentID = isbn
            }
            
            if let docID = documentID, !docID.isEmpty {
                print("Saving book with document ID: \(docID)")
                firestore.collection("books").document(docID).setData([
                    "title": book.title,
                    "author": book.author,
                    "publisher": book.publisher,
                    "pubDate": book.pubDate,
                    "isbn": book.isbn,
                    "isbn13": book.isbn13,
                    "cover": book.cover,
                    "priceSales": book.priceSales,
                    "priceStandard": book.priceStandard,
                    "description": book.description,
                    "category": book.category,
                    "customerReviewRank": book.customerReviewRank
                ], merge: true) { error in
                    if let error = error {
                        print("Error saving book to Firestore: \(error.localizedDescription)")
                    } else {
                        print("Book saved to Firestore: \(book.title)")
                    }
                }
            } else {
                print("Saving book with auto-generated document ID: \(book.title)")
                firestore.collection("books").addDocument(data: [
                    "title": book.title,
                    "author": book.author,
                    "publisher": book.publisher,
                    "pubDate": book.pubDate,
                    "isbn": book.isbn,
                    "isbn13": book.isbn13,
                    "cover": book.cover,
                    "priceSales": book.priceSales,
                    "priceStandard": book.priceStandard,
                    "description": book.description,
                    "category": book.category,
                    "customerReviewRank": book.customerReviewRank
                ]) { error in
                    if let error = error {
                        print("Error saving book to Firestore with auto ID: \(error.localizedDescription)")
                    } else {
                        print("Book saved to Firestore with auto ID: \(book.title)")
                    }
                }
            }
        }
    }
    
    // MARK: - XMLParserDelegate 메서드들
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentBook = [:]
        }
        foundCharacters = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "item" {
            // `currentBook`를 `Book` 객체로 변환하기 전에 필터링 조건 적용
            let publisher = currentBook["publisher"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // "알라딘 이벤트"인 경우 제외
            if publisher == "알라딘 이벤트" {
                print("Excluded Aladin Event: \(currentBook["title"] ?? "Unknown Title")")
                return
            }
            
            // 필터링 조건에 부합하는 경우에만 Book 객체 생성 및 추가
            let title = currentBook["title"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Title"
            let author = currentBook["author"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Author"
            let publisherValue = publisher.isEmpty ? "Unknown Publisher" : publisher
            let pubDate = currentBook["pubDate"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Date"
            let isbn = currentBook["isbn"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let isbn13 = currentBook["isbn13"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let cover = currentBook["cover"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let priceSales = Int(currentBook["priceSales"] ?? "") ?? 0
            let priceStandard = Int(currentBook["priceStandard"] ?? "") ?? 0
            let description = currentBook["description"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No description"
            let category = currentBook["categoryName"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
            let customerReviewRank = Int(currentBook["customerReviewRank"] ?? "") ?? 0

            let book = Book(
                title: title,
                author: author,
                publisher: publisherValue,
                pubDate: pubDate,
                isbn: isbn,
                isbn13: isbn13,
                cover: cover,
                priceSales: priceSales,
                priceStandard: priceStandard,
                description: description,
                category: category,
                customerReviewRank: customerReviewRank
            )
            books.append(book)
        } else if currentElement != "error" { // 에러 요소는 무시
            currentBook[elementName] = foundCharacters
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            self.saveBooksToFirestore(self.books)
            self.completionHandler?(self.books)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parse Error: \(parseError.localizedDescription)")
        DispatchQueue.main.async {
            self.completionHandler?(nil)
        }
    }
}
