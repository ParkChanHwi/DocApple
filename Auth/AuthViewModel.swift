import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User? = nil
    @Published var isLoggedIn: Bool = false
    @Published var userNickname: String?
    @Published var userEmail: String?

    init() {
        self.user = Auth.auth().currentUser
        self.isLoggedIn = self.user != nil
        self.fetchUserData()
    }

    /// 🔹 Firestore에서 사용자 닉네임 가져오기
    func fetchUserData() {
        guard let userId = self.user?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.userNickname = data["nickname"] as? String ?? "사용자"
                    self.userEmail = data["email"] as? String ?? "이메일 없음"
                }
            } else {
                print("Firestore에서 사용자 정보를 찾을 수 없음: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func updateNickname(newNickname: String) {
        guard let userId = self.user?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                userRef.updateData(["nickname": newNickname]) { error in
                    if let error = error {
                        print("닉네임 업데이트 실패: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.userNickname = newNickname
                        }
                        print("닉네임 업데이트 성공")
                    }
                }
            } else {
                userRef.setData(["nickname": newNickname]) { error in
                    if let error = error {
                        print("닉네임 생성 실패: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.userNickname = newNickname
                        }
                        print("닉네임 새로 생성 성공")
                    }
                }
            }
        }
    }
    

    /// 🔹 Google 로그인
    func loginWithGoogle() {
        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController }).first else {
            print("RootViewController를 찾을 수 없습니다.")
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

                guard let authUser = authResult?.user else { return }
                print("Google Sign-In Successful! UID: \(authUser.uid)")

                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.user = authUser
                }
                // 🔹 Firestore에 사용자 정보 저장
                self.saveUserToFirestore(user: authUser)
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
    
    
    
    private func saveUserToFirestore(user: FirebaseAuth.User) {
        let userRef = Firestore.firestore().collection("users").document(user.uid)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("사용자 데이터가 이미 Firestore에 존재합니다.")
                self.fetchUserData() // 기존 사용자 정보 불러오기
            } else {
                let newUser: [String: Any] = [
                    "nickname": "사용자", // 기본 닉네임 설정
                    "email": user.email ?? "이메일 없음",
                    "profileImage": user.photoURL?.absoluteString ?? ""
                ]

                userRef.setData(newUser) { error in
                    if let error = error {
                        print("Firestore에 사용자 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("Firestore에 사용자 정보 저장 완료")
                        self.fetchUserData()
                    }
                }
            }
        }
    }
 
    
    
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.isLoggedIn = false
                self.userNickname = nil
                self.userEmail = nil
            }
            print("로그아웃 성공!")
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
}
