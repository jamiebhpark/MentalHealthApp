import SwiftUI

struct CreatePostView: View {
    @State private var emotion: String = ""
    @State private var message: String = ""
    @State private var selectedColor: Color = .gray
    let firestoreManager = FirestoreManager()

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("감정 공유하기")
                .font(.largeTitle)
                .padding()

            // 감정 입력 필드
            TextField("감정 입력", text: $emotion)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 감정 메시지 입력 필드
            TextField("감정에 대해 더 말해보세요", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 색상 선택 팔레트 (그리드 형식)
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 3)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()

            // 감정 기록 저장 버튼
            Button(action: {
                firestoreManager.saveEmotionRecord(emotion: emotion, color: selectedColor) { success in
                    if success {
                        print("Emotion successfully saved in 'emotions' collection!")
                    }
                }
            }) {
                Text("감정 기록 저장")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            // 커뮤니티에 공유 버튼
            Button(action: {
                firestoreManager.createPost(emotion: emotion, message: message, color: selectedColor)
            }) {
                Text("커뮤니티에 공유")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView()
    }
}
