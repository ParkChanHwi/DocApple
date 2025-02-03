import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User? = nil
    @Published var isLoggedIn: Bool = false
    @Published var userNickname: String?

    init() {
        self.user = Auth.auth().currentUser
        self.isLoggedIn = self.user != nil
        self.fetchUserNickname()
    }

    /// 🔹 Firestore에서 사용자 닉네임 가져오기
    func fetchUserNickname() {
        guard let userId = self.user?.uid else { return }
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let nickname = data["nickname"] as? String {
                DispatchQueue.main.async {
                    self.userNickname = nickname
                }
            } else {
                print("닉네임을 불러오지 못함: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    /// 🔹 Google 로그인
    func loginWithGoogle() {
        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController }).first else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let result = signInResult else {
                print("Google Sign-In Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            guard let idToken = result.user.idToken?.tokenString else {
                print("Failed to get ID token from Google")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Authentication Error: \(error.localizedDescription)")
                    return
                }
                print("Google Sign-In Successful!")
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.user = authResult?.user
                }
            }
        }
    }

    /// 🔹 GitHub 로그인
    func loginWithGitHub() {
        let provider = OAuthProvider(providerID: "github.com")
        provider.getCredentialWith(nil) { credential, error in
            guard let credential = credential else {
                print("GitHub Login Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("GitHub Authentication Error: \(error.localizedDescription)")
                    return
                }
                print("GitHub Sign-In Successful!")
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.user = authResult?.user
                }
            }
        }
    }

    /// 🔹 로그아웃
    func logout() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.isLoggedIn = false
                self.userNickname = nil
            }
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
}
