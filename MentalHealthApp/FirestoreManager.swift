import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class FirestoreManager {
    let db = Firestore.firestore()
    
    // 개인 감정 기록 저장 함수 - 사용자 개인 컬렉션에 저장
    func saveEmotionRecord(emotion: String, color: Color, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(false)
            return
        }
        
        let colorString = getColorString(color: color)
        let emotionData: [String: Any] = [
            "emotion": emotion,
            "color": colorString,
            "timestamp": Timestamp()
        ]
        
        db.collection("users").document(uid).collection("emotions").addDocument(data: emotionData) { error in
            if let error = error {
                print("Error saving emotion: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Emotion successfully saved in 'emotions' collection!")
                completion(true)
            }
        }
    }
    
    // 개인 감정 기록 불러오기 함수
    func fetchEmotionRecords(completion: @escaping ([EmotionRecord]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion([])
            return
        }
        
        db.collection("users").document(uid).collection("emotions").order(by: "timestamp", descending: true).limit(to: 7).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching emotions: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var records: [EmotionRecord] = []
            for document in snapshot!.documents {
                let data = document.data()
                let emotion = data["emotion"] as? String ?? "Unknown"
                let colorString = data["color"] as? String ?? "gray"
                let color = self.getColorFromString(colorString)
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                
                records.append(EmotionRecord(emotion: emotion, color: color, timestamp: timestamp))
            }
            
            completion(records)
        }
    }
    
    // 게시물 저장 함수 - 'posts' 컬렉션에 저장
    func createPost(emotion: String, message: String, color: Color) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        // 'posts' 컬렉션에 저장하도록 경로 설정
        let postData: [String: Any] = [
            "userID": userID,
            "emotion": emotion,
            "message": message,
            "color": getColorString(color: color),
            "timestamp": Timestamp(),
            "likes": 0,
            "comments": []
        ]
        
        // Firestore의 'posts' 컬렉션에 데이터를 저장
        db.collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error creating post: \(error.localizedDescription)")
            } else {
                print("Post successfully created in 'posts' collection!")
            }
        }
    }
    
    // 게시글 목록 불러오기 - 공개 커뮤니티 컬렉션에서
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var fetchedPosts: [Post] = []
            for document in snapshot!.documents {
                let data = document.data()
                let emotion = data["emotion"] as? String ?? "Unknown"
                let message = data["message"] as? String ?? ""
                let colorString = data["color"] as? String ?? "gray"
                let color = self.getColorFromString(colorString)
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let likes = data["likes"] as? Int ?? 0
                let comments = data["comments"] as? [String] ?? []
                
                fetchedPosts.append(Post(id: document.documentID, emotion: emotion, message: message, color: color, timestamp: timestamp, likes: likes, comments: comments))
            }
            
            print("Fetched \(fetchedPosts.count) posts from Firestore.")
            completion(fetchedPosts)
        }
    }
    
    // 공감 추가 함수
    func addLikeToPost(postID: String) {
        let postRef = db.collection("posts").document(postID)
        postRef.updateData(["likes": FieldValue.increment(Int64(1))]) { error in
            if let error = error {
                print("Error updating likes: \(error.localizedDescription)")
            }
        }
    }
    
    // 댓글 추가 함수
    func addCommentToPost(postID: String, comment: String) {
        let postRef = db.collection("posts").document(postID)
        postRef.updateData(["comments": FieldValue.arrayUnion([comment])]) { error in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }
    // 주간 감정 기록 불러오기
    func fetchWeeklyEmotionRecords(completion: @escaping ([EmotionRecord]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion([])
            return
        }
        
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        db.collection("users").document(uid).collection("emotions")
            .whereField("timestamp", isGreaterThanOrEqualTo: oneWeekAgo)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching weekly emotions: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var records: [EmotionRecord] = []
                for document in snapshot!.documents {
                    let data = document.data()
                    let emotion = data["emotion"] as? String ?? "Unknown"
                    let colorString = data["color"] as? String ?? "gray"
                    let color = self.getColorFromString(colorString)  // 색상 변환 함수 재사용
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    
                    records.append(EmotionRecord(emotion: emotion, color: color, timestamp: timestamp))
                }
                
                completion(records)
            }
    }

    // 사용자 경험치 업데이트
    func updateUserXP(amount: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let currentXP = document.data()?["xp"] as? Int ?? 0
                let newXP = currentXP + amount
                userRef.updateData(["xp": newXP])
            } else {
                userRef.setData(["xp": amount])
            }
        }
    }
    
    // 사용자 경험치 불러오기
    func fetchUserXP(completion: @escaping (Int) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(0)
            return
        }
        
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let xp = document.data()?["xp"] as? Int ?? 0
                completion(xp)
            } else {
                print("User document does not exist or error occurred: \(error?.localizedDescription ?? "Unknown error")")
                completion(0)
            }
        }
    }
    
    // 사용자 배지 목록 불러오기
    func fetchUserBadges(completion: @escaping ([String]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let badges = document.data()?["badges"] as? [String] ?? []
                completion(badges)
            } else {
                completion([])
            }
        }
    }
    
    // 배지 획득 함수
    func awardBadgeToUser(badgeName: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userID)
        userRef.updateData(["badges": FieldValue.arrayUnion([badgeName])]) { error in
            if let error = error {
                print("Error awarding badge: \(error.localizedDescription)")
            } else {
                print("Badge awarded: \(badgeName)")
            }
        }
    }

    // 색상을 문자열로 변환하는 함수
    func getColorString(color: Color) -> String {
        switch color {
        case Color.yellow: return "yellow"
        case Color.blue: return "blue"
        case Color.red: return "red"
        case Color.green: return "green"
        case Color.purple: return "purple"
        case Color.orange: return "orange"
        default: return "gray"
        }
    }
    
    // 문자열을 색상으로 변환하는 함수
    func getColorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "yellow": return Color.yellow
        case "blue": return Color.blue
        case "red": return Color.red
        case "green": return Color.green
        case "purple": return Color.purple
        case "orange": return Color.orange
        default: return Color.gray
        }
    }
}

// 감정 기록 구조체
struct EmotionRecord {
    let emotion: String
    let color: Color
    let timestamp: Date
}


// Post 모델 구조체
struct Post: Identifiable {
    var id: String
    var emotion: String
    var message: String
    var color: Color
    var timestamp: Date
    var likes: Int
    var comments: [String]
}
