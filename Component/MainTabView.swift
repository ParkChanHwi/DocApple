//
//  TabView.swift
//  DocApple
//
//  Created by 박찬휘 on 2/6/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView() // 홈에 서치버튼, 책이랑 아티클 검색 가능
                .tabItem{
                    Image(systemName: "house")
                    Text("홈") // 홈에 뜨는 정보들은 아티클, 책 홍보, 신간
                }
            CommunityView()
                .tabItem{
                    Image(systemName: "person.3")
                    Text("커뮤니티")
                }
            
            SearchView()
                .tabItem {
                    Image (systemName: "magnifyingglass.circle")
                    Text("검색")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("프로필")
                }
        }
    }
}

#Preview {
    MainTabView()
}
