import SwiftUI

struct ProfileView: View {
    @State private var userXP: Int = 0
    @State private var userLevel: Int = 1
    @State private var userBadges: [String] = [] // 배지 목록 상태 추가
    let firestoreManager = FirestoreManager()

    var body: some View {
        VStack {
            Text("내 프로필")
                .font(.largeTitle)
                .padding()

            // 레벨 표시
            Text("레벨 \(userLevel)")
                .font(.title)
                .padding()

            // 경험치 표시
            Text("경험치: \(userXP)")
                .padding()

            // 배지 목록 표시
            Text("획득한 배지")
                .font(.headline)
                .padding(.top, 20)

            // 획득한 배지 목록을 ForEach로 표시
            ForEach(userBadges, id: \.self) { badge in
                Text(badge)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .padding(.bottom, 10)
            }

            Spacer()
        }
        .onAppear {
            firestoreManager.fetchUserXP { xp in
                userXP = xp
                userLevel = calculateLevel(from: xp)
            }

            firestoreManager.fetchUserBadges { badges in
                userBadges = badges // Firestore에서 배지 목록 불러오기
            }
        }
    }

    // 경험치에 따라 레벨 계산
    func calculateLevel(from xp: Int) -> Int {
        return xp / 100 // 경험치 100마다 레벨업
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
