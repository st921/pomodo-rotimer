//
//  ContentView.swift
//  pomodo-rotimer
//
//  Created by しょう on 2026/02/23.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    @State private var timeRemaining: CGFloat = 25 * 60
    @State private var isActive = false
    let totalTime: CGFloat = 25 * 60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //カラーテーマ（落ち着いたカフェ風）
    let bgColor = Color(red: 0.95, green: 0.93, blue: 0.90)
    let accentColor = Color(red: 0.4, green: 0.3, blue: 0.25) //コーヒーブラウン
    
    var body: some View {
        ZStack {
            //背景色
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 50) {
                //イトル
                Text(isActive ? "FOCUS TIME" : "READY?")
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .tracking(8) //文字間隔を広げておしゃれに
                    .foregroundColor(accentColor)
                
                //メインのタイマー部分
                ZStack {
                    //外側の影（立体感）
                    Circle()
                        .fill(bgColor)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.white, radius: 10, x: -5, y: -5)
                    
                    //進捗リング（細めのラインで洗練された印象に）
                    Circle()
                        .trim(from: 0, to: timeRemaining / totalTime)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [accentColor.opacity(0.6), accentColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .padding(15) //少し内側に配置
                        .animation(.linear(duration: 1), value: timeRemaining)
                    
                    //中央の時間表示
                    VStack {
                        Text(formatTime(Int(timeRemaining)))
                            .font(.system(size: 54, weight: .thin, design: .monospaced))
                            .foregroundColor(accentColor)
                    }
                }
                .frame(width: 300, height: 300)
                
                //操作ボタン
                HStack(spacing: 40) {
                    //再生/一時停止
                    Button(action: { isActive.toggle() }) {
                        Circle()
                            .fill(bgColor)
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                            .overlay(
                                Image(systemName: isActive ? "pause" : "play.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 24))
                            )
                    }
                    
                    //セット
                    Button(action: resetTimer) {
                        Circle()
                            .fill(bgColor)
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                            .overlay(
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(accentColor.opacity(0.6))
                                    .font(.system(size: 20))
                            )
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if isActive && timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    func resetTimer() {
        isActive = false
        timeRemaining = totalTime
    }
}
#Preview {
    ContentView()
}
