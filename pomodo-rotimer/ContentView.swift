//
//  ContentView.swift
//  pomodo-rotimer
//
//  Created by しょう on 2026/02/23.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    // タイマーの設定（秒単位）
    @State private var timeRemaining: CGFloat = 25 * 60
    let totalTime: CGFloat = 25 * 60
    
    // タイマーの動作状態
    @State private var isActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // 背景の薄い円
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                // 進捗を示す動く円
                Circle()
                    .trim(from: 0, to: timeRemaining / totalTime) // 残り時間比率
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [.orange, .red]), center: .center),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90)) // 12時の位置から開始させる
                    .animation(.easeInOut(duration: 1), value: timeRemaining)
                
                // 中央の時間表示
                Text(formatTime(Int(timeRemaining)))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
            }
            .frame(width: 280, height: 280)
            
            // 操作ボタン
            HStack(spacing: 30) {
                Button(action: { isActive.toggle() }) {
                    Image(systemName: isActive ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(isActive ? .orange : .green)
                }
                
                Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
            }
        }
        .onReceive(timer) { _ in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isActive = false
            }
        }
    }
    
    // 秒を「分:秒」の形式に変換
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func resetTimer() {
        isActive = false
        timeRemaining = totalTime
    }
}
#Preview {
    ContentView()
}
