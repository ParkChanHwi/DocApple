import SwiftUI

struct LoginCardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showLoginSheet: Bool
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("로그인 또는 회원가입")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Button(action: {
                authViewModel.loginWithGoogle()
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text("Google 로그인")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Button(action: {
                authViewModel.loginWithGitHub()
            }) {
                HStack {
                    Image(systemName: "chevron.left.slash.chevron.right")
                    Text("GitHub 로그인")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Button(action: {
                showLoginSheet = false
            }) {
                Text("닫기")
                    .foregroundColor(.gray)
                    .padding()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: 350)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

#Preview {
    LoginCardView(showLoginSheet: .constant(true))
        .environmentObject(AuthViewModel())
}
