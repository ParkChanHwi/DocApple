import SwiftUI
import FirebaseCore

@main
struct DocAppleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
