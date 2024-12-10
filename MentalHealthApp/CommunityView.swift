import SwiftUI

struct CommunityView: View {
    @State private var posts: [Post] = []
    let firestoreManager = FirestoreManager()
    
    var body: some View {
        VStack {
            Text("익명 소셜 커뮤니티")
                .font(.largeTitle)
                .padding()
            
            if posts.isEmpty {
                Text("게시글이 없습니다.")
            } else {
                List(posts) { post in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(post.color)
                                .frame(width: 12, height: 12)
                            Text(post.emotion)
                                .font(.headline)
                                .padding(.leading, 4)
                        }
                        
                        Text(post.message)
                            .font(.body)
                            .padding(.vertical, 4)
                        
                        Text(post.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Button(action: {
                                firestoreManager.addLikeToPost(postID: post.id)
                            }) {
                                HStack {
                                    Image(systemName: "hand.thumbsup")
                                    Text("공감 \(post.likes)")
                                }
                                .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Spacer()
                            
                            Button(action: {
                                // 댓글 작성 화면으로 이동하는 로직을 추가할 수 있습니다.
                            }) {
                                HStack {
                                    Image(systemName: "bubble.left")
                                    Text("댓글 \(post.comments.count)")
                                }
                                .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.vertical, 5)
                }
            }

            Spacer()
            
            NavigationLink(destination: EmotionRecordView()) {
                Text("게시글 작성")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            firestoreManager.fetchPosts { fetchedPosts in
                posts = fetchedPosts
                print("CommunityView: Loaded \(posts.count) posts")
            }
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
