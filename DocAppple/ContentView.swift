import SwiftUI

struct ContentView: View {
    @State private var query: String = ""
    @State private var books: [Book] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for books", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Search") {
                    searchBooks()
                }
                .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                List(books, id: \.isbn) { book in
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.author)
                            .font(.subheadline)
                        Text(book.publisher)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Book Search")
        }
    }

    func searchBooks() {
        APIManager.shared.fetchBooks(query: query) { result in
            if let result = result {
                books = result
                errorMessage = nil
            } else {
                errorMessage = "Failed to fetch books from API."
            }
        }
    }
}
