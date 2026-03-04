//
//  ContentView.swift
//  pomodo-rotimer
//
//  Created by しょう on 2026/02/23.
//

import SwiftUI
import PhotosUI // 写真選択用
internal import Combine

struct ContentView: View {
    @State private var timeRemaining: CGFloat = 25 * 60
    @State private var isActive = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var backgroundImage: Image? = nil
    
    let totalTime: CGFloat = 25 * 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // --- カスタマイズ背景 ---
            Group {
                if let backgroundImage = backgroundImage {
                    backgroundImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.black // デフォルトは漆黒
                }
            }
            .ignoresSafeArea()
            .overlay(Color.black.opacity(0.4)) // 画像を見やすくするために少し暗く
            .blur(radius: 10) // ぼかしを入れて文字を浮かせる
            
            VStack(spacing: 60) {
                // --- ヘッダー（近未来風テキスト） ---
                HStack {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("BG SET", systemImage: "photo.stack")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                    Spacer()
                    Text("SYSTEM ACTIVE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.cyan)
                        .opacity(isActive ? 1 : 0.3)
                }
                .padding(.horizontal, 30)

                // --- メインタイマー（ネオンリング） ---
                ZStack {
                    // 外側の発光（グローエフェクト）
                    Circle()
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 2)
                        .scaleEffect(1.1)
                    
                    //進捗リング
                    Circle()
                        .trim(from: 0, to: timeRemaining / totalTime)
                        .stroke(
                            LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: .cyan.opacity(0.8), radius: 10) // ネオンの光
                        .animation(.easeInOut(duration: 1), value: timeRemaining)
                    
                    //時間表示
                    Text(formatTime(Int(timeRemaining)))
                        .font(.system(size: 70, weight: .thin, design: .monospaced))
                        .foregroundColor(.white)
                        .italic()
                        .shadow(color: .cyan, radius: 5)
                }
                .frame(width: 280, height: 280)

                //--- 操作パネル ---
                HStack(spacing: 50) {
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 25))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Button(action: { isActive.toggle() }) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 90, height: 90)
                            .overlay(
                                Image(systemName: isActive ? "pause.fill" : "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.cyan)
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: 15)
                    }
                    
                    // 完了ボタン（10秒お試し用などのショートカットも可）
                    Button(action: {}) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        // 写真選択時の処理
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    backgroundImage = Image(uiImage: uiImage)
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
