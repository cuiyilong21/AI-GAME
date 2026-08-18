import SwiftUI
import SpriteKit

@main
struct ShanghaiActionApp: App {
    var body: some Scene {
        WindowGroup {
            GameHostView()
        }
    }
}

private struct GameHostView: View {
    @State private var scene: GameScene?
    @State private var loadProgress = 0.02
    @State private var loadStatus = "正在启动上海行动"
    @State private var showingLoader = true
    @State private var loadingStarted = false

    var body: some View {
        ZStack {
            Color(red: 0.015, green: 0.03, blue: 0.045)
                .ignoresSafeArea()

            if let scene {
                SpriteView(scene: scene, options: [.ignoresSiblingOrder, .shouldCullNonVisibleNodes])
                    .ignoresSafeArea()
            }

            if showingLoader {
                ZStack {
                    LinearGradient(colors: [Color(red: 0.01, green: 0.03, blue: 0.05), Color(red: 0.03, green: 0.12, blue: 0.15)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    VStack(spacing: 18) {
                        Text("上海行动")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("SHANGHAI ACTION")
                            .font(.caption.weight(.bold))
                            .tracking(4)
                            .foregroundStyle(.cyan)
                        VStack(spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.14))
                                    Capsule()
                                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: max(8, geometry.size.width * loadProgress))
                                        .shadow(color: .cyan.opacity(0.8), radius: 7)
                                }
                            }
                            .frame(height: 12)
                            HStack {
                                Text(loadStatus)
                                Spacer()
                                Text("\(Int(loadProgress * 100))%")
                                    .monospacedDigit()
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.82))
                        }
                        .frame(maxWidth: 430)
                        .padding(.horizontal, 36)
                    }
                }
                .transition(.opacity)
            }
        }
        .persistentSystemOverlays(.hidden)
        .onAppear {
            guard scene == nil, !loadingStarted else { return }
            loadingStarted = true
            // 先绘制加载页，再分批预载资源，避免启动白屏。
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                loadProgress = 0.05
                GameScene.preloadGameAssets { progress, status in
                    loadProgress = 0.05 + progress * 0.85
                    loadStatus = status
                } completion: {
                    loadStatus = "正在建立行动场景"
                    loadProgress = 0.94
                    scene = GameScene()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeOut(duration: 0.15)) {
                            loadProgress = 1
                            loadStatus = "行动开始"
                            showingLoader = false
                        }
                    }
                }
            }
        }
    }
}
