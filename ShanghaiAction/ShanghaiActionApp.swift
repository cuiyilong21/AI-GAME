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

    var body: some View {
        ZStack {
            Color(red: 0.015, green: 0.03, blue: 0.045)
                .ignoresSafeArea()

            if let scene {
                SpriteView(scene: scene, options: [.ignoresSiblingOrder, .shouldCullNonVisibleNodes])
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.cyan)
                        .scaleEffect(1.25)
                    Text("正在载入上海行动…")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
        .persistentSystemOverlays(.hidden)
        .onAppear {
            guard scene == nil else { return }
            // 先让 SwiftUI 绘制深色加载帧，再创建 SpriteKit 场景。
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                scene = GameScene()
            }
        }
    }
}
