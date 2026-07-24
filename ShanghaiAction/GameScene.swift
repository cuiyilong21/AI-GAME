import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private enum Mask {
        static let player: UInt32 = 1
        static let enemy: UInt32 = 2
        static let bullet: UInt32 = 4
    }

    private enum Weapon: Int, CaseIterable, Hashable {
        case pistol, shotgun, axe
        var name: String { ["手枪", "霰弹枪", "消防斧"][rawValue] }
        var asset: String { ["weapon_pistol", "weapon_shotgun", "weapon_axe"][rawValue] }
        var price: Int { [0, 60, 100][rawValue] }
    }

    private struct Level {
        let name: String
        let enemies: Int
        let speedBonus: CGFloat
    }

    private let levels = [
        Level(name: "南京东路", enemies: 6, speedBonus: 0),
        Level(name: "武康路", enemies: 8, speedBonus: 5),
        Level(name: "徐家汇", enemies: 10, speedBonus: 10),
        Level(name: "外滩", enemies: 12, speedBonus: 16),
        Level(name: "上海中心顶层", enemies: 14, speedBonus: 23)
    ]

    private let world = SKNode()
    private let scenery = SKNode()
    private let player = SKShapeNode(circleOfRadius: 24)
    private var weaponSprite: SKSpriteNode?

    private let hpLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let weaponLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let coinLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let missionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    private let joystickBase = SKShapeNode(circleOfRadius: 54)
    private let joystickKnob = SKShapeNode(circleOfRadius: 24)
    private let fireButton = SKShapeNode(circleOfRadius: 47)
    private let switchButton = SKShapeNode(circleOfRadius: 34)
    private let shopButton = SKShapeNode(circleOfRadius: 34)
    private let settingsButton = SKShapeNode(circleOfRadius: 28)

    private var joystickTouch: UITouch?
    private var fireTouch: UITouch?
    private var moveVector = CGVector.zero
    private var lastUpdate: TimeInterval = 0
    private var lastShot: TimeInterval = 0

    private var health = 100
    private var kills = 0
    private var currentLevel = 0
    private var enemiesToSpawn = 6
    private var weapon: Weapon = .pistol
    private var ammo: [Weapon: Int] = [.pistol: 24, .shotgun: 0]
    private var unlocked: Set<Weapon> = [.pistol]
    private var coins = 0

    private var gameStarted = false
    private var gameEnded = false
    private var shopOpen = false
    private var settingsOpen = false
    private var gamePaused = false

    override init(size: CGSize = CGSize(width: 844, height: 390)) {
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.02, green: 0.04, blue: 0.06, alpha: 1)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        addChild(world)
        world.addChild(scenery)
        buildBackground()
        buildPlayer()
        buildHUD()
        showIntro()
    }

    private func buildBackground() {
        scenery.removeAllChildren()
        let asset = String(format: "level%02d", currentLevel + 1)
        if let image = UIImage(named: asset) {
            let background = SKSpriteNode(texture: SKTexture(image: image))
            background.position = CGPoint(x: size.width / 2, y: size.height / 2)
            background.size = size
            background.zPosition = -20
            scenery.addChild(background)
        } else {
            let fallback = SKShapeNode(rectOf: size)
            fallback.position = CGPoint(x: size.width / 2, y: size.height / 2)
            fallback.fillColor = SKColor(red: 0.06, green: 0.09, blue: 0.12, alpha: 1)
            fallback.strokeColor = .clear
            fallback.zPosition = -20
            scenery.addChild(fallback)
        }
        let shade = SKShapeNode(rectOf: size)
        shade.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shade.fillColor = .black
        shade.alpha = 0.24
        shade.strokeColor = .clear
        shade.zPosition = -19
        scenery.addChild(shade)
        let alert = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        alert.position = CGPoint(x: size.width / 2, y: size.height * 0.57)
        alert.fillColor = .systemRed
        alert.alpha = 0.12
        alert.strokeColor = .clear
        alert.zPosition = -18
        scenery.addChild(alert)
    }

    private func buildPlayer() {
        player.fillColor = SKColor(red: 0.78, green: 0.57, blue: 0.42, alpha: 1)
        player.strokeColor = .white
        player.lineWidth = 3
        player.position = CGPoint(x: size.width * 0.30, y: size.height * 0.32)
        player.zPosition = 20
        world.addChild(player)

        let hair = SKShapeNode(rectOf: CGSize(width: 42, height: 14), cornerRadius: 6)
        hair.position.y = 15
        hair.fillColor = SKColor(white: 0.05, alpha: 1)
        hair.strokeColor = .clear
        player.addChild(hair)
        for x: CGFloat in [-9, 9] {
            let eye = SKShapeNode(circleOfRadius: 3)
            eye.position = CGPoint(x: x, y: 2)
            eye.fillColor = .white
            eye.strokeColor = .black
            player.addChild(eye)
            let pupil = SKShapeNode(circleOfRadius: 1.3)
            pupil.position.x = 0.8
            pupil.fillColor = .black
            pupil.strokeColor = .clear
            eye.addChild(pupil)
        }
        let mouth = SKShapeNode(rectOf: CGSize(width: 10, height: 2), cornerRadius: 1)
        mouth.position.y = -11
        mouth.fillColor = .black
        mouth.strokeColor = .clear
        player.addChild(mouth)

        let body = SKShapeNode(rectOf: CGSize(width: 38, height: 48), cornerRadius: 8)
        body.position.y = -44
        body.fillColor = SKColor(red: 0.05, green: 0.23, blue: 0.29, alpha: 1)
        body.strokeColor = .cyan
        body.lineWidth = 2
        player.addChild(body)
        let backpack = SKShapeNode(rectOf: CGSize(width: 14, height: 35), cornerRadius: 4)
        backpack.position = CGPoint(x: -25, y: -42)
        backpack.fillColor = .darkGray
        backpack.strokeColor = .systemOrange
        player.addChild(backpack)

        updateWeaponGraphic()
        player.physicsBody = SKPhysicsBody(circleOfRadius: 24)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = Mask.player
        player.physicsBody?.contactTestBitMask = Mask.enemy
        player.physicsBody?.collisionBitMask = 0
    }

    private func makeLabel(_ node: SKLabelNode, text: String, position: CGPoint, size fontSize: CGFloat, alignment: SKLabelHorizontalAlignmentMode = .left) {
        node.text = text
        node.fontSize = fontSize
        node.fontColor = .white
        node.horizontalAlignmentMode = alignment
        node.position = position
        node.zPosition = 100
        addChild(node)
    }

    private func buildHUD() {
        makeLabel(hpLabel, text: "生命 100", position: CGPoint(x: 75, y: size.height - 42), size: 18)
        makeLabel(levelLabel, text: "第 1/5 关 · 南京东路", position: CGPoint(x: size.width / 2, y: size.height - 41), size: 18, alignment: .center)
        makeLabel(weaponLabel, text: "手枪 · 24", position: CGPoint(x: size.width - 25, y: size.height - 42), size: 18, alignment: .right)
        makeLabel(coinLabel, text: "申城币 0", position: CGPoint(x: size.width - 25, y: size.height - 68), size: 14, alignment: .right)
        makeLabel(missionLabel, text: "任务 · 清除感染者 0/6", position: CGPoint(x: size.width / 2, y: 27), size: 18, alignment: .center)

        joystickBase.fillColor = .black
        joystickBase.alpha = 0.38
        joystickBase.strokeColor = .white
        joystickBase.position = CGPoint(x: 92, y: 85)
        joystickBase.zPosition = 90
        addChild(joystickBase)
        joystickKnob.fillColor = .white
        joystickKnob.alpha = 0.58
        joystickKnob.strokeColor = .clear
        joystickKnob.position = joystickBase.position
        joystickKnob.zPosition = 91
        addChild(joystickKnob)

        addRoundButton(fireButton, name: "fire", text: "开火", position: CGPoint(x: size.width - 88, y: 83), color: .systemRed, fontSize: 18)
        addRoundButton(switchButton, name: "switch", text: "换", position: CGPoint(x: size.width - 180, y: 62), color: .black, fontSize: 16, stroke: .cyan)
        addRoundButton(shopButton, name: "shop", text: "商店", position: CGPoint(x: size.width - 180, y: 137), color: .black, fontSize: 13, stroke: .systemYellow)
        addRoundButton(settingsButton, name: "settings", text: "⚙", position: CGPoint(x: 35, y: size.height - 92), color: .black, fontSize: 22)
    }

    private func addRoundButton(_ node: SKShapeNode, name: String, text: String, position: CGPoint, color: SKColor, fontSize: CGFloat, stroke: SKColor = .white) {
        node.name = name
        node.position = position
        node.fillColor = color
        node.alpha = 0.72
        node.strokeColor = stroke
        node.zPosition = 100
        addChild(node)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = text
        label.fontSize = fontSize
        label.verticalAlignmentMode = .center
        node.addChild(label)
    }

    private func showIntro() {
        let panel = makePanel(name: "intro", size: CGSize(width: min(620, size.width - 80), height: 205), color: SKColor(white: 0.025, alpha: 0.94), stroke: .cyan, z: 250)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "上海行动"
        title.fontSize = 35
        title.position.y = 48
        panel.addChild(title)
        let story = SKLabelNode(fontNamed: "AvenirNext-Regular")
        story.text = "穿过五个失守街区，登顶上海中心，取回解药。"
        story.fontSize = 17
        story.fontColor = .lightGray
        story.position.y = 5
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "start"
        start.text = "点击开始行动"
        start.fontSize = 21
        start.fontColor = .cyan
        start.position.y = -55
        panel.addChild(start)
    }

    private func makePanel(name: String, size panelSize: CGSize, color: SKColor, stroke: SKColor, z: CGFloat) -> SKShapeNode {
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 18)
        panel.name = name
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = color
        panel.strokeColor = stroke
        panel.lineWidth = 2
        panel.zPosition = z
        addChild(panel)
        return panel
    }

    private func updateWeaponGraphic() {
        weaponSprite?.removeFromParent()
        let texture = SKTexture(imageNamed: weapon.asset)
        let sprite = SKSpriteNode(texture: texture)
        switch weapon {
        case .pistol:
            sprite.size = CGSize(width: 68, height: 45)
            sprite.position = CGPoint(x: 42, y: -13)
        case .shotgun:
            sprite.size = CGSize(width: 116, height: 42)
            sprite.position = CGPoint(x: 55, y: -14)
        case .axe:
            sprite.size = CGSize(width: 96, height: 48)
            sprite.position = CGPoint(x: 47, y: -14)
        }
        sprite.zPosition = 5
        player.addChild(sprite)
        weaponSprite = sprite
    }

    private func spawnEnemy() {
        guard gameStarted, !gameEnded, enemiesToSpawn > 0 else { return }
        enemiesToSpawn -= 1
        let heavy = currentLevel >= 2 && Int.random(in: 0...3) == 0
        let radius: CGFloat = heavy ? 28 : 22
        let enemy = SKShapeNode(circleOfRadius: radius)
        enemy.name = heavy ? "enemyHeavy" : "enemy"
        enemy.position = CGPoint(x: size.width + 35, y: CGFloat.random(in: 95...size.height * 0.53))
        enemy.zPosition = 15
        enemy.fillColor = heavy ? SKColor(red: 0.56, green: 0.46, blue: 0.33, alpha: 1) : SKColor(red: 0.43, green: 0.56, blue: 0.36, alpha: 1)
        enemy.strokeColor = .systemRed
        enemy.lineWidth = 3
        enemy.userData = ["hp": (heavy ? 4 : 2) + currentLevel / 2]

        let hair = SKShapeNode(rectOf: CGSize(width: radius * 1.65, height: 11), cornerRadius: 4)
        hair.position.y = radius * 0.65
        hair.fillColor = SKColor(white: 0.08, alpha: 1)
        hair.strokeColor = .clear
        enemy.addChild(hair)
        for x: CGFloat in [-8, 8] {
            let eye = SKShapeNode(circleOfRadius: heavy ? 3.5 : 3)
            eye.position = CGPoint(x: x, y: 3)
            eye.fillColor = .systemRed
            eye.strokeColor = .black
            eye.glowWidth = 2
            enemy.addChild(eye)
        }
        let mouth = SKShapeNode(rectOf: CGSize(width: heavy ? 18 : 14, height: 4), cornerRadius: 2)
        mouth.position.y = -12
        mouth.fillColor = .black
        mouth.strokeColor = .systemRed
        enemy.addChild(mouth)
        let body = SKShapeNode(rectOf: CGSize(width: heavy ? 46 : 36, height: heavy ? 54 : 46), cornerRadius: 8)
        body.position.y = heavy ? -48 : -41
        body.fillColor = heavy ? .brown : .darkGray
        body.strokeColor = .systemRed
        enemy.addChild(body)
        for side: CGFloat in [-1, 1] {
            let arm = SKShapeNode(rectOf: CGSize(width: 27, height: 8), cornerRadius: 3)
            arm.position = CGPoint(x: side * (heavy ? 30 : 25), y: -30)
            arm.zRotation = -side * 0.24
            arm.fillColor = enemy.fillColor
            arm.strokeColor = .systemRed
            enemy.addChild(arm)
        }

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = Mask.enemy
        enemy.physicsBody?.contactTestBitMask = Mask.player | Mask.bullet
        enemy.physicsBody?.collisionBitMask = 0
        world.addChild(enemy)
    }

    private func spawnWave() {
        let count = enemiesToSpawn
        for index in 0..<count {
            run(.sequence([.wait(forDuration: Double(index) * 0.72), .run { [weak self] in self?.spawnEnemy() }]))
        }
        run(.sequence([.wait(forDuration: 2.2), .run { [weak self] in self?.spawnAirdrop() }]))
        updateHUD()
    }

    private func nearestEnemy() -> SKNode? {
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.min {
            hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < hypot($1.position.x - player.position.x, $1.position.y - player.position.y)
        }
    }

    private func fire(now: TimeInterval) {
        let delay = weapon == .axe ? 0.55 : (weapon == .shotgun ? 0.72 : 0.28)
        guard now - lastShot > delay, let target = nearestEnemy() else { return }
        lastShot = now
        let dx = target.position.x - player.position.x
        let dy = target.position.y - player.position.y
        let distance = max(1, hypot(dx, dy))
        player.zRotation = atan2(dy, dx)
        if weapon == .axe {
            if distance < 115 { hit(target, damage: 3) }
            pulse(at: player.position, color: .white, radius: 70)
            return
        }
        guard ammo[weapon, default: 0] > 0 else { showToast("弹药耗尽，寻找空投！", color: .systemRed); return }
        ammo[weapon, default: 0] -= 1
        updateHUD()
        let pelletCount = weapon == .shotgun ? 5 : 1
        for index in 0..<pelletCount {
            let bullet = SKShapeNode(circleOfRadius: weapon == .shotgun ? 3 : 4)
            bullet.name = "bullet"
            bullet.fillColor = .yellow
            bullet.strokeColor = .white
            bullet.position = player.position
            bullet.zPosition = 30
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: 4)
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = Mask.bullet
            bullet.physicsBody?.contactTestBitMask = Mask.enemy
            bullet.physicsBody?.collisionBitMask = 0
            world.addChild(bullet)
            let spread = (CGFloat(index) - CGFloat(pelletCount - 1) / 2) * 0.07
            let angle = atan2(dy, dx) + spread
            bullet.physicsBody?.velocity = CGVector(dx: cos(angle) * 680, dy: sin(angle) * 680)
            bullet.run(.sequence([.wait(forDuration: 1.3), .removeFromParent()]))
        }
        pulse(at: CGPoint(x: player.position.x + cos(player.zRotation) * 48, y: player.position.y + sin(player.zRotation) * 48), color: .systemOrange, radius: 17)
    }

    private func pulse(at point: CGPoint, color: SKColor, radius: CGFloat) {
        let pulse = SKShapeNode(circleOfRadius: radius)
        pulse.position = point
        pulse.strokeColor = color
        pulse.lineWidth = 4
        pulse.fillColor = .clear
        pulse.zPosition = 29
        world.addChild(pulse)
        pulse.run(.sequence([.group([.scale(to: 1.45, duration: 0.12), .fadeOut(withDuration: 0.12)]), .removeFromParent()]))
    }

    private func hit(_ enemy: SKNode, damage: Int) {
        guard let data = enemy.userData else { return }
        let hp = (data["hp"] as? Int ?? 1) - damage
        data["hp"] = hp
        if hp <= 0 {
            enemy.removeFromParent()
            kills += 1
            updateHUD()
            checkLevelCompletion()
        }
    }

    private func checkLevelCompletion() {
        guard kills >= levels[currentLevel].enemies else { return }
        if currentLevel < levels.count - 1 {
            currentLevel += 1
            kills = 0
            enemiesToSpawn = levels[currentLevel].enemies
            health = min(100, health + 12)
            coins += 15 + currentLevel * 3
            world.children.filter { $0.name?.hasPrefix("enemy") == true || $0.name == "airdrop" }.forEach { $0.removeFromParent() }
            buildBackground()
            showToast("进入第 \(currentLevel + 1) 关 · 难度提升", color: .cyan)
            updateHUD()
            run(.sequence([.wait(forDuration: 1.4), .run { [weak self] in self?.spawnWave() }]))
        } else {
            winGame()
        }
    }

    private func spawnAirdrop() {
        guard gameStarted, !gameEnded, world.childNode(withName: "airdrop") == nil else { return }
        let box = SKShapeNode(rectOf: CGSize(width: 58, height: 44), cornerRadius: 7)
        box.name = "airdrop"
        box.position = CGPoint(x: CGFloat.random(in: size.width * 0.40...size.width * 0.72), y: size.height + 40)
        box.zPosition = 25
        box.fillColor = .systemRed
        box.strokeColor = .white
        box.lineWidth = 3
        let stripe = SKShapeNode(rectOf: CGSize(width: 12, height: 40))
        stripe.fillColor = .white
        stripe.strokeColor = .clear
        box.addChild(stripe)
        world.addChild(box)
        box.run(.sequence([.moveTo(y: CGFloat.random(in: 110...size.height * 0.48), duration: 1.0), .run { [weak self] in self?.showToast("空投抵达，靠近自动开启", color: .systemYellow) }]))
    }

    private func openAirdrop(_ box: SKNode) {
        let pistol = Int.random(in: 10...18)
        let shotgun = Int.random(in: 3...7)
        let reward = Int.random(in: 25...45)
        ammo[.pistol, default: 0] += pistol
        ammo[.shotgun, default: 0] += shotgun
        coins += reward
        pulse(at: box.position, color: .systemYellow, radius: 42)
        box.removeFromParent()
        updateHUD()
        showToast("空投：手枪 +\(pistol) 霰弹 +\(shotgun) 申城币 +\(reward)", color: .systemYellow)
    }

    private func updateHUD() {
        hpLabel.text = "生命 \(max(0, health))"
        levelLabel.text = "第 \(currentLevel + 1)/5 关 · \(levels[currentLevel].name)"
        weaponLabel.text = "\(weapon.name) · \(weapon == .axe ? "∞" : String(ammo[weapon, default: 0]))"
        coinLabel.text = "申城币 \(coins)"
        missionLabel.text = "任务 · 清除感染者 \(kills)/\(levels[currentLevel].enemies)"
    }

    private func showToast(_ text: String, color: SKColor) {
        childNode(withName: "toast")?.removeFromParent()
        let toast = SKLabelNode(fontNamed: "AvenirNext-Bold")
        toast.name = "toast"
        toast.text = text
        toast.fontSize = 16
        toast.fontColor = color
        toast.position = CGPoint(x: size.width / 2, y: size.height - 94)
        toast.zPosition = 500
        addChild(toast)
        toast.run(.sequence([.wait(forDuration: 1.8), .fadeOut(withDuration: 0.3), .removeFromParent()]))
    }

    private func showShop() {
        guard !shopOpen else { closeShop(); return }
        shopOpen = true
        stopControls()
        let panel = makePanel(name: "shopPanel", size: CGSize(width: min(520, size.width - 100), height: 230), color: SKColor(white: 0.025, alpha: 0.97), stroke: .systemYellow, z: 300)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "幸存者武器站 · \(coins) 币"
        title.fontSize = 24
        title.position.y = 72
        panel.addChild(title)
        addShopItem(to: panel, weapon: .shotgun, y: 22)
        addShopItem(to: panel, weapon: .axe, y: -35)
        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.name = "closeShop"
        close.text = "关闭"
        close.fontSize = 17
        close.position.y = -88
        panel.addChild(close)
    }

    private func addShopItem(to panel: SKNode, weapon item: Weapon, y: CGFloat) {
        let owned = unlocked.contains(item)
        let button = SKShapeNode(rectOf: CGSize(width: 350, height: 44), cornerRadius: 9)
        button.name = owned ? "owned" : "buy_\(item.rawValue)"
        button.position.y = y
        button.fillColor = owned ? .darkGray : SKColor(red: 0.08, green: 0.24, blue: 0.27, alpha: 1)
        button.strokeColor = owned ? .gray : .cyan
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = button.name
        label.text = owned ? "\(item.name) · 已拥有" : "解锁 \(item.name) · \(item.price) 币"
        label.fontSize = 17
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func buyWeapon(_ item: Weapon) {
        guard !unlocked.contains(item) else { return }
        guard coins >= item.price else { showToast("申城币不足，继续搜寻空投", color: .systemRed); return }
        coins -= item.price
        unlocked.insert(item)
        weapon = item
        if item == .shotgun { ammo[.shotgun, default: 0] += 5 }
        updateWeaponGraphic()
        closeShop()
        updateHUD()
        showToast("已解锁 \(item.name)", color: .cyan)
    }

    private func closeShop() {
        childNode(withName: "shopPanel")?.removeFromParent()
        shopOpen = false
    }

    private func showSettings() {
        guard gameStarted, !gameEnded else { return }
        if settingsOpen { resumeGame(); return }
        settingsOpen = true
        gamePaused = true
        stopControls()
        world.isPaused = true
        speed = 0
        let dim = SKShapeNode(rectOf: size)
        dim.name = "settingsPanel"
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = .black
        dim.alpha = 0.74
        dim.strokeColor = .clear
        dim.zPosition = 400
        addChild(dim)
        let panel = SKShapeNode(rectOf: CGSize(width: min(430, size.width - 100), height: 245), cornerRadius: 20)
        panel.fillColor = SKColor(red: 0.02, green: 0.07, blue: 0.09, alpha: 0.98)
        panel.strokeColor = .cyan
        panel.lineWidth = 2
        panel.zPosition = 1
        dim.addChild(panel)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "行动设置"
        title.fontSize = 28
        title.position.y = 78
        panel.addChild(title)
        addMenuButton(to: panel, name: "resumeGame", text: "继续行动", y: 20, color: .systemTeal)
        addMenuButton(to: panel, name: "restartGame", text: "重新开始", y: -42, color: .systemRed)
        let note = SKLabelNode(fontNamed: "AvenirNext-Regular")
        note.text = "当前进度：第 \(currentLevel + 1) 关 · \(levels[currentLevel].name)"
        note.fontSize = 14
        note.fontColor = .lightGray
        note.position.y = -94
        panel.addChild(note)
    }

    private func addMenuButton(to panel: SKNode, name: String, text: String, y: CGFloat, color: SKColor) {
        let button = SKShapeNode(rectOf: CGSize(width: 280, height: 48), cornerRadius: 11)
        button.name = name
        button.position.y = y
        button.fillColor = color
        button.alpha = 0.82
        button.strokeColor = .white
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = text
        label.fontSize = 19
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func resumeGame() {
        childNode(withName: "settingsPanel")?.removeFromParent()
        settingsOpen = false
        gamePaused = false
        world.isPaused = false
        speed = 1
        lastUpdate = 0
    }

    private func restartGame() {
        guard let view else { return }
        speed = 1
        view.presentScene(GameScene(size: size), transition: .fade(withDuration: 0.35))
    }

    private func stopControls() {
        fireTouch = nil
        joystickTouch = nil
        moveVector = .zero
        joystickKnob.position = joystickBase.position
    }

    private func winGame() {
        gameEnded = true
        stopControls()
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
        let panel = makePanel(name: "winPanel", size: CGSize(width: min(620, size.width - 60), height: 220), color: SKColor(red: 0.02, green: 0.12, blue: 0.14, alpha: 0.97), stroke: .cyan, z: 350)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "解药已取得"
        title.fontSize = 36
        title.fontColor = .cyan
        title.position.y = 52
        panel.addChild(title)
        let message = SKLabelNode(fontNamed: "AvenirNext-Regular")
        message.text = "黎明照亮上海，危机解除。"
        message.fontSize = 19
        message.position.y = 8
        panel.addChild(message)
        let restart = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restart.name = "restartGame"
        restart.text = "点击重新行动"
        restart.fontSize = 18
        restart.position.y = -55
        panel.addChild(restart)
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = min(0.04, lastUpdate == 0 ? 0 : currentTime - lastUpdate)
        lastUpdate = currentTime
        guard gameStarted, !gameEnded, !shopOpen, !gamePaused else { return }
        player.position.x = max(35, min(size.width - 35, player.position.x + moveVector.dx * 220 * delta))
        player.position.y = max(70, min(size.height * 0.55, player.position.y + moveVector.dy * 220 * delta))
        for enemy in world.children where enemy.name?.hasPrefix("enemy") == true {
            let dx = player.position.x - enemy.position.x
            let dy = player.position.y - enemy.position.y
            let distance = max(1, hypot(dx, dy))
            let base: CGFloat = enemy.name == "enemyHeavy" ? 50 : 74
            let speed = base + levels[currentLevel].speedBonus
            enemy.position.x += dx / distance * speed * delta
            enemy.position.y += dy / distance * speed * delta
        }
        if let box = world.childNode(withName: "airdrop"), hypot(box.position.x - player.position.x, box.position.y - player.position.y) < 62 { openAirdrop(box) }
        if fireTouch != nil { fire(now: currentTime) }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let first = contact.bodyA.node
        let second = contact.bodyB.node
        if first?.name == "bullet", let enemy = second, enemy.name?.hasPrefix("enemy") == true {
            first?.removeFromParent(); hit(enemy, damage: 1)
        } else if second?.name == "bullet", let enemy = first, enemy.name?.hasPrefix("enemy") == true {
            second?.removeFromParent(); hit(enemy, damage: 1)
        } else if first === player || second === player {
            let enemy = first === player ? second : first
            if enemy?.name?.hasPrefix("enemy") == true {
                health -= 8
                enemy?.position.x += 48
                updateHUD()
                if health <= 0 { gameEnded = true; stopControls(); missionLabel.text = "行动失败 · 点击设置重新开始" }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            let hitNodes = nodes(at: point)
            let names = hitNodes.compactMap(\.name)
            if names.contains("resumeGame") { resumeGame(); continue }
            if names.contains("restartGame") { restartGame(); continue }
            if names.contains("settings") { showSettings(); continue }
            if settingsOpen { continue }
            if !gameStarted, hitNodes.contains(where: { $0.name == "start" || $0.parent?.name == "intro" }) {
                childNode(withName: "intro")?.removeFromParent()
                gameStarted = true
                spawnWave()
                continue
            }
            if let buyName = names.first(where: { $0.hasPrefix("buy_") }), let raw = Int(buyName.replacingOccurrences(of: "buy_", with: "")), let item = Weapon(rawValue: raw) {
                buyWeapon(item)
                continue
            }
            if names.contains("closeShop") { closeShop(); continue }
            if names.contains("shop") { showShop(); continue }
            if shopOpen { continue }
            if names.contains("switch") {
                let available = Weapon.allCases.filter { unlocked.contains($0) }
                if let index = available.firstIndex(of: weapon) { weapon = available[(index + 1) % available.count] }
                updateWeaponGraphic()
                updateHUD()
            } else if point.x < size.width * 0.35 {
                joystickTouch = touch
                updateJoystick(point)
            } else if names.contains("fire") || point.x > size.width * 0.72 {
                fireTouch = touch
                fire(now: lastUpdate)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches where touch === joystickTouch { updateJoystick(touch.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === joystickTouch { joystickTouch = nil; moveVector = .zero; joystickKnob.position = joystickBase.position }
            if touch === fireTouch { fireTouch = nil }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { touchesEnded(touches, with: event) }

    private func updateJoystick(_ point: CGPoint) {
        let dx = point.x - joystickBase.position.x
        let dy = point.y - joystickBase.position.y
        let distance = max(1, hypot(dx, dy))
        let magnitude = min(45, distance)
        moveVector = CGVector(dx: dx / distance, dy: dy / distance)
        joystickKnob.position = CGPoint(x: joystickBase.position.x + dx / distance * magnitude, y: joystickBase.position.y + dy / distance * magnitude)
    }
}
