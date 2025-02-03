import SwiftUI
import FirebaseCore

@main
struct DocAppleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProfileView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
