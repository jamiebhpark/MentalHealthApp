import SwiftUI

struct EmotionRecordView: View {
    @State private var selectedEmotion: String = ""
    @State private var message: String = ""
    @State private var selectedColor: Color = .gray
    @State private var isSaved: Bool = false
    @State private var isShared: Bool = false
    let firestoreManager = FirestoreManager()
    
    let colors: [Color] = [.yellow, .blue, .red, .green, .purple, .orange]
    let columns = [
        GridItem(.flexible()), // 그리드의 각 열이 유연한 크기로 배치됨
        GridItem(.flexible()),
        GridItem(.flexible())  // 3열로 설정
    ]
    
    var body: some View {
        VStack {
            Text("오늘의 감정을 선택하세요")
                .font(.title)
                .padding()

            // 색상 팔레트 (그리드 형식)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 4)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()

            // 감정 메모 입력
            TextField("오늘의 감정을 기록하세요", text: $selectedEmotion)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("공유 메시지 (선택 사항)", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 개인 감정 기록 버튼
            Button(action: {
                firestoreManager.saveEmotionRecord(emotion: selectedEmotion, color: selectedColor) { success in
                    isSaved = success
                    if isSaved { print("Emotion saved in 'emotions' collection") }
                }
            }) {
                Text("개인 감정 기록 저장")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            // 커뮤니티 공유 버튼
            Button(action: {
                firestoreManager.createPost(emotion: selectedEmotion, message: message, color: selectedColor)
                isShared = true
            }) {
                Text("커뮤니티에 공유")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            if isSaved {
                Text("감정이 성공적으로 기록되었습니다.")
                    .foregroundColor(.green)
                    .padding(.top, 20)
            }
            
            if isShared {
                Text("커뮤니티에 공유되었습니다.")
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
}

struct EmotionRecordView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionRecordView()
    }
}
