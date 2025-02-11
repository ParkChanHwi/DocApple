//
//  MyPageView.swift
//  DocApple
//
//  Created by 박찬휘 on 2/11/25.
//

import SwiftUI

struct MyPageView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditNickname = false
       @State private var newNickname = ""
    var body: some View {
        VStack {
            HStack {
                        TabButton(title: "마이페이지",index:0, selectedTab: $selectedTab)
                            TabButton(title: "책꽂이", index: 1, selectedTab: $selectedTab)
                            TabButton(title: "캘린더", index: 2, selectedTab: $selectedTab)
                        }
                .padding(.top, 10)
                Divider()
            
            if selectedTab == 0 {
                ShowMypage(showEditNickname: $showEditNickname, newNickname: $newNickname)
            } else if selectedTab == 1{
                BookshelfView()
            }else {
                CalendarView()
            }
        }
        .sheet(isPresented: $showEditNickname) {
            EditNicknameView(newNickname: $newNickname)
        }
    }
}

struct ShowMypage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showEditNickname: Bool
    @Binding var newNickname: String
    var body: some View {
        VStack(spacing: 20) {
            // 프로필 섹션
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)

                VStack(alignment: .leading) {
                    HStack {
                        Text(authViewModel.userNickname ?? "사용자 닉네임")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Gold")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .bold()
                    }

                    Button(action: {
                        showEditNickname.toggle()
                    }) {
                        Text("수정")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)

            // 🔹 추천 도서 리스트
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(authViewModel.userNickname ?? "사용자 닉네임")의 추천 도서!")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 150)

                    VStack {
                        Text("알라딘 API 사용해서")
                        Text("책 사진 띄우기")
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            // 🔹 로그아웃 버튼 추가
            Button(action: {
                authViewModel.logout()
            }) {
                Text("로그아웃")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct EditNicknameView: View {
    @Binding var newNickname: String
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
                    Text("닉네임 변경")
                        .font(.title)
                        .bold()
                        .padding()

                    TextField("새 닉네임 입력", text: $newNickname)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Button(action: {
                        authViewModel.updateNickname(newNickname: newNickname) 
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("저장")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding()
            }
}




struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: {
            selectedTab = index
        }) {
            VStack {
                Text(title)
                    .foregroundColor(selectedTab == index ? .black : .gray)
                    .font(.headline)

                if selectedTab == index {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct BookshelfView: View {
    var body: some View {
        VStack {
            Text("책꽂이")
                .font(.largeTitle)
            Spacer()
        }
    }
}


struct CalendarView: View {
    var body: some View {
        VStack {
            Text("캘린더")
                .font(.largeTitle)
            Spacer()
        }
    }
}



#Preview {
    MyPageView()
}
