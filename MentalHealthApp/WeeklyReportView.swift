import SwiftUI

struct WeeklyReportView: View {
    @State private var weeklyRecords: [EmotionRecord] = []
    let firestoreManager = FirestoreManager()

    var body: some View {
        VStack {
            Text("주간 감정 리포트")
                .font(.largeTitle)
                .padding()

            HStack {
                ForEach(weeklyRecords, id: \.timestamp) { record in
                    VStack {
                        Text("\(record.timestamp, formatter: shortDateFormatter)")
                        Circle()
                            .fill(record.color)
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                }
            }
            .onAppear {
                firestoreManager.fetchWeeklyEmotionRecords { records in
                    weeklyRecords = records
                }
            }

            Spacer()
        }
        .padding()
    }
    
    // DateFormatter 인스턴스 생성
    var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short  // short 스타일 사용
        return formatter
    }
}

struct WeeklyReportView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyReportView()
    }
}
