import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLoginSheet = false
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        if authViewModel.isLoggedIn {MyPageView() }
        
        else {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 16)
                
                Text("회원 서비스 이용을 위해\n로그인 해주세요.")
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 54)
                
                VStack(spacing: 10) {
                    TextField("아이디를 입력해 주세요", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    SecureField("비밀번호를 입력해 주세요", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    showLoginSheet.toggle()
                }) {
                    Text("로그인")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.colorRedMain)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                HStack {
                    Button(action: {
                        authViewModel.loginWithGoogle()
                    }) {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Button(action: {
                        authViewModel.loginWithGitHub()
                    }) {
                        Image("github-mark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.top, 10)
                Text("아직 회원이 아니신가요?")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 55.35)
                
                Button(action: {
                                       showLoginSheet.toggle()
                                   }) {
                                       Text("회원가입")
                                           .foregroundColor(.black)
                                           .padding()
                                           .frame(maxWidth: .infinity)
                                           .background(Color(.systemGray5))
                                           .cornerRadius(10)
                                           .padding(.top, 8)
                                   }
                                   .padding(.horizontal)
                
            }
            
        }// else
        
        
        
        
        
    } // body
    
    
    
    
    
    
    
} // profileView
