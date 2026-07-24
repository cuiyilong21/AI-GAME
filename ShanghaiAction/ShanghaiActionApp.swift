import SwiftUI
import SpriteKit

@main
struct ShanghaiActionApp: App {
    var body: some Scene {
        WindowGroup {
            SpriteView(scene: GameScene(), options: [.ignoresSiblingOrder])
                .ignoresSafeArea()
                .background(Color.black)
                .persistentSystemOverlays(.hidden)
        }
    }
}

