//
//  User.swift
//  DocAppple
//
//  Created by 박찬휘 on 1/30/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String  // Firestore에서 userId를 문서 ID로 사용
    var nickname: String
    var email: String
    var profileImage: String?
    var birthDate: String?
    var avgReadingTime: Double
    var totalReadingTime: Double
    var ranking: Int
    var favoriteBooks: [String]

    // Firestore 데이터를 `User` 구조체로 변환하는 이니셜라이저
    init(id: String, data: [String: Any]) {
        self.id = id
        self.nickname = data["nickname"] as? String ?? "사용자"
        self.email = data["email"] as? String ?? "이메일 없음"
        self.profileImage = data["profileImage"] as? String
        self.birthDate = data["birthDate"] as? String
        self.avgReadingTime = data["avgReadingTime"] as? Double ?? 0.0
        self.totalReadingTime = data["totalReadingTime"] as? Double ?? 0.0
        self.ranking = data["ranking"] as? Int ?? 0
        self.favoriteBooks = data["favoriteBooks"] as? [String] ?? []
    }

    // Firestore에 저장할 데이터로 변환하는 함수
    func toDictionary() -> [String: Any] {
        return [
            "nickname": nickname,
            "email": email,
            "profileImage": profileImage ?? "",
            "birthDate": birthDate ?? "",
            "avgReadingTime": avgReadingTime,
            "totalReadingTime": totalReadingTime,
            "ranking": ranking,
            "favoriteBooks": favoriteBooks
        ]
    }
}
