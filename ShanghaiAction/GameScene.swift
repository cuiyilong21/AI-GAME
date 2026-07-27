import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private enum Mask {
        static let player: UInt32 = 1
        static let enemy: UInt32 = 2
        static let bullet: UInt32 = 4
    }

    private enum Weapon: Int, CaseIterable, Hashable {
        case pistol, shotgun, axe, thompson, barrett
        var name: String { ["手枪", "s1897霰弹枪", "消防斧", "汤普森冲锋枪", "巴雷特狙击枪"][rawValue] }
        var asset: String { ["weapon_pistol", "weapon_shotgun", "weapon_axe", "weapon_thompson", "weapon_barrett"][rawValue] }
        var price: Int { [0, 60, 100, 140, 220][rawValue] }
        var shotDelay: TimeInterval { [0.28, 0.72, 0.55, 0.10, 1.25][rawValue] }
        var damage: Int { [1, 1, 3, 1, 7][rawValue] }
    }

    private enum ArmorKind: String {
        case helmet, vest
        var name: String { self == .helmet ? "头盔" : "防弹衣" }
        var prices: [Int] { self == .helmet ? [0, 35, 70, 120] : [0, 45, 90, 150] }
    }

    private enum Training: String, CaseIterable, Hashable {
        case speed, accuracy, kick
        var name: String { ["速度", "枪法", "踢击力量"][Training.allCases.firstIndex(of: self)!] }
        var detail: String { ["移动速度提升", "提高弹速与暴击率", "提高踢击伤害与击退"][Training.allCases.firstIndex(of: self)!] }
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
        Level(name: "上海中心顶层", enemies: 14, speedBonus: 23),
        Level(name: "陆家嘴疏散区", enemies: 12, speedBonus: 27),
        Level(name: "上海中心救援站", enemies: 16, speedBonus: 32)
    ]

    private let world = SKNode()
    private let scenery = SKNode()
    private var textureCache: [String: SKTexture] = [:]
    private let player = SKShapeNode(circleOfRadius: 24)
    private var playerPortrait: SKSpriteNode?
    private var weaponSprite: SKSpriteNode?
    private var helmetSprite: SKSpriteNode?
    private var vestSprite: SKSpriteNode?

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
    private let trainingButton = SKShapeNode(circleOfRadius: 30)
    private let kickButton = SKShapeNode(circleOfRadius: 30)
    private let settingsButton = SKShapeNode(circleOfRadius: 28)

    private var joystickTouch: UITouch?
    private var fireTouch: UITouch?
    private var moveVector = CGVector.zero
    private var lastUpdate: TimeInterval = 0
    private var lastShot: TimeInterval = 0
    private var lastAllyShot: TimeInterval = 0
    private var lastKick: TimeInterval = 0

    private var health = 100
    private var kills = 0
    private var currentLevel = 0
    private var enemiesToSpawn = 6
    private var weapon: Weapon = .pistol
    private var ammo: [Weapon: Int] = [.pistol: 24, .shotgun: 0, .thompson: 0, .barrett: 0]
    private var unlocked: Set<Weapon> = [.pistol]
    private var coins = 0
    private var helmetLevel = 0
    private var vestLevel = 0
    private var allyWeaponLevel = 0
    private var trainingLevels: [Training: Int] = [.speed: 0, .accuracy: 0, .kick: 0]

    private var isCurePhase: Bool { currentLevel >= 5 }
    private var allies: [SKNode] { world.children.filter { $0.name == "ally" } }

    private var gameStarted = false
    private var gameEnded = false
    private var shopOpen = false
    private var settingsOpen = false
    private var trainingOpen = false
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
        guard world.parent == nil else { return }
        addChild(world)
        world.addChild(scenery)
        buildBackground()
        buildPlayer()
        buildHUD()
        showIntro()
    }

    private func cachedTexture(_ name: String) -> SKTexture {
        if let texture = textureCache[name] { return texture }
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .linear
        textureCache[name] = texture
        return texture
    }

    private func bodyPart(name: String, size: CGSize, position: CGPoint, color: SKColor, stroke: SKColor, z: CGFloat) -> SKShapeNode {
        let part = SKShapeNode(rectOf: size, cornerRadius: min(size.width, size.height) * 0.34)
        part.name = name
        part.position = position
        part.fillColor = color
        part.strokeColor = stroke
        part.lineWidth = 1.5
        part.zPosition = z
        return part
    }

    private func addPlayerBody() {
        let jacket = SKColor(red: 0.035, green: 0.18, blue: 0.25, alpha: 1)
        let denim = SKColor(red: 0.06, green: 0.10, blue: 0.16, alpha: 1)
        let skin = SKColor(red: 0.72, green: 0.49, blue: 0.34, alpha: 1)

        let torso = bodyPart(name: "playerTorso", size: CGSize(width: 42, height: 52), position: CGPoint(x: 0, y: -43), color: jacket, stroke: .cyan, z: -1)
        player.addChild(torso)
        for side: CGFloat in [-1, 1] {
            let arm = bodyPart(name: side < 0 ? "playerArmLeft" : "playerArmRight", size: CGSize(width: 12, height: 43), position: CGPoint(x: side * 27, y: -38), color: jacket, stroke: skin, z: -2)
            arm.zRotation = side * 0.08
            player.addChild(arm)
            let hand = SKShapeNode(circleOfRadius: 6)
            hand.position.y = -22
            hand.fillColor = skin
            hand.strokeColor = .clear
            arm.addChild(hand)

            let leg = bodyPart(name: side < 0 ? "playerLegLeft" : "playerLegRight", size: CGSize(width: 14, height: 43), position: CGPoint(x: side * 11, y: -87), color: denim, stroke: .darkGray, z: -2)
            player.addChild(leg)
            let boot = bodyPart(name: "playerBoot", size: CGSize(width: 18, height: 10), position: CGPoint(x: 2, y: -24), color: .black, stroke: .darkGray, z: 0)
            leg.addChild(boot)
        }
    }

    private func addEnemyBody(to enemy: SKNode, heavy: Bool, radius: CGFloat) {
        let cloth = heavy ? SKColor(red: 0.22, green: 0.13, blue: 0.10, alpha: 1) : SKColor(red: 0.16, green: 0.18, blue: 0.14, alpha: 1)
        let infectedSkin = SKColor(red: 0.38, green: 0.43, blue: 0.32, alpha: 1)
        let scale: CGFloat = heavy ? 1.18 : 1
        enemy.addChild(bodyPart(name: "enemyTorso", size: CGSize(width: 40 * scale, height: 50 * scale), position: CGPoint(x: 0, y: -radius - 25 * scale), color: cloth, stroke: .systemRed, z: -1))
        for side: CGFloat in [-1, 1] {
            let arm = bodyPart(name: side < 0 ? "enemyArmLeft" : "enemyArmRight", size: CGSize(width: 11 * scale, height: 46 * scale), position: CGPoint(x: side * 27 * scale, y: -radius - 19 * scale), color: infectedSkin, stroke: .systemRed, z: -2)
            arm.zRotation = side < 0 ? -0.42 : 0.26
            enemy.addChild(arm)
            let leg = bodyPart(name: side < 0 ? "enemyLegLeft" : "enemyLegRight", size: CGSize(width: 14 * scale, height: 43 * scale), position: CGPoint(x: side * 11 * scale, y: -radius - 67 * scale), color: cloth, stroke: .darkGray, z: -2)
            enemy.addChild(leg)
        }
    }

    private func buildBackground() {
        scenery.removeAllChildren()
        let backgroundIndex = currentLevel < 5 ? currentLevel + 1 : (currentLevel == 5 ? 4 : 5)
        let asset = String(format: "level%02d", backgroundIndex)
        let background = SKSpriteNode(texture: cachedTexture(asset))
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -20
        scenery.addChild(background)
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
        player.fillColor = SKColor(white: 0.04, alpha: 0.95)
        player.strokeColor = .cyan
        player.lineWidth = 4
        player.position = CGPoint(x: size.width * 0.30, y: size.height * 0.32)
        player.zPosition = 20
        world.addChild(player)

        let portrait = SKSpriteNode(texture: cachedTexture("player_survivor"))
        portrait.name = "playerPortrait"
        portrait.size = CGSize(width: 47, height: 47)
        portrait.zPosition = 1
        player.addChild(portrait)
        playerPortrait = portrait
        addPlayerBody()

        let helmet = SKSpriteNode()
        helmet.position = CGPoint(x: -24, y: 30)
        helmet.size = CGSize(width: 29, height: 29)
        helmet.zPosition = 3
        helmet.isHidden = true
        player.addChild(helmet)
        helmetSprite = helmet

        let vest = SKSpriteNode()
        vest.position = CGPoint(x: -25, y: -29)
        vest.size = CGSize(width: 27, height: 27)
        vest.zPosition = 3
        vest.isHidden = true
        player.addChild(vest)
        vestSprite = vest

        updateWeaponGraphic()
        updateArmorGraphics()
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 48, height: 108), center: CGPoint(x: 0, y: -40))
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
        makeLabel(levelLabel, text: "第 1/7 关 · 南京东路", position: CGPoint(x: size.width / 2, y: size.height - 41), size: 18, alignment: .center)
        makeLabel(weaponLabel, text: "手枪 · 20", position: CGPoint(x: size.width - 25, y: size.height - 42), size: 18, alignment: .right)
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
        addRoundButton(trainingButton, name: "training", text: "训练", position: CGPoint(x: size.width - 255, y: 137), color: .black, fontSize: 12, stroke: .systemGreen)
        addRoundButton(kickButton, name: "kick", text: "踢", position: CGPoint(x: size.width - 255, y: 62), color: .black, fontSize: 16, stroke: .systemOrange)
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
        story.text = "已登顶上海中心，取回解药，拯救感染者。"
        story.fontSize = 17
        story.fontColor = .lightGray
        story.position.y = 5
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "start"
        start.text = "点击开始行动（第一章）"
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
        let texture = cachedTexture(weapon.asset)
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
        case .thompson:
            sprite.size = CGSize(width: 112, height: 46)
            sprite.position = CGPoint(x: 54, y: -14)
        case .barrett:
            sprite.size = CGSize(width: 152, height: 52)
            sprite.position = CGPoint(x: 72, y: -13)
        }
        sprite.zPosition = 5
        player.addChild(sprite)
        weaponSprite = sprite
    }

    private func spawnEnemy() {
        guard gameStarted, !gameEnded, enemiesToSpawn > 0 else { return }
        enemiesToSpawn -= 1
        let typeRoll = Int.random(in: 0..<100)
        let heavy = currentLevel >= 2 && typeRoll < 25
        let runner = !heavy && currentLevel >= 1 && typeRoll < 55
        let radius: CGFloat = heavy ? 31 : (runner ? 21 : 25)
        let enemy = SKShapeNode(circleOfRadius: radius)
        enemy.name = heavy ? "enemyHeavy" : (runner ? "enemyRunner" : "enemy")
        enemy.position = CGPoint(x: size.width + 35, y: CGFloat.random(in: 95...size.height * 0.53))
        enemy.zPosition = 15
        enemy.fillColor = SKColor(white: 0.03, alpha: 0.96)
        enemy.strokeColor = heavy ? .systemOrange : (runner ? .systemGreen : .systemRed)
        enemy.lineWidth = heavy ? 5 : (runner ? 4 : 3)
        let enemyHP = heavy ? 9 + currentLevel : (runner ? 1 + currentLevel / 3 : 2 + currentLevel / 2)
        enemy.userData = ["hp": enemyHP]

        let portrait = SKSpriteNode(texture: cachedTexture(heavy ? "zombie_heavy" : "zombie_standard"))
        let diameter = radius * 1.92
        portrait.size = CGSize(width: diameter, height: diameter)
        portrait.zPosition = 1
        if runner {
            portrait.color = .systemGreen
            portrait.colorBlendFactor = 0.22
        }
        enemy.addChild(portrait)
        addEnemyBody(to: enemy, heavy: heavy, radius: radius)

        if heavy || runner {
            let badge = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            badge.text = heavy ? "重型" : "疾行者"
            badge.fontSize = 10
            badge.fontColor = heavy ? .systemOrange : .systemGreen
            badge.position = CGPoint(x: 0, y: -radius - 14)
            badge.zPosition = 2
            enemy.addChild(badge)
        }

        let bodyHeight: CGFloat = heavy ? 126 : (runner ? 96 : 108)
        let bodyCenterY: CGFloat = heavy ? -43 : (runner ? -33 : -36)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: radius * 2, height: bodyHeight), center: CGPoint(x: 0, y: bodyCenterY))
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
        let chestCount = min(4, 2 + currentLevel / 3)
        let waveLevel = currentLevel
        let enemySpawnDuration = Double(max(1, count - 1)) * 0.72
        let supportStart = max(4.0, enemySpawnDuration * 0.62)
        run(.sequence([.wait(forDuration: supportStart), .run { [weak self] in self?.spawnAirdrop(for: waveLevel) }]))
        for index in 0..<chestCount {
            let chestDelay = supportStart + 1.3 + Double(index) * 1.7
            run(.sequence([.wait(forDuration: chestDelay), .run { [weak self] in self?.spawnCoinChest(for: waveLevel) }]))
        }
        updateHUD()
    }

    private func nearestEnemy() -> SKNode? {
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.min {
            hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < hypot($1.position.x - player.position.x, $1.position.y - player.position.y)
        }
    }

    private func fire(now: TimeInterval) {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        guard now - lastShot > weapon.shotDelay, let target = nearestEnemy() else { return }
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
            let accuracyLevel = trainingLevels[.accuracy, default: 0]
            let critical = Int.random(in: 0..<100) < accuracyLevel * 9
            bullet.userData = ["damage": critical ? weapon.damage * 2 : weapon.damage]
            bullet.fillColor = isCurePhase ? .cyan : (weapon == .barrett ? .systemRed : .yellow)
            bullet.strokeColor = .white
            bullet.position = player.position
            bullet.zPosition = 30
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: 4)
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = Mask.bullet
            bullet.physicsBody?.contactTestBitMask = Mask.enemy
            bullet.physicsBody?.collisionBitMask = 0
            world.addChild(bullet)
            let spreadTraining = max(0.4, 1 - CGFloat(trainingLevels[.accuracy, default: 0]) * 0.18)
            let spread = (CGFloat(index) - CGFloat(pelletCount - 1) / 2) * 0.07 * spreadTraining
            let angle = atan2(dy, dx) + spread
            let bulletSpeed = 680 + CGFloat(trainingLevels[.accuracy, default: 0]) * 45
            bullet.physicsBody?.velocity = CGVector(dx: cos(angle) * bulletSpeed, dy: sin(angle) * bulletSpeed)
            bullet.run(.sequence([.wait(forDuration: 1.3), .removeFromParent()]))
        }
        pulse(at: CGPoint(x: player.position.x + cos(player.zRotation) * 48, y: player.position.y + sin(player.zRotation) * 48), color: .systemOrange, radius: 17)
    }

    private func kick(now: TimeInterval) {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen, now - lastKick > 0.8 else { return }
        guard let target = nearestEnemy() else { return }
        let dx = target.position.x - player.position.x
        let dy = target.position.y - player.position.y
        let distance = max(1, hypot(dx, dy))
        guard distance < 105 else { showToast("距离太远，无法踢击", color: .systemOrange); return }
        lastKick = now
        let level = trainingLevels[.kick, default: 0]
        let damage = 2 + level * 2
        let push = CGFloat(42 + level * 18)
        target.position.x += dx / distance * push
        target.position.y += dy / distance * push
        hit(target, damage: damage)
        pulse(at: target.position, color: .systemOrange, radius: 38 + CGFloat(level) * 5)
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
            let defeatedHeavy = enemy.name == "enemyHeavy"
            if isCurePhase {
                convertToAlly(enemy)
            } else {
                enemy.removeFromParent()
            }
            kills += 1
            if defeatedHeavy {
                let reward = 20 + currentLevel * 6
                coins += reward
                showToast("击败重型丧尸：申城币 +\(reward)", color: .systemYellow)
            }
            updateHUD()
            checkLevelCompletion()
        }
    }

    private func checkLevelCompletion() {
        guard kills >= levels[currentLevel].enemies else { return }
        if currentLevel == 4 {
            showAntidoteTransition()
        } else if currentLevel < levels.count - 1 {
            currentLevel += 1
            kills = 0
            enemiesToSpawn = levels[currentLevel].enemies
            health = min(100, health + 12)
            coins += 15 + currentLevel * 3
            world.children.filter { $0.name?.hasPrefix("enemy") == true || $0.name == "airdrop" || $0.name?.hasPrefix("coinChest") == true }.forEach { $0.removeFromParent() }
            buildBackground()
            showToast("进入第 \(currentLevel + 1) 关 · 难度提升", color: .cyan)
            updateHUD()
            run(.sequence([.wait(forDuration: 1.4), .run { [weak self] in self?.spawnWave() }]))
        } else {
            winGame()
        }
    }

    private func showAntidoteTransition() {
        stopControls()
        gamePaused = true
        world.children.filter { $0.name?.hasPrefix("enemy") == true || $0.name == "airdrop" || $0.name?.hasPrefix("coinChest") == true }.forEach { $0.removeFromParent() }
        let panel = makePanel(name: "antidotePanel", size: CGSize(width: min(620, size.width - 60), height: 230), color: SKColor(red: 0.02, green: 0.12, blue: 0.14, alpha: 0.98), stroke: .cyan, z: 350)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "解药已取得"
        title.fontSize = 34
        title.fontColor = .cyan
        title.position.y = 58
        panel.addChild(title)
        let message = SKLabelNode(fontNamed: "AvenirNext-Regular")
        message.text = "危机尚未结束：净化感染者，让他们成为战友。"
        message.fontSize = 17
        message.position.y = 12
        panel.addChild(message)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "startCureMission"
        start.text = "携带解药，继续救援"
        start.fontSize = 20
        start.fontColor = .systemGreen
        start.position.y = -58
        panel.addChild(start)
    }

    private func startCureMission() {
        childNode(withName: "antidotePanel")?.removeFromParent()
        currentLevel = 5
        kills = 0
        enemiesToSpawn = levels[currentLevel].enemies
        health = min(100, health + 25)
        coins += 60
        gamePaused = false
        buildBackground()
        updateHUD()
        showToast("解药弹已装填：净化感染者并组建小队", color: .cyan)
        spawnWave()
    }

    private func convertToAlly(_ enemy: SKNode) {
        let position = enemy.position
        enemy.removeFromParent()
        pulse(at: position, color: .systemGreen, radius: 34)
        let ally = SKShapeNode(circleOfRadius: 19)
        ally.name = "ally"
        ally.position = position
        ally.zPosition = 18
        ally.fillColor = SKColor(white: 0.04, alpha: 0.95)
        ally.strokeColor = .systemGreen
        ally.lineWidth = 3
        let portrait = SKSpriteNode(texture: cachedTexture("player_survivor"))
        portrait.size = CGSize(width: 36, height: 36)
        portrait.zPosition = 1
        ally.addChild(portrait)
        let weaponAsset = allyWeaponLevel >= 3 ? "weapon_barrett" : (allyWeaponLevel == 2 ? "weapon_thompson" : (allyWeaponLevel == 1 ? "weapon_shotgun" : "weapon_pistol"))
        let gun = SKSpriteNode(texture: cachedTexture(weaponAsset))
        gun.name = "allyWeapon"
        gun.size = allyWeaponLevel >= 3 ? CGSize(width: 74, height: 25) : CGSize(width: 48, height: 25)
        gun.position = CGPoint(x: 29, y: -8)
        gun.zPosition = 3
        ally.addChild(gun)
        world.addChild(ally)
        showToast("净化成功：新战友已加入", color: .systemGreen)
    }

    private func updateAllies(_ currentTime: TimeInterval, delta: TimeInterval) {
        let squad = allies
        for (index, ally) in squad.enumerated() {
            let column = CGFloat(index % 4)
            let row = CGFloat(index / 4)
            let targetPosition = CGPoint(x: player.position.x - 58 - column * 34, y: player.position.y + 54 - row * 38)
            ally.position.x += (targetPosition.x - ally.position.x) * CGFloat(min(1, delta * 4.5))
            ally.position.y += (targetPosition.y - ally.position.y) * CGFloat(min(1, delta * 4.5))
        }
        let delays: [TimeInterval] = [1.0, 0.72, 0.24, 1.1]
        guard !squad.isEmpty, currentTime - lastAllyShot > delays[allyWeaponLevel], let target = nearestEnemy() else { return }
        lastAllyShot = currentTime
        let damages = [1, 2, 1, 6]
        for ally in squad.prefix(8) {
            let dx = target.position.x - ally.position.x
            let dy = target.position.y - ally.position.y
            let distance = max(1, hypot(dx, dy))
            ally.zRotation = atan2(dy, dx)
            let bullet = SKShapeNode(circleOfRadius: 3)
            bullet.name = "bullet"
            bullet.userData = ["damage": damages[allyWeaponLevel]]
            bullet.fillColor = .systemGreen
            bullet.strokeColor = .white
            bullet.position = ally.position
            bullet.zPosition = 30
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: 3)
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = Mask.bullet
            bullet.physicsBody?.contactTestBitMask = Mask.enemy
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.velocity = CGVector(dx: dx / distance * 620, dy: dy / distance * 620)
            world.addChild(bullet)
            bullet.run(.sequence([.wait(forDuration: 1.3), .removeFromParent()]))
        }
    }

    private func spawnAirdrop(for waveLevel: Int) {
        guard gameStarted, !gameEnded, currentLevel == waveLevel, world.childNode(withName: "airdrop") == nil else { return }
        let box = SKShapeNode(rectOf: CGSize(width: 58, height: 44), cornerRadius: 7)
        box.name = "airdrop"
        box.position = CGPoint(x: CGFloat.random(in: size.width * 0.55...size.width * 0.82), y: size.height + 40)
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
        var extra = ""
        if unlocked.contains(.thompson) {
            let thompson = Int.random(in: 18...32)
            ammo[.thompson, default: 0] += thompson
            extra += " 汤普森 +\(thompson)"
        }
        if unlocked.contains(.barrett) {
            let barrett = Int.random(in: 2...4)
            ammo[.barrett, default: 0] += barrett
            extra += " 巴雷特 +\(barrett)"
        }
        coins += reward
        pulse(at: box.position, color: .systemYellow, radius: 42)
        box.removeFromParent()
        updateHUD()
        showToast("空投：手枪 +\(pistol) 霰弹 +\(shotgun)\(extra) 币 +\(reward)", color: .systemYellow)
    }

    private func spawnCoinChest(for waveLevel: Int) {
        guard gameStarted, !gameEnded, currentLevel == waveLevel else { return }
        let chest = SKNode()
        let existingCount = world.children.filter { $0.name?.hasPrefix("coinChest") == true }.count
        chest.name = "coinChest_\(waveLevel)_\(existingCount)"
        chest.position = CGPoint(x: CGFloat.random(in: size.width * 0.52...size.width * 0.82), y: CGFloat.random(in: 112...size.height * 0.48))
        chest.zPosition = 24

        let glow = SKShapeNode(circleOfRadius: 34)
        glow.fillColor = .systemYellow
        glow.strokeColor = .clear
        glow.alpha = 0.16
        glow.run(.repeatForever(.sequence([.fadeAlpha(to: 0.36, duration: 0.65), .fadeAlpha(to: 0.12, duration: 0.65)])))
        chest.addChild(glow)

        let base = SKShapeNode(rectOf: CGSize(width: 58, height: 34), cornerRadius: 6)
        base.fillColor = SKColor(red: 0.34, green: 0.15, blue: 0.04, alpha: 1)
        base.strokeColor = .systemYellow
        base.lineWidth = 3
        chest.addChild(base)

        let lid = SKShapeNode(rectOf: CGSize(width: 62, height: 17), cornerRadius: 7)
        lid.position.y = 19
        lid.fillColor = SKColor(red: 0.48, green: 0.22, blue: 0.05, alpha: 1)
        lid.strokeColor = .systemYellow
        lid.lineWidth = 3
        chest.addChild(lid)

        let lock = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        lock.text = "¥"
        lock.fontSize = 22
        lock.fontColor = .systemYellow
        lock.verticalAlignmentMode = .center
        lock.position.y = -1
        chest.addChild(lock)
        world.addChild(chest)
        chest.run(.repeatForever(.sequence([.moveBy(x: 0, y: 4, duration: 0.55), .moveBy(x: 0, y: -4, duration: 0.55)])))
        showToast("发现金币宝箱，靠近即可开启", color: .systemYellow)
    }

    private func openCoinChest(_ chest: SKNode) {
        let reward = Int.random(in: (45 + currentLevel * 8)...(75 + currentLevel * 12))
        let position = chest.position
        chest.removeAllActions()
        chest.removeFromParent()
        coins += reward
        pulse(at: position, color: .systemYellow, radius: 48)
        for index in 0..<6 {
            let coin = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            coin.text = "●"
            coin.fontSize = 16
            coin.fontColor = .systemYellow
            coin.position = position
            coin.zPosition = 35
            world.addChild(coin)
            let angle = CGFloat(index) * .pi / 3
            let destination = CGPoint(x: position.x + cos(angle) * 48, y: position.y + sin(angle) * 34 + 18)
            coin.run(.sequence([.group([.move(to: destination, duration: 0.35), .fadeOut(withDuration: 0.55)]), .removeFromParent()]))
        }
        updateHUD()
        showToast("金币宝箱：申城币 +\(reward)", color: .systemYellow)
    }

    private func updateHUD() {
        hpLabel.text = "生命 \(max(0, health)) · 盔\(helmetLevel) 甲\(vestLevel)"
        levelLabel.text = "第 \(currentLevel + 1)/7 关 · \(levels[currentLevel].name)"
        let weaponPrefix = isCurePhase ? "解药·" : ""
        weaponLabel.text = "\(weaponPrefix)\(weapon.name) · \(weapon == .axe ? "∞" : String(ammo[weapon, default: 0]))"
        coinLabel.text = "申城币 \(coins)"
        missionLabel.text = isCurePhase ? "任务 · 净化 \(kills)/\(levels[currentLevel].enemies) · 战友 \(allies.count)" : "任务 · 清除感染者 \(kills)/\(levels[currentLevel].enemies)"
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
        if trainingOpen { closeTraining() }
        shopOpen = true
        stopControls()
        let panel = makePanel(name: "shopPanel", size: CGSize(width: min(540, size.width - 80), height: 370), color: SKColor(white: 0.025, alpha: 0.97), stroke: .systemYellow, z: 300)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "幸存者装备站 · \(coins) 币"
        title.fontSize = 23
        title.position.y = 158
        panel.addChild(title)
        addShopItem(to: panel, weapon: .shotgun, position: CGPoint(x: -128, y: 113))
        addShopItem(to: panel, weapon: .axe, position: CGPoint(x: 128, y: 113))
        addShopItem(to: panel, weapon: .thompson, position: CGPoint(x: -128, y: 68))
        addShopItem(to: panel, weapon: .barrett, position: CGPoint(x: 128, y: 68))
        for (index, item) in [Weapon.pistol, .shotgun, .thompson, .barrett].enumerated() {
            addAmmoItem(to: panel, weapon: item, position: CGPoint(x: CGFloat(index) * 126 - 189, y: 18))
        }
        if isCurePhase {
            addAllyWeaponItem(to: panel)
        } else {
            for level in 1...3 {
                let x = CGFloat(level - 2) * 168
                addArmorItem(to: panel, kind: .helmet, level: level, position: CGPoint(x: x, y: -42))
                addArmorItem(to: panel, kind: .vest, level: level, position: CGPoint(x: x, y: -112))
            }
        }
        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.name = "closeShop"
        close.text = "关闭"
        close.fontSize = 17
        close.position.y = -174
        panel.addChild(close)
    }

    private func ammoPack(for item: Weapon) -> (count: Int, price: Int) {
        switch item {
        case .pistol: return (20, 15)
        case .shotgun: return (8, 22)
        case .thompson: return (40, 30)
        case .barrett: return (5, 35)
        case .axe: return (0, 0)
        }
    }

    private func addAmmoItem(to panel: SKNode, weapon item: Weapon, position: CGPoint) {
        let available = unlocked.contains(item)
        let pack = ammoPack(for: item)
        let name = available ? "buyAmmo_\(item.rawValue)" : "ammoLocked"
        let button = SKShapeNode(rectOf: CGSize(width: 116, height: 40), cornerRadius: 8)
        button.name = name
        button.position = position
        button.fillColor = available ? SKColor(red: 0.16, green: 0.12, blue: 0.03, alpha: 1) : .darkGray
        button.strokeColor = available ? .systemYellow : .gray
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.numberOfLines = 2
        label.fontSize = 11
        label.verticalAlignmentMode = .center
        label.text = available ? "\(item.name)弹药 +\(pack.count)\n\(pack.price)币 · 现有\(ammo[item, default: 0])" : "\(item.name)弹药\n尚未解锁"
        button.addChild(label)
    }

    private func buyAmmo(for item: Weapon) {
        guard unlocked.contains(item), item != .axe else { showToast("请先解锁该武器", color: .systemOrange); return }
        let pack = ammoPack(for: item)
        guard coins >= pack.price else { showToast("申城币不足，寻找金币宝箱", color: .systemRed); return }
        coins -= pack.price
        ammo[item, default: 0] += pack.count
        updateHUD()
        refreshShop()
        showToast("\(item.name)弹药 +\(pack.count)", color: .systemYellow)
    }

    private func addAllyWeaponItem(to panel: SKNode) {
        let names = ["手枪", "霰弹枪", "汤普森", "巴雷特"]
        let prices = [0, 80, 150, 240]
        let maxed = allyWeaponLevel >= 3
        let next = min(3, allyWeaponLevel + 1)
        let button = SKShapeNode(rectOf: CGSize(width: 430, height: 68), cornerRadius: 10)
        button.name = maxed ? "allyWeaponMax" : "buyAllyWeapon"
        button.position.y = -78
        button.fillColor = maxed ? .darkGray : SKColor(red: 0.07, green: 0.22, blue: 0.13, alpha: 1)
        button.strokeColor = .systemGreen
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = button.name
        label.text = maxed ? "战友武器：巴雷特 · 已满级" : "战友武器：\(names[allyWeaponLevel]) → \(names[next]) · \(prices[next]) 币"
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func buyAllyWeapon() {
        let prices = [0, 80, 150, 240]
        guard allyWeaponLevel < 3 else { return }
        let next = allyWeaponLevel + 1
        guard coins >= prices[next] else { showToast("申城币不足，继续救援", color: .systemRed); return }
        coins -= prices[next]
        allyWeaponLevel = next
        for ally in allies {
            let gun = ally.childNode(withName: "allyWeapon") as? SKSpriteNode
            gun?.texture = cachedTexture(next >= 3 ? "weapon_barrett" : (next == 2 ? "weapon_thompson" : "weapon_shotgun"))
            gun?.size = next >= 3 ? CGSize(width: 74, height: 25) : CGSize(width: 55, height: 25)
        }
        updateHUD()
        refreshShop()
        showToast("战友武器已升级", color: .systemGreen)
    }

    private func addArmorItem(to panel: SKNode, kind: ArmorKind, level: Int, position: CGPoint) {
        let current = kind == .helmet ? helmetLevel : vestLevel
        let owned = level <= current
        let available = level == current + 1
        let name = available ? "buy_armor_\(kind.rawValue)_\(level)" : "armor_locked"
        let card = SKShapeNode(rectOf: CGSize(width: 154, height: 66), cornerRadius: 9)
        card.name = name
        card.position = position
        card.fillColor = owned ? .darkGray : SKColor(red: 0.06, green: 0.13, blue: 0.17, alpha: 1)
        card.strokeColor = owned ? .gray : (available ? .systemYellow : .darkGray)
        panel.addChild(card)

        let icon = SKSpriteNode(texture: cachedTexture("\(kind.rawValue)_level\(level)"))
        icon.name = name
        icon.size = CGSize(width: 54, height: 54)
        icon.position.x = -46
        card.addChild(icon)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = owned ? "\(kind.name)\(level)级\n已装备" : (available ? "\(kind.name)\(level)级\n\(kind.prices[level])币" : "\(kind.name)\(level)级\n需前一级")
        label.numberOfLines = 2
        label.fontSize = 12
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position.x = -10
        card.addChild(label)
    }

    private func buyArmor(kind: ArmorKind, level: Int) {
        let current = kind == .helmet ? helmetLevel : vestLevel
        guard level == current + 1 else { showToast("请按等级顺序升级装备", color: .systemOrange); return }
        let price = kind.prices[level]
        guard coins >= price else { showToast("申城币不足，继续搜寻空投", color: .systemRed); return }
        coins -= price
        if kind == .helmet { helmetLevel = level } else { vestLevel = level }
        updateArmorGraphics()
        updateHUD()
        refreshShop()
        showToast("已装备\(level)级\(kind.name)", color: .cyan)
    }

    private func updateArmorGraphics() {
        helmetSprite?.isHidden = helmetLevel == 0
        vestSprite?.isHidden = vestLevel == 0
        if helmetLevel > 0 { helmetSprite?.texture = cachedTexture("helmet_level\(helmetLevel)") }
        if vestLevel > 0 { vestSprite?.texture = cachedTexture("vest_level\(vestLevel)") }
    }

    private func addShopItem(to panel: SKNode, weapon item: Weapon, position: CGPoint) {
        let owned = unlocked.contains(item)
        let button = SKShapeNode(rectOf: CGSize(width: 240, height: 42), cornerRadius: 9)
        button.name = owned ? "owned" : "buy_\(item.rawValue)"
        button.position = position
        button.fillColor = owned ? .darkGray : SKColor(red: 0.08, green: 0.24, blue: 0.27, alpha: 1)
        button.strokeColor = owned ? .gray : .cyan
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = button.name
        label.text = owned ? "\(item.name) · 已拥有" : "解锁 \(item.name) · \(item.price) 币"
        label.fontSize = 14
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func buyWeapon(_ item: Weapon) {
        guard !unlocked.contains(item) else { return }
        guard coins >= item.price else { showToast("申城币不足，继续搜寻空投和宝箱", color: .systemRed); return }
        coins -= item.price
        unlocked.insert(item)
        weapon = item
        switch item {
        case .shotgun: ammo[.shotgun, default: 0] += 5
        case .thompson: ammo[.thompson, default: 0] += 45
        case .barrett: ammo[.barrett, default: 0] += 8
        default: break
        }
        updateWeaponGraphic()
        updateHUD()
        refreshShop()
        showToast("已解锁 \(item.name)", color: .cyan)
    }

    private func closeShop() {
        childNode(withName: "shopPanel")?.removeFromParent()
        shopOpen = false
    }

    private func refreshShop() {
        childNode(withName: "shopPanel")?.removeFromParent()
        shopOpen = false
        showShop()
    }

    private func showTraining() {
        guard gameStarted, !gameEnded else { return }
        if trainingOpen { closeTraining(); return }
        if shopOpen { closeShop() }
        trainingOpen = true
        stopControls()
        let panel = makePanel(name: "trainingPanel", size: CGSize(width: min(500, size.width - 90), height: 300), color: SKColor(red: 0.025, green: 0.10, blue: 0.08, alpha: 0.98), stroke: .systemGreen, z: 310)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "幸存者训练 · \(coins) 币"
        title.fontSize = 25
        title.position.y = 112
        panel.addChild(title)
        for (index, item) in Training.allCases.enumerated() {
            addTrainingItem(to: panel, training: item, y: CGFloat(55 - index * 65))
        }
        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.name = "closeTraining"
        close.text = "关闭"
        close.fontSize = 17
        close.position.y = -130
        panel.addChild(close)
    }

    private func addTrainingItem(to panel: SKNode, training item: Training, y: CGFloat) {
        let level = trainingLevels[item, default: 0]
        let maxed = level >= 3
        let price = [0, 45, 85, 140][min(3, level + 1)]
        let name = maxed ? "trainingMax" : "train_\(item.rawValue)"
        let button = SKShapeNode(rectOf: CGSize(width: 410, height: 54), cornerRadius: 10)
        button.name = name
        button.position.y = y
        button.fillColor = maxed ? .darkGray : SKColor(red: 0.04, green: 0.19, blue: 0.13, alpha: 1)
        button.strokeColor = maxed ? .gray : .systemGreen
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.numberOfLines = 2
        label.fontSize = 14
        label.verticalAlignmentMode = .center
        label.text = maxed ? "\(item.name) · 3级（已满）\n\(item.detail)" : "\(item.name) · \(level)级 → \(level + 1)级 · \(price)币\n\(item.detail)"
        button.addChild(label)
    }

    private func buyTraining(_ item: Training) {
        let level = trainingLevels[item, default: 0]
        guard level < 3 else { return }
        let price = [0, 45, 85, 140][level + 1]
        guard coins >= price else { showToast("申城币不足，寻找宝箱或重型丧尸", color: .systemRed); return }
        coins -= price
        trainingLevels[item] = level + 1
        updateHUD()
        childNode(withName: "trainingPanel")?.removeFromParent()
        trainingOpen = false
        showTraining()
        showToast("\(item.name)训练提升至 \(level + 1) 级", color: .systemGreen)
    }

    private func closeTraining() {
        childNode(withName: "trainingPanel")?.removeFromParent()
        trainingOpen = false
    }

    private func showSettings() {
        guard gameStarted else { return }
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
        if !gameEnded {
            addMenuButton(to: panel, name: "resumeGame", text: "继续行动", y: 20, color: .systemTeal)
        }
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
        title.text = "解药已取得，请继续净化"
        title.fontSize = 36
        title.fontColor = .cyan
        title.position.y = 52
        panel.addChild(title)
        let message = SKLabelNode(fontNamed: "AvenirNext-Regular")
        message.text = "感染者恢复成人类，幸存者小队守住了上海谢谢你。"
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
        guard gameStarted, !gameEnded, !shopOpen, !trainingOpen, !gamePaused else { return }
        playerPortrait?.zRotation = -player.zRotation
        helmetSprite?.zRotation = -player.zRotation
        vestSprite?.zRotation = -player.zRotation
        let moving = abs(moveVector.dx) + abs(moveVector.dy) > 0.08
        let playerStride = moving ? CGFloat(sin(currentTime * 9)) * 0.34 : 0
        player.childNode(withName: "playerArmLeft")?.zRotation = playerStride
        player.childNode(withName: "playerArmRight")?.zRotation = -playerStride
        player.childNode(withName: "playerLegLeft")?.zRotation = -playerStride * 0.72
        player.childNode(withName: "playerLegRight")?.zRotation = playerStride * 0.72
        let movementSpeed = 220 + CGFloat(trainingLevels[.speed, default: 0]) * 28
        player.position.x = max(35, min(size.width - 35, player.position.x + moveVector.dx * movementSpeed * delta))
        player.position.y = max(108, min(size.height * 0.61, player.position.y + moveVector.dy * movementSpeed * delta))
        for enemy in world.children where enemy.name?.hasPrefix("enemy") == true {
            let dx = player.position.x - enemy.position.x
            let dy = player.position.y - enemy.position.y
            let distance = max(1, hypot(dx, dy))
            let base: CGFloat
            switch enemy.name {
            case "enemyHeavy": base = 50
            case "enemyRunner": base = 132
            default: base = 74
            }
            let speed = base + levels[currentLevel].speedBonus
            enemy.position.x += dx / distance * speed * delta
            enemy.position.y += dy / distance * speed * delta
            let strideRate: Double = enemy.name == "enemyHeavy" ? 4.2 : (enemy.name == "enemyRunner" ? 10.5 : 5.4)
            let stagger = CGFloat(sin(currentTime * strideRate + Double(enemy.position.x) * 0.018))
            enemy.childNode(withName: "enemyArmLeft")?.zRotation = -0.38 + stagger * 0.18
            enemy.childNode(withName: "enemyArmRight")?.zRotation = 0.25 - stagger * 0.24
            enemy.childNode(withName: "enemyLegLeft")?.zRotation = stagger * 0.24
            enemy.childNode(withName: "enemyLegRight")?.zRotation = -stagger * 0.24
        }
        if isCurePhase { updateAllies(currentTime, delta: delta) }
        if let box = world.childNode(withName: "airdrop"), hypot(box.position.x - player.position.x, box.position.y - player.position.y) < 62 { openAirdrop(box) }
        if let chest = world.children.first(where: { $0.name?.hasPrefix("coinChest") == true && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < 66 }) { openCoinChest(chest) }
        if fireTouch != nil { fire(now: currentTime) }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let first = contact.bodyA.node
        let second = contact.bodyB.node
        if first?.name == "bullet", let enemy = second, enemy.name?.hasPrefix("enemy") == true {
            let damage = first?.userData?["damage"] as? Int ?? 1
            first?.removeFromParent(); hit(enemy, damage: damage)
        } else if second?.name == "bullet", let enemy = first, enemy.name?.hasPrefix("enemy") == true {
            let damage = second?.userData?["damage"] as? Int ?? 1
            second?.removeFromParent(); hit(enemy, damage: damage)
        } else if first === player || second === player {
            let enemy = first === player ? second : first
            if enemy?.name?.hasPrefix("enemy") == true {
                let reduction = helmetLevel + vestLevel
                health -= max(2, 8 - reduction)
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
            if names.contains("startCureMission") { startCureMission(); continue }
            if names.contains("resumeGame") { resumeGame(); continue }
            if names.contains("restartGame") { restartGame(); continue }
            if names.contains("settings") { showSettings(); continue }
            if names.contains("closeTraining") { closeTraining(); continue }
            if names.contains("training") { showTraining(); continue }
            if let trainingName = names.first(where: { $0.hasPrefix("train_") }), let item = Training(rawValue: trainingName.replacingOccurrences(of: "train_", with: "")) {
                buyTraining(item)
                continue
            }
            if gameEnded { continue }
            if settingsOpen { continue }
            if trainingOpen { continue }
            if !gameStarted, hitNodes.contains(where: { $0.name == "start" || $0.parent?.name == "intro" }) {
                childNode(withName: "intro")?.removeFromParent()
                gameStarted = true
                spawnWave()
                continue
            }
            if let ammoName = names.first(where: { $0.hasPrefix("buyAmmo_") }), let raw = Int(ammoName.replacingOccurrences(of: "buyAmmo_", with: "")), let item = Weapon(rawValue: raw) {
                buyAmmo(for: item)
                continue
            }
            if let buyName = names.first(where: { $0.hasPrefix("buy_") }), let raw = Int(buyName.replacingOccurrences(of: "buy_", with: "")), let item = Weapon(rawValue: raw) {
                buyWeapon(item)
                continue
            }
            if names.contains("buyAllyWeapon") { buyAllyWeapon(); continue }
            if let armorName = names.first(where: { $0.hasPrefix("buy_armor_") }) {
                let parts = armorName.split(separator: "_")
                if parts.count == 4, let kind = ArmorKind(rawValue: String(parts[2])), let level = Int(parts[3]) {
                    buyArmor(kind: kind, level: level)
                }
                continue
            }
            if names.contains("closeShop") { closeShop(); continue }
            if names.contains("shop") { showShop(); continue }
            if shopOpen { continue }
            if names.contains("kick") {
                kick(now: lastUpdate)
            } else if names.contains("switch") {
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
