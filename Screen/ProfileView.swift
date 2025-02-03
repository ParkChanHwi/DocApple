import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLoginSheet = false
    
    var body: some View {
        VStack {
            if authViewModel.isLoggedIn {
                VStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)

                    Text(authViewModel.userNickname ?? "사용자 닉네임")
                        .font(.title)
                        .fontWeight(.bold)

                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("로그아웃")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            } else {
                VStack {
                    Text("로그인이 필요합니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)

                    Button(action: {
                        showLoginSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "figure.wave.circle.fill")
                            Text("로그인 또는 회원가입")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showLoginSheet) {
            LoginCardView(showLoginSheet: $showLoginSheet)
        }
    }
}
