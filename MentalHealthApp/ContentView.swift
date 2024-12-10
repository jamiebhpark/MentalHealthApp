import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var emotionRecords: [EmotionRecord] = []
    @State private var recommendedContent: String = ""
    @State private var isLoggedIn = false
    @State private var isLoading = true  // 로딩 상태 추가
    @State private var showEmotionRecordView = false  // 감정 기록 화면 표시 여부 상태

    let firestoreManager = FirestoreManager()
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    if isLoggedIn {
                        Text("Logged in as Anonymous User")
                        
                        // 감정 기록 화면으로 이동하는 버튼
                        Button(action: {
                            showEmotionRecordView = true
                        }) {
                            Text("오늘의 감정 기록")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 50)
                        .navigationDestination(isPresented: $showEmotionRecordView) {
                            EmotionRecordView()  // 감정 기록 화면
                        }
                        
                        // 감정 온도계 표시
                        Text("감정 온도계")
                            .font(.title)
                            .padding(.top, 50)
                        
                        if isLoading {
                            ProgressView("불러오는 중...")  // 로딩 중일 때
                                .padding()
                        } else if emotionRecords.isEmpty {
                            Text("최근 감정 기록이 없습니다.")  // 감정 기록이 없을 때
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {  // 스크롤 가능하게 수정
                                HStack {
                                    ForEach(emotionRecords, id: \.timestamp) { record in
                                        Circle()
                                            .fill(record.color)
                                            .frame(width: 50, height: 50)
                                            .padding()
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // 맞춤형 콘텐츠 추천
                        Text("추천 콘텐츠: \(recommendedContent)")
                            .font(.title2)
                            .padding(.top, 20)
                        
                    } else {
                        Text("Logging in...")
                    }
                    
                    Spacer()
                }
                .onAppear {
                    signInAnonymously { success in
                        if success {
                            isLoggedIn = true
                            loadEmotionRecords()  // 로그인 후 감정 기록 불러오기
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("홈")
            }
            
            CommunityView() // 커뮤니티 뷰
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("커뮤니티")
                }
            
            ProfileView() // 프로필 화면 뷰
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("프로필")
                }
        }
    }

    // 감정 기록 불러오기 함수
    func loadEmotionRecords() {
        isLoading = true
        firestoreManager.fetchEmotionRecords { records in
            emotionRecords = records
            recommendContentBasedOnEmotion(records: records)
            isLoading = false  // 로딩 완료
        }
    }

    // 간단한 조건 기반 추천 로직
    func recommendContentBasedOnEmotion(records: [EmotionRecord]) {
        guard let latestRecord = records.first else { return }
        
        switch latestRecord.emotion {
        case "행복":
            recommendedContent = "기분 좋은 음악 추천"
        case "슬픔":
            recommendedContent = "위로를 주는 명상 추천"
        case "화남":
            recommendedContent = "진정에 도움이 되는 호흡 운동"
        default:
            recommendedContent = "일상 회복을 위한 콘텐츠 추천"
        }
    }
}

func signInAnonymously(completion: @escaping (Bool) -> Void) {
    Auth.auth().signInAnonymously { authResult, error in
        if let error = error {
            print("Error signing in anonymously: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Signed in anonymously with user ID: \(authResult?.user.uid ?? "No UID")")
            completion(true)
        }
    }
}
