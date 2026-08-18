import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private static var preloadedTextureCache: [String: SKTexture] = [:]

    static func preloadGameAssets(progress: @escaping (Double, String) -> Void, completion: @escaping () -> Void) {
        let groups: [(String, [String])] = [
            ("正在载入行动区域", ["level01"]),
            ("正在载入幸存者", ["player_survivor"]),
            ("正在载入初始装备", ["weapon_pistol", "helmet_level1", "vest_level1"])
        ]

        let assets = groups.flatMap { group in group.1.map { (group.0, $0) } }
        func loadAsset(_ index: Int) {
            guard index < assets.count else {
                progress(1, "准备进入行动")
                completion()
                return
            }
            let asset = assets[index]
            progress(Double(index) / Double(assets.count), asset.0)
            let texture = SKTexture(imageNamed: asset.1)
            texture.filteringMode = .linear
            preloadedTextureCache[asset.1] = texture
            // 每个资源让出一次主线程，使进度条持续刷新；不依赖尚未建立的 SKView 回调。
            DispatchQueue.main.async {
                progress(Double(index + 1) / Double(assets.count), asset.0)
                loadAsset(index + 1)
            }
        }

        loadAsset(0)
    }

    private struct AccountProfile: Codable {
        var id: String
        var name: String
        var level: Int
        var experience: Int
        var reputation: Int
        var specialWeaponFragments: Int
        var weaponTechnicians: Int
        var jetpackUnlocked: Bool
        var jetpackBatteries: Int
        var laserUnlocked: Bool
        var ionCannonUnlocked: Bool
        var plasmaBladeUnlocked: Bool
        var powerHelmetUnlocked: Bool
        var powerArmorUnlocked: Bool
        var vehicleUnlocked: Bool
        var dieselCanisters: Int
        var helicopterUnlocked: Bool
        var aviationFuelCanisters: Int
        var tankUnlocked: Bool
        var hovercraftUnlocked: Bool
        var totalKills: Int
        var totalModeClears: Int
        var lastActivityClaimDate: String
        var claimedMissionRewards: [String]
        var bossMedalUnlocked: Bool
        var activityClaimCount: Int
        var collectibleItems: [String]
        var defenseModeClears: Int
        var bossDefeats: Int

        init(id: String, name: String, level: Int, experience: Int, reputation: Int = 0, specialWeaponFragments: Int = 0, weaponTechnicians: Int = 0, jetpackUnlocked: Bool = false, jetpackBatteries: Int = 0, laserUnlocked: Bool = false, ionCannonUnlocked: Bool = false, plasmaBladeUnlocked: Bool = false, powerHelmetUnlocked: Bool = false, powerArmorUnlocked: Bool = false, vehicleUnlocked: Bool = false, dieselCanisters: Int = 0, helicopterUnlocked: Bool = false, aviationFuelCanisters: Int = 0, tankUnlocked: Bool = false, hovercraftUnlocked: Bool = false, totalKills: Int = 0, totalModeClears: Int = 0, lastActivityClaimDate: String = "", claimedMissionRewards: [String] = [], bossMedalUnlocked: Bool = false, activityClaimCount: Int = 0, collectibleItems: [String] = [], defenseModeClears: Int = 0, bossDefeats: Int = 0) {
            self.id = id
            self.name = name
            self.level = level
            self.experience = experience
            self.reputation = reputation
            self.specialWeaponFragments = specialWeaponFragments
            self.weaponTechnicians = weaponTechnicians
            self.jetpackUnlocked = jetpackUnlocked
            self.jetpackBatteries = jetpackBatteries
            self.laserUnlocked = laserUnlocked
            self.ionCannonUnlocked = ionCannonUnlocked
            self.plasmaBladeUnlocked = plasmaBladeUnlocked
            self.powerHelmetUnlocked = powerHelmetUnlocked
            self.powerArmorUnlocked = powerArmorUnlocked
            self.vehicleUnlocked = vehicleUnlocked
            self.dieselCanisters = dieselCanisters
            self.helicopterUnlocked = helicopterUnlocked
            self.aviationFuelCanisters = aviationFuelCanisters
            self.tankUnlocked = tankUnlocked
            self.hovercraftUnlocked = hovercraftUnlocked
            self.totalKills = totalKills
            self.totalModeClears = totalModeClears
            self.lastActivityClaimDate = lastActivityClaimDate
            self.claimedMissionRewards = claimedMissionRewards
            self.bossMedalUnlocked = bossMedalUnlocked
            self.activityClaimCount = activityClaimCount
            self.collectibleItems = collectibleItems
            self.defenseModeClears = defenseModeClears
            self.bossDefeats = bossDefeats
        }

        private enum CodingKeys: String, CodingKey { case id, name, level, experience, reputation, specialWeaponFragments, weaponTechnicians, jetpackUnlocked, jetpackBatteries, laserUnlocked, ionCannonUnlocked, plasmaBladeUnlocked, powerHelmetUnlocked, powerArmorUnlocked, vehicleUnlocked, dieselCanisters, helicopterUnlocked, aviationFuelCanisters, tankUnlocked, hovercraftUnlocked, totalKills, totalModeClears, lastActivityClaimDate, claimedMissionRewards, bossMedalUnlocked, activityClaimCount, collectibleItems, defenseModeClears, bossDefeats }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            level = try values.decode(Int.self, forKey: .level)
            experience = try values.decode(Int.self, forKey: .experience)
            reputation = try values.decodeIfPresent(Int.self, forKey: .reputation) ?? 0
            specialWeaponFragments = try values.decodeIfPresent(Int.self, forKey: .specialWeaponFragments) ?? 0
            weaponTechnicians = try values.decodeIfPresent(Int.self, forKey: .weaponTechnicians) ?? 0
            jetpackUnlocked = try values.decodeIfPresent(Bool.self, forKey: .jetpackUnlocked) ?? false
            jetpackBatteries = try values.decodeIfPresent(Int.self, forKey: .jetpackBatteries) ?? 0
            laserUnlocked = try values.decodeIfPresent(Bool.self, forKey: .laserUnlocked) ?? false
            ionCannonUnlocked = try values.decodeIfPresent(Bool.self, forKey: .ionCannonUnlocked) ?? false
            plasmaBladeUnlocked = try values.decodeIfPresent(Bool.self, forKey: .plasmaBladeUnlocked) ?? false
            powerHelmetUnlocked = try values.decodeIfPresent(Bool.self, forKey: .powerHelmetUnlocked) ?? false
            powerArmorUnlocked = try values.decodeIfPresent(Bool.self, forKey: .powerArmorUnlocked) ?? false
            vehicleUnlocked = try values.decodeIfPresent(Bool.self, forKey: .vehicleUnlocked) ?? false
            dieselCanisters = try values.decodeIfPresent(Int.self, forKey: .dieselCanisters) ?? 0
            helicopterUnlocked = try values.decodeIfPresent(Bool.self, forKey: .helicopterUnlocked) ?? false
            aviationFuelCanisters = try values.decodeIfPresent(Int.self, forKey: .aviationFuelCanisters) ?? 0
            tankUnlocked = try values.decodeIfPresent(Bool.self, forKey: .tankUnlocked) ?? false
            hovercraftUnlocked = try values.decodeIfPresent(Bool.self, forKey: .hovercraftUnlocked) ?? false
            totalKills = try values.decodeIfPresent(Int.self, forKey: .totalKills) ?? 0
            totalModeClears = try values.decodeIfPresent(Int.self, forKey: .totalModeClears) ?? 0
            lastActivityClaimDate = try values.decodeIfPresent(String.self, forKey: .lastActivityClaimDate) ?? ""
            claimedMissionRewards = try values.decodeIfPresent([String].self, forKey: .claimedMissionRewards) ?? []
            bossMedalUnlocked = try values.decodeIfPresent(Bool.self, forKey: .bossMedalUnlocked) ?? false
            activityClaimCount = try values.decodeIfPresent(Int.self, forKey: .activityClaimCount) ?? 0
            collectibleItems = try values.decodeIfPresent([String].self, forKey: .collectibleItems) ?? []
            defenseModeClears = try values.decodeIfPresent(Int.self, forKey: .defenseModeClears) ?? 0
            bossDefeats = try values.decodeIfPresent(Int.self, forKey: .bossDefeats) ?? 0
        }
    }

    private enum GameMode {
        case task, survival, defense, melee, mech
    }

    private enum Mask {
        static let player: UInt32 = 1
        static let enemy: UInt32 = 2
        static let bullet: UInt32 = 4
    }

    private enum Weapon: Int, CaseIterable, Hashable {
        case pistol, shotgun, axe, thompson, barrett, rpg, machete, katana, throwingKnife, boomerang, laserEmitter, ionCannon, plasmaBlade
        var name: String { ["手枪", "s1897霰弹枪", "消防斧", "汤普森冲锋枪", "巴雷特狙击枪", "RPG火箭炮", "开山砍刀", "武士刀", "飞刀", "回旋镖", "激光发射器", "离子炮", "等离子大刀"][rawValue] }
        var asset: String { ["weapon_pistol", "weapon_shotgun", "weapon_axe", "weapon_thompson", "weapon_barrett", "weapon_rpg", "weapon_machete", "weapon_katana", "", "", "", "", ""][rawValue] }
        var price: Int { [0, 60, 100, 140, 220, 320, 70, 180, 110, 240, 0, 0, 0][rawValue] }
        var shotDelay: TimeInterval { [0.28, 0.72, 0.55, 0.10, 1.25, 1.65, 0.42, 0.58, 0.48, 1.05, 0.35, 0.50, 0.28][rawValue] }
        var damage: Int { [1, 1, 3, 1, 7, 6, 3, 5, 3, 4, 10, 16, 12][rawValue] }
        var requiredLevel: Int { [1, 2, 4, 3, 5, 10, 4, 5, 4, 5, 1, 1, 1][rawValue] }
        var isMelee: Bool { self == .axe || self == .machete || self == .katana || self == .plasmaBlade }
        var isThrownMelee: Bool { self == .throwingKnife || self == .boomerang }
        var isEnergyWeapon: Bool { self == .laserEmitter || self == .ionCannon }
    }

    private enum ArmorKind: String {
        case helmet, vest
        var name: String { self == .helmet ? "头盔" : "防弹衣" }
        var prices: [Int] { self == .helmet ? [0, 35, 70, 120, 180, 260] : [0, 45, 90, 150, 230, 330] }
        var reductions: [Double] { self == .helmet ? [0, 0.06, 0.12, 0.18, 0.24, 0.30] : [0, 0.10, 0.20, 0.32, 0.40, 0.50] }
    }

    private enum Training: String, CaseIterable, Hashable {
        case speed, accuracy, kick, resistance, explosive
        var name: String { ["速度", "枪法", "踢击力量", "抗性", "爆发力"][Training.allCases.firstIndex(of: self)!] }
        var detail: String { ["移动速度提升", "提高弹速与暴击率", "提高踢击伤害与击退", "每级生命上限提高25", "敌群包围时触发速度爆发"][Training.allCases.firstIndex(of: self)!] }
    }

    private struct Level {
        let name: String
        let enemies: Int
        let speedBonus: CGFloat
    }

    private let levels = [
        Level(name: "南京东路", enemies: 10, speedBonus: 0),
        Level(name: "武康路", enemies: 8, speedBonus: 5),
        Level(name: "徐家汇", enemies: 10, speedBonus: 10),
        Level(name: "外滩", enemies: 12, speedBonus: 16),
        Level(name: "上海中心顶层", enemies: 14, speedBonus: 23),
        Level(name: "陆家嘴疏散区", enemies: 12, speedBonus: 27),
        Level(name: "上海中心救援站", enemies: 16, speedBonus: 32)
    ]
    private let waterLevels = [
        Level(name: "黄浦江航道", enemies: 14, speedBonus: 18),
        Level(name: "长江口船队", enemies: 18, speedBonus: 25),
        Level(name: "东海撤离线", enemies: 22, speedBonus: 32),
        Level(name: "海上终极巢穴·暴君", enemies: 1, speedBonus: 38)
    ]
    private let transitionDelay: TimeInterval = 3.0
    private let trainingPrices = [0, 45, 85, 140, 210, 300]

    private let world = SKNode()
    private let scenery = SKNode()
    private var textureCache: [String: SKTexture] = [:]
    private let player = SKShapeNode(circleOfRadius: 24)
    private var playerPortrait: SKSpriteNode?
    private var weaponSprite: SKNode?
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
    private let grenadeButton = SKShapeNode(circleOfRadius: 30)
    private let airstrikeButton = SKShapeNode(circleOfRadius: 30)
    private let torpedoButton = SKShapeNode(circleOfRadius: 30)
    private let vehicleButton = SKShapeNode(circleOfRadius: 30)
    private let helicopterButton = SKShapeNode(circleOfRadius: 30)
    private let tankButton = SKShapeNode(circleOfRadius: 30)
    private let hovercraftButton = SKShapeNode(circleOfRadius: 30)
    private let trapButton = SKShapeNode(circleOfRadius: 30)
    private let medicalButton = SKShapeNode(circleOfRadius: 30)
    private let stimulantButton = SKShapeNode(circleOfRadius: 30)
    private let jetpackButton = SKShapeNode(circleOfRadius: 30)
    private let settingsButton = SKShapeNode(circleOfRadius: 28)
    private let repairButton = SKShapeNode(circleOfRadius: 28)
    private let pistolSound = SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)
    private let shotgunSound = SKAction.playSoundFileNamed("shotgun.wav", waitForCompletion: false)
    private let thompsonSound = SKAction.playSoundFileNamed("thompson.wav", waitForCompletion: false)
    private let barrettSound = SKAction.playSoundFileNamed("barrett.wav", waitForCompletion: false)
    private let kickSound = SKAction.playSoundFileNamed("kick.wav", waitForCompletion: false)
    private let zombieCrySound = SKAction.playSoundFileNamed("zombie_cry.wav", waitForCompletion: false)
    private let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    private weak var backgroundMusicNode: SKAudioNode?
    private var backgroundMusicName = ""

    private var joystickTouch: UITouch?
    private var fireTouch: UITouch?
    private var firePressStartedAt: TimeInterval = 0
    private var plasmaUltimateTriggered = false
    private var trapPlacementTouch: UITouch?
    private var grenadePlacementTouch: UITouch?
    private weak var trapPlacementGhost: SKNode?
    private weak var grenadePlacementGhost: SKNode?
    private weak var airstrikePlacementGhost: SKNode?
    private var moveVector = CGVector.zero
    private var lastUpdate: TimeInterval = 0
    private var lastShot: TimeInterval = 0
    private var lastAllyShot: TimeInterval = 0
    private var lastKick: TimeInterval = 0
    private var lastZombieCry: TimeInterval = 0
    private var lastBossShock: TimeInterval = 0
    private var lastBossSummon: TimeInterval = 0
    private var bossDefeated = false
    private var isKicking = false
    private var trapSerial = 0

    private var health = 100
    private var damageTowardNextBloodStain = 0
    private var playerBloodStainCount = 0
    private var gameMode: GameMode = .task
    private var kills = 0
    private var currentLevel = 0
    private var taskChapter = 1
    private var pendingWaterLevel = 0
    private var taskWave = 1
    private var enemiesToSpawn = 6
    private var survivalWave = 1
    private var survivalTarget = 6
    private var defenseFort = 1
    private var defenseWave = 1
    private var defenseTarget = 7
    private var defenseResolved = 0
    private var fortHealth = 100
    private var turretCount = 0
    private var defenseSoldierCount = 0
    private var lastDefenseShot: TimeInterval = 0
    private var weapon: Weapon = .pistol
    private var ammo: [Weapon: Int] = [.pistol: 24, .shotgun: 0, .thompson: 0, .barrett: 0, .rpg: 0]
    private var unlocked: Set<Weapon> = [.pistol]
    private var coins = 0
    private var helmetLevel = 0
    private var vestLevel = 0
    private var allyWeaponLevel = 0
    private var trainingLevels: [Training: Int] = [.speed: 0, .accuracy: 0, .kick: 0, .resistance: 0, .explosive: 0]
    private var grenades = 1
    private var airstrikes = 0
    private var torpedoes = 0
    private var vehicleActive = false
    private var vehicleFuelRemaining: TimeInterval = 0
    private var lastVehicleImpact: TimeInterval = 0
    private weak var vehicleBody: SKNode?
    private var helicopterActive = false
    private var helicopterFuelRemaining: TimeInterval = 0
    private var lastHelicopterAttack: TimeInterval = 0
    private weak var helicopterBody: SKNode?
    private var tankActive = false
    private var tankFuelRemaining: TimeInterval = 0
    private var lastTankShot: TimeInterval = 0
    private weak var tankBody: SKNode?
    private var hovercraftActive = false
    private var hovercraftFuelRemaining: TimeInterval = 0
    private var lastHovercraftShot: TimeInterval = 0
    private var hovercraftBarrelSide: CGFloat = -1
    private weak var hovercraftBody: SKNode?
    private var traps = 1
    private var medicalKits = 1
    private var stimulantShots = 1
    private var stimulantRemaining: TimeInterval = 0
    private var jetpackActive = false
    private var jetpackBatteryRemaining: TimeInterval = 0
    private var jetpackBurstsRemaining = 0
    private var jetpackWarnedAtEight = false
    private var jetpackWarnedAtThree = false
    private weak var jetpackFlame: SKNode?
    private var laserCharge: TimeInterval = 1
    private var ionCharge: TimeInterval = 1
    private var plasmaBladeCharge: TimeInterval = 1
    private var powerHelmetCharge: TimeInterval = 1
    private var powerArmorCharge: TimeInterval = 1
    private var explosiveActive = false
    private var repairCooldownRemaining: TimeInterval = 0

    private var isWaterChapter: Bool { gameMode == .task && taskChapter == 2 }
    private var isBossLevel: Bool { gameMode == .task && taskChapter == 2 && currentLevel == waterLevels.count - 1 }
    private var isCurePhase: Bool { gameMode == .task && taskChapter == 1 && currentLevel >= 5 }
    private var usesSurvivalWaves: Bool { gameMode == .survival || gameMode == .melee || gameMode == .mech }
    private var objectiveCount: Int {
        switch gameMode {
        case .task: return isWaterChapter ? waterLevels[currentLevel].enemies : levels[currentLevel].enemies
        case .survival, .melee, .mech: return survivalTarget
        case .defense: return defenseTarget
        }
    }
    private var allies: [SKNode] { world.children.filter { $0.name == "ally" } }
    private var armorDamageReduction: Double {
        let powered = (activeAccount.powerHelmetUnlocked && powerHelmetCharge > 0 ? 0.12 : 0) + (activeAccount.powerArmorUnlocked && powerArmorCharge > 0 ? 0.20 : 0)
        return min(0.85, ArmorKind.helmet.reductions[helmetLevel] + ArmorKind.vest.reductions[vestLevel] + powered)
    }
    private var maxHealth: Int { 150 + trainingLevels[.resistance, default: 0] * 20 }

    private var gameStarted = false
    private var gameEnded = false
    private var shopOpen = false
    private var settingsOpen = false
    private var trainingOpen = false
    private var trapPlacementOpen = false
    private var grenadePlacementOpen = false
    private var airstrikePlacementOpen = false
    private var continuousGrenadePlacement = false
    private var continuousTrapPlacement = false
    private var queuedGrenadeDestinations: [CGPoint] = []
    private var gamePaused = false
    private var openingCinematicActive = false
    private var reputationAwardedThisRun = false
    private let accountStorageKey = "ShanghaiAction.accounts.v1"
    private let activeAccountStorageKey = "ShanghaiAction.activeAccount.v1"
    private var accounts: [AccountProfile] = []
    private var activeAccountID = ""
    private var activeAccountIndex: Int { accounts.firstIndex(where: { $0.id == activeAccountID }) ?? 0 }
    private var activeAccount: AccountProfile { accounts[activeAccountIndex] }

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
        // 动力护甲和特殊装备会读取当前账号，必须先完成账号恢复。
        loadAccounts()
        buildBackground()
        buildPlayer()
        buildHUD()
        updateHUD()
        playBackgroundMusic("opening_music.m4a", volume: 0.46)
        showOpeningCinematic()
    }

    private func showOpeningCinematic() {
        openingCinematicActive = true
        let cinematic = SKNode()
        cinematic.name = "openingCinematic"
        cinematic.zPosition = 900
        addChild(cinematic)

        let backdrop = SKShapeNode(rectOf: CGSize(width: size.width + 8, height: size.height + 8))
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.fillColor = SKColor(red: 0.008, green: 0.02, blue: 0.035, alpha: 1)
        backdrop.strokeColor = .clear
        cinematic.addChild(backdrop)

        let haze = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.48))
        haze.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        haze.fillColor = SKColor(red: 0.025, green: 0.15, blue: 0.19, alpha: 0.72)
        haze.strokeColor = .clear
        cinematic.addChild(haze)

        let skyline = SKNode()
        skyline.position = CGPoint(x: 0, y: 72)
        cinematic.addChild(skyline)
        for index in 0..<18 {
            let height = CGFloat(42 + (index * 31) % 115)
            let building = SKShapeNode(rectOf: CGSize(width: 47, height: height), cornerRadius: 2)
            building.position = CGPoint(x: CGFloat(index) * 51 - 10, y: height / 2)
            building.fillColor = SKColor(white: 0.025, alpha: 1)
            building.strokeColor = SKColor(red: 0.04, green: 0.25, blue: 0.29, alpha: 0.55)
            building.alpha = 0
            skyline.addChild(building)
            for floor in stride(from: CGFloat(12), to: height - 8, by: 17) {
                let window = SKShapeNode(rectOf: CGSize(width: 4, height: 3))
                window.position = CGPoint(x: index.isMultiple(of: 2) ? -9 : 9, y: floor - height / 2)
                window.fillColor = index % 3 == 0 ? .systemRed : .systemYellow
                window.strokeColor = .clear
                building.addChild(window)
            }
            building.run(.sequence([.wait(forDuration: Double(index) * 0.035), .fadeIn(withDuration: 0.35)]))
        }

        let tower = SKShapeNode(rectOf: CGSize(width: 35, height: 224), cornerRadius: 12)
        tower.position = CGPoint(x: size.width * 0.73, y: 184)
        tower.fillColor = SKColor(red: 0.04, green: 0.11, blue: 0.14, alpha: 1)
        tower.strokeColor = .systemCyan
        tower.lineWidth = 2
        tower.alpha = 0
        cinematic.addChild(tower)
        let spire = SKShapeNode(rectOf: CGSize(width: 5, height: 55), cornerRadius: 2)
        spire.position.y = 137
        spire.fillColor = .lightGray
        spire.strokeColor = .systemRed
        tower.addChild(spire)
        tower.run(.sequence([.wait(forDuration: 0.45), .fadeIn(withDuration: 0.55)]))

        let alertBand = SKShapeNode(rectOf: CGSize(width: size.width * 1.4, height: 12))
        alertBand.position = CGPoint(x: -size.width * 0.25, y: size.height - 82)
        alertBand.fillColor = .systemRed
        alertBand.strokeColor = .clear
        alertBand.alpha = 0
        alertBand.zRotation = -0.08
        cinematic.addChild(alertBand)
        alertBand.run(.sequence([.wait(forDuration: 0.9), .repeat(.sequence([.fadeAlpha(to: 0.75, duration: 0.12), .fadeAlpha(to: 0.08, duration: 0.18)]), count: 7), .fadeOut(withDuration: 0.3)]))

        func caption(_ text: String, at y: CGFloat, delay: TimeInterval, color: SKColor = .white) {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = text
            label.fontSize = 20
            label.fontColor = color
            label.position = CGPoint(x: size.width / 2, y: y)
            label.alpha = 0
            cinematic.addChild(label)
            label.run(.sequence([.wait(forDuration: delay), .fadeIn(withDuration: 0.35), .wait(forDuration: 1.05), .fadeOut(withDuration: 0.3)]))
        }
        caption("感染爆发后的第 17 天", at: size.height - 52, delay: 0.35, color: .lightGray)
        caption("上海最后的救援信号已经中断", at: size.height - 52, delay: 1.85, color: .systemRed)
        caption("一名幸存者，仍在向上海中心前进", at: size.height - 52, delay: 3.35, color: .systemCyan)

        let survivor = SKNode()
        survivor.position = CGPoint(x: -80, y: 102)
        survivor.alpha = 0
        cinematic.addChild(survivor)
        let head = SKShapeNode(circleOfRadius: 15)
        head.fillColor = SKColor(red: 0.75, green: 0.57, blue: 0.43, alpha: 1)
        head.strokeColor = .white
        head.position.y = 39
        survivor.addChild(head)
        let body = SKShapeNode(rectOf: CGSize(width: 31, height: 51), cornerRadius: 8)
        body.fillColor = SKColor(red: 0.05, green: 0.22, blue: 0.25, alpha: 1)
        body.strokeColor = .systemCyan
        survivor.addChild(body)
        let shotgun = SKShapeNode(rectOf: CGSize(width: 73, height: 8), cornerRadius: 3)
        shotgun.position = CGPoint(x: 34, y: 13)
        shotgun.zRotation = 0.13
        shotgun.fillColor = .darkGray
        shotgun.strokeColor = .systemOrange
        survivor.addChild(shotgun)
        survivor.run(.sequence([.wait(forDuration: 3.05), .fadeIn(withDuration: 0.2), .moveTo(x: size.width * 0.37, duration: 1.15)]))

        for index in 0..<5 {
            let infected = SKNode()
            infected.position = CGPoint(x: size.width + 55 + CGFloat(index) * 34, y: 92 + CGFloat(index % 2) * 24)
            infected.alpha = 0
            cinematic.addChild(infected)
            let head = SKShapeNode(circleOfRadius: 12)
            head.position.y = 29
            head.fillColor = SKColor(red: 0.30, green: 0.52, blue: 0.18, alpha: 1)
            head.strokeColor = .systemRed
            infected.addChild(head)
            let torso = SKShapeNode(rectOf: CGSize(width: 25, height: 42), cornerRadius: 7)
            torso.fillColor = .darkGray
            torso.strokeColor = .systemRed
            infected.addChild(torso)
            infected.run(.sequence([.wait(forDuration: 2.35 + Double(index) * 0.12), .fadeIn(withDuration: 0.2), .moveTo(x: size.width * 0.67 + CGFloat(index) * 25, duration: 1.5)]))
        }

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "上海行动"
        title.fontSize = 58
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 15)
        title.alpha = 0
        title.setScale(1.35)
        title.zPosition = 20
        cinematic.addChild(title)
        title.run(.sequence([.wait(forDuration: 5.0), .group([.fadeIn(withDuration: 0.45), .scale(to: 1, duration: 0.45)])]))
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitle.text = "SHANGHAI  ACTION"
        subtitle.fontSize = 15
        subtitle.fontColor = .systemCyan
        subtitle.position = CGPoint(x: size.width / 2, y: size.height / 2 - 28)
        subtitle.alpha = 0
        subtitle.zPosition = 20
        cinematic.addChild(subtitle)
        subtitle.run(.sequence([.wait(forDuration: 5.35), .fadeIn(withDuration: 0.35)]))

        let skip = SKLabelNode(fontNamed: "AvenirNext-Regular")
        skip.name = "skipOpeningCinematic"
        skip.text = "点击屏幕跳过"
        skip.fontSize = 13
        skip.fontColor = SKColor(white: 0.78, alpha: 1)
        skip.position = CGPoint(x: size.width - 82, y: 25)
        cinematic.addChild(skip)
        cinematic.run(.sequence([.wait(forDuration: 6.7), .run { [weak self] in self?.finishOpeningCinematic() }]), withKey: "finishOpening")
    }

    private func finishOpeningCinematic() {
        guard openingCinematicActive else { return }
        openingCinematicActive = false
        playBackgroundMusic("lobby_music.m4a", volume: 0.34)
        guard let cinematic = childNode(withName: "openingCinematic") else {
            showModeSelection()
            return
        }
        cinematic.removeAction(forKey: "finishOpening")
        cinematic.run(.sequence([.fadeOut(withDuration: 0.35), .run { [weak self] in
            guard let self, self.childNode(withName: "modeSelection") == nil else { return }
            self.showModeSelection()
        }, .removeFromParent()]))
    }

    private func playBackgroundMusic(_ fileName: String, volume: Float) {
        guard backgroundMusicName != fileName else { return }
        backgroundMusicName = fileName
        if let old = backgroundMusicNode {
            old.run(.sequence([.changeVolume(to: 0, duration: 0.45), .removeFromParent()]))
        }
        let music = SKAudioNode(fileNamed: fileName)
        music.name = "backgroundMusic"
        music.autoplayLooped = true
        music.isPositional = false
        music.run(.changeVolume(to: 0, duration: 0))
        addChild(music)
        music.run(.changeVolume(to: volume, duration: 0.65))
        backgroundMusicNode = music
    }

    private func startBattleMusic() {
        let track: String
        let volume: Float
        if gameMode == .mech {
            track = "battle_mech.m4a"
            volume = 0.82
        } else if gameMode == .task && taskChapter == 2 {
            track = "battle_water.m4a"
            volume = 0.86
        } else if gameMode == .task {
            track = "battle_heroic.m4a"
            volume = 0.88
        } else {
            track = "battle_heroic.m4a"
            volume = 0.86
        }
        playBackgroundMusic(track, volume: volume)
    }

    private func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: accountStorageKey),
           let saved = try? JSONDecoder().decode([AccountProfile].self, from: data), !saved.isEmpty {
            accounts = saved
        } else {
            accounts = [AccountProfile(id: UUID().uuidString, name: "幸存者001", level: 1, experience: 0)]
        }
        let savedID = UserDefaults.standard.string(forKey: activeAccountStorageKey)
        activeAccountID = accounts.contains(where: { $0.id == savedID }) ? (savedID ?? accounts[0].id) : accounts[0].id
        applyAccountItemLocks()
        saveAccounts()
    }

    private func applyAccountItemLocks() {
        if activeAccount.level < 6 { grenades = 0 }
        if activeAccount.level < 7 { airstrikes = 0 }
        if activeAccount.level < 5 { medicalKits = 0 }
        if activeAccount.level < 8 { stimulantShots = 0 }
        jetpackBatteryRemaining = 0
        jetpackBurstsRemaining = 0
        deactivateJetpack()
        vehicleFuelRemaining = 0
        deactivateVehicle()
        helicopterFuelRemaining = 0
        deactivateHelicopter()
        tankFuelRemaining = 0
        deactivateTank()
        hovercraftFuelRemaining = 0
        deactivateHovercraft()
        repairCooldownRemaining = 0
        unlocked.remove(.laserEmitter)
        unlocked.remove(.ionCannon)
        unlocked.remove(.plasmaBlade)
        if activeAccount.laserUnlocked { unlocked.insert(.laserEmitter) }
        if activeAccount.ionCannonUnlocked { unlocked.insert(.ionCannon) }
        if activeAccount.plasmaBladeUnlocked { unlocked.insert(.plasmaBlade) }
        updateJetpackHUD()
    }

    private func saveAccounts() {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: accountStorageKey)
        }
        UserDefaults.standard.set(activeAccountID, forKey: activeAccountStorageKey)
    }

    private func experienceNeeded(for level: Int) -> Int { max(100, level * 100) }

    private func grantExperience(_ amount: Int, reason: String) {
        guard amount > 0, !accounts.isEmpty else { return }
        let index = activeAccountIndex
        let oldLevel = accounts[index].level
        accounts[index].experience += amount
        while accounts[index].experience >= experienceNeeded(for: accounts[index].level) {
            accounts[index].experience -= experienceNeeded(for: accounts[index].level)
            accounts[index].level += 1
        }
        let newLevel = accounts[index].level
        saveAccounts()
        if newLevel > oldLevel {
            let unlockedName = newLevel == 2 ? "生存模式" : (newLevel == 3 ? "防守模式" : (newLevel == 4 ? "刀战模式" : (newLevel == 5 ? "医疗道具与解药章节" : "更高等级奖励")))
            showToast("升级至 Lv.\(newLevel) · 解锁\(unlockedName)", color: .systemYellow)
        } else {
            showToast("\(reason) · 经验 +\(amount)", color: .systemGreen)
        }
    }

    private func cachedTexture(_ name: String) -> SKTexture {
        if let texture = textureCache[name] { return texture }
        let texture = Self.preloadedTextureCache[name] ?? SKTexture(imageNamed: name)
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
        if isWaterChapter {
            buildWaterBattlefield()
            return
        }
        let backgroundIndex = usesSurvivalWaves ? 5 : (gameMode == .defense ? min(5, defenseFort + 2) : (currentLevel < 5 ? currentLevel + 1 : (currentLevel == 5 ? 4 : 5)))
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
        if gameMode == .defense { buildDefenseBoundary() }
    }

    private func buildWaterBattlefield() {
        let photoIndex = min(currentLevel + 1, 3)
        let photo = SKSpriteNode(texture: cachedTexture(String(format: "water_chapter%02d", photoIndex)))
        photo.position = CGPoint(x: size.width / 2, y: size.height / 2)
        photo.size = size
        photo.zPosition = -24
        scenery.addChild(photo)
        if isBossLevel {
            let bossTint = SKShapeNode(rectOf: size)
            bossTint.position = CGPoint(x: size.width / 2, y: size.height / 2)
            bossTint.fillColor = SKColor(red: 0.22, green: 0.01, blue: 0.04, alpha: 0.30)
            bossTint.strokeColor = .clear
            bossTint.zPosition = -19.5
            scenery.addChild(bossTint)
        }
        let sky = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.48))
        sky.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        sky.fillColor = currentLevel == 2 ? SKColor(red: 0.03, green: 0.04, blue: 0.09, alpha: 0.55) : SKColor(red: 0.02, green: 0.10, blue: 0.15, alpha: 0.28)
        sky.strokeColor = .clear
        sky.zPosition = -22
        scenery.addChild(sky)
        let water = SKShapeNode(rectOf: size)
        water.position = CGPoint(x: size.width / 2, y: size.height / 2)
        water.fillColor = currentLevel == 2 ? SKColor(red: 0.01, green: 0.05, blue: 0.10, alpha: 0.52) : SKColor(red: 0.01, green: 0.10, blue: 0.16, alpha: 0.34)
        water.strokeColor = .clear
        water.zPosition = -20
        scenery.addChild(water)
        buildWaterHorizonDetails()
        for index in 0..<24 {
            let near = index >= 12
            let wave = SKShapeNode(rectOf: CGSize(width: near ? 82 : 54, height: near ? 4 : 2), cornerRadius: 2)
            wave.position = CGPoint(x: CGFloat(index % 8) * 118 + CGFloat(index % 3) * 13 - 20, y: CGFloat(index / 8) * 62 + 38)
            wave.fillColor = near ? .white : .cyan
            wave.strokeColor = .clear
            wave.alpha = near ? 0.28 : 0.20
            wave.zPosition = -18
            let drift = CGFloat(22 + index % 4 * 8)
            wave.run(.repeatForever(.sequence([.moveBy(x: drift, y: 0, duration: 1.2 + Double(index % 3) * 0.2), .moveBy(x: -drift, y: 0, duration: 1.2 + Double(index % 3) * 0.2)])))
            scenery.addChild(wave)
        }
        buildPlayerShip()
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "第二章 · \(waterLevels[currentLevel].name)"
        title.fontSize = 16
        title.fontColor = .cyan
        title.position = CGPoint(x: size.width / 2, y: size.height - 72)
        title.zPosition = -10
        scenery.addChild(title)
    }

    private func buildWaterHorizonDetails() {
        if currentLevel == 0 {
            for index in 0..<13 {
                let height = CGFloat(24 + (index * 17) % 70)
                let building = SKShapeNode(rectOf: CGSize(width: 42, height: height))
                building.position = CGPoint(x: CGFloat(index) * 70 - 10, y: size.height * 0.64 + height / 2)
                building.fillColor = SKColor(white: 0.07, alpha: 0.92)
                building.strokeColor = .clear
                building.zPosition = -19
                scenery.addChild(building)
            }
            let tower = SKShapeNode(rectOf: CGSize(width: 18, height: 112), cornerRadius: 6)
            tower.position = CGPoint(x: size.width * 0.72, y: size.height * 0.64 + 56)
            tower.fillColor = .darkGray
            tower.strokeColor = .cyan
            tower.zPosition = -18
            scenery.addChild(tower)
        } else if currentLevel == 1 {
            for index in 0..<4 {
                let crane = SKNode()
                crane.position = CGPoint(x: 100 + CGFloat(index) * 210, y: size.height * 0.67)
                crane.zPosition = -18
                let mast = SKShapeNode(rectOf: CGSize(width: 8, height: 92))
                mast.position.y = 42
                mast.fillColor = .darkGray
                mast.strokeColor = .systemOrange
                crane.addChild(mast)
                let arm = SKShapeNode(rectOf: CGSize(width: 92, height: 7))
                arm.position = CGPoint(x: 38, y: 86)
                arm.fillColor = .darkGray
                arm.strokeColor = .systemOrange
                crane.addChild(arm)
                scenery.addChild(crane)
            }
        } else {
            let moon = SKShapeNode(circleOfRadius: 31)
            moon.position = CGPoint(x: size.width * 0.78, y: size.height * 0.82)
            moon.fillColor = SKColor(white: 0.88, alpha: 0.8)
            moon.strokeColor = .white
            moon.glowWidth = 12
            moon.zPosition = -19
            scenery.addChild(moon)
        }
    }

    private func buildPlayerShip() {
        let hullPath = CGMutablePath()
        hullPath.move(to: CGPoint(x: 55, y: 72))
        hullPath.addLine(to: CGPoint(x: size.width - 72, y: 72))
        hullPath.addLine(to: CGPoint(x: size.width - 22, y: 126))
        hullPath.addLine(to: CGPoint(x: size.width - 90, y: 245))
        hullPath.addLine(to: CGPoint(x: 66, y: 245))
        hullPath.addLine(to: CGPoint(x: 25, y: 122))
        hullPath.closeSubpath()
        let hull = SKShapeNode(path: hullPath)
        hull.fillColor = SKColor(red: 0.16, green: 0.19, blue: 0.21, alpha: 0.98)
        hull.strokeColor = .lightGray
        hull.lineWidth = 6
        hull.zPosition = -15
        scenery.addChild(hull)
        let deck = SKShapeNode(rectOf: CGSize(width: size.width * 0.76, height: 136), cornerRadius: 22)
        deck.position = CGPoint(x: size.width * 0.49, y: 160)
        deck.fillColor = SKColor(red: 0.27, green: 0.25, blue: 0.21, alpha: 0.98)
        deck.strokeColor = SKColor(red: 0.48, green: 0.43, blue: 0.32, alpha: 1)
        deck.lineWidth = 4
        deck.zPosition = -14
        scenery.addChild(deck)
        for index in 0..<7 {
            let seam = SKShapeNode(rectOf: CGSize(width: 3, height: 126))
            seam.position = CGPoint(x: size.width * 0.18 + CGFloat(index) * 88, y: 160)
            seam.fillColor = .black
            seam.strokeColor = .clear
            seam.alpha = 0.20
            seam.zPosition = -13
            scenery.addChild(seam)
        }
        let cabin = SKShapeNode(rectOf: CGSize(width: 128, height: 72), cornerRadius: 14)
        cabin.position = CGPoint(x: 148, y: 221)
        cabin.fillColor = SKColor(white: 0.24, alpha: 1)
        cabin.strokeColor = .white
        cabin.lineWidth = 3
        cabin.zPosition = -11
        scenery.addChild(cabin)
        for x in [-38, 0, 38] as [CGFloat] {
            let window = SKShapeNode(rectOf: CGSize(width: 27, height: 22), cornerRadius: 4)
            window.position = CGPoint(x: x, y: 9)
            window.fillColor = SKColor(red: 0.04, green: 0.28, blue: 0.38, alpha: 1)
            window.strokeColor = .cyan
            cabin.addChild(window)
        }
        for side: CGFloat in [-1, 1] {
            let rail = SKShapeNode(rectOf: CGSize(width: 7, height: 138), cornerRadius: 3)
            rail.position = CGPoint(x: side < 0 ? 57 : size.width - 74, y: 170)
            rail.fillColor = .darkGray
            rail.strokeColor = .white
            rail.zPosition = -10
            scenery.addChild(rail)
            let light = SKShapeNode(circleOfRadius: 7)
            light.position = CGPoint(x: side < 0 ? 57 : size.width - 74, y: 242)
            light.fillColor = side < 0 ? .systemRed : .systemGreen
            light.strokeColor = .white
            light.glowWidth = 7
            light.zPosition = -9
            scenery.addChild(light)
        }
        let wake = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.88, height: 42))
        wake.position = CGPoint(x: size.width * 0.48, y: 67)
        wake.fillColor = SKColor.white.withAlphaComponent(0.10)
        wake.strokeColor = SKColor.white.withAlphaComponent(0.45)
        wake.lineWidth = 5
        wake.zPosition = -16
        scenery.addChild(wake)
    }

    private func buildDefenseBoundary() {
        let boundaryX = size.width * 0.20
        for index in 0..<8 {
            let stripe = SKShapeNode(rectOf: CGSize(width: 18, height: size.height / 8 + 2))
            stripe.position = CGPoint(x: boundaryX, y: CGFloat(index) * size.height / 8 + size.height / 16)
            stripe.fillColor = index.isMultiple(of: 2) ? .systemYellow : .black
            stripe.strokeColor = .clear
            stripe.zPosition = -10
            scenery.addChild(stripe)
        }
        let wall = SKShapeNode(rectOf: CGSize(width: 62, height: size.height * 0.56), cornerRadius: 8)
        wall.position = CGPoint(x: boundaryX - 38, y: size.height * 0.34)
        wall.fillColor = SKColor(white: 0.13, alpha: 0.94)
        wall.strokeColor = .systemOrange
        wall.lineWidth = 4
        wall.zPosition = -9
        scenery.addChild(wall)
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = "堡垒 \(defenseFort)"
        label.fontSize = 13
        label.fontColor = .systemYellow
        label.position = CGPoint(x: boundaryX - 38, y: size.height * 0.63)
        label.zPosition = -8
        scenery.addChild(label)
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
        helmet.position = CGPoint(x: 0, y: 17)
        helmet.size = CGSize(width: 48, height: 48)
        helmet.zPosition = 3
        helmet.isHidden = true
        player.addChild(helmet)
        helmetSprite = helmet

        let vest = SKSpriteNode()
        vest.position = CGPoint(x: 0, y: -43)
        vest.size = CGSize(width: 52, height: 52)
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
        makeLabel(levelLabel, text: "任务模式 · 第 1/7 关", position: CGPoint(x: size.width / 2, y: size.height - 41), size: 18, alignment: .center)
        makeLabel(weaponLabel, text: "手枪 · 20", position: CGPoint(x: size.width - 25, y: size.height - 42), size: 18, alignment: .right)
        makeLabel(coinLabel, text: "◎ 申城币 0", position: CGPoint(x: size.width - 25, y: size.height - 68), size: 14, alignment: .right)
        coinLabel.fontColor = .systemYellow
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
        addRoundButton(grenadeButton, name: "grenade", text: "雷×1", position: CGPoint(x: size.width - 330, y: 137), color: .black, fontSize: 12, stroke: .systemRed)
        addRoundButton(trapButton, name: "trap", text: "阱×1", position: CGPoint(x: size.width - 330, y: 62), color: .black, fontSize: 12, stroke: .systemPurple)
        addRoundButton(medicalButton, name: "medical", text: "药×1", position: CGPoint(x: size.width - 405, y: 137), color: .black, fontSize: 11, stroke: .systemGreen)
        addRoundButton(stimulantButton, name: "stimulant", text: "针×1", position: CGPoint(x: size.width - 405, y: 62), color: .black, fontSize: 11, stroke: .systemBlue)
        addRoundButton(jetpackButton, name: "jetpack", text: "背包", position: CGPoint(x: size.width - 480, y: 62), color: .black, fontSize: 10, stroke: .gray)
        addRoundButton(airstrikeButton, name: "airstrike", text: "空袭×0", position: CGPoint(x: size.width - 480, y: 137), color: .black, fontSize: 9, stroke: .systemOrange)
        addRoundButton(torpedoButton, name: "torpedo", text: "鱼雷×0", position: CGPoint(x: size.width - 555, y: 137), color: .black, fontSize: 9, stroke: .systemCyan)
        torpedoButton.isHidden = true
        addRoundButton(vehicleButton, name: "vehicle", text: "载具·锁", position: CGPoint(x: size.width - 555, y: 62), color: .black, fontSize: 9, stroke: .gray)
        addRoundButton(helicopterButton, name: "helicopter", text: "直升机·锁", position: CGPoint(x: size.width - 630, y: 137), color: .black, fontSize: 8, stroke: .gray)
        addRoundButton(tankButton, name: "tank", text: "坦克·锁", position: CGPoint(x: size.width - 630, y: 62), color: .black, fontSize: 9, stroke: .gray)
        addRoundButton(hovercraftButton, name: "hovercraft", text: "气垫船·锁", position: CGPoint(x: size.width - 630, y: 62), color: .black, fontSize: 8, stroke: .gray)
        hovercraftButton.isHidden = true
        addRoundButton(settingsButton, name: "settings", text: "⚙", position: CGPoint(x: 35, y: size.height - 92), color: .black, fontSize: 22)
        addRoundButton(repairButton, name: "repairMech", text: "维修", position: CGPoint(x: 35, y: size.height - 158), color: .black, fontSize: 11, stroke: .systemGreen)
        repairButton.isHidden = true
        buildGrenadeButtonIcon()
        buildMedicalButtonIcon()
        buildStimulantButtonIcon()
        buildJetpackButtonIcon()
    }

    private func buildJetpackButtonIcon() {
        guard let label = jetpackButton.childNode(withName: "jetpack") as? SKLabelNode else { return }
        label.position.y = -15
        label.fontSize = 9
        let body = SKShapeNode(rectOf: CGSize(width: 18, height: 22), cornerRadius: 5)
        body.position.y = 8
        body.fillColor = .darkGray
        body.strokeColor = .systemOrange
        body.lineWidth = 2
        jetpackButton.addChild(body)
        for x in [-7, 7] as [CGFloat] {
            let nozzle = SKShapeNode(rectOf: CGSize(width: 5, height: 10), cornerRadius: 2)
            nozzle.position = CGPoint(x: x, y: -8)
            nozzle.fillColor = .gray
            nozzle.strokeColor = .clear
            body.addChild(nozzle)
        }
        let energyBack = SKShapeNode(rectOf: CGSize(width: 42, height: 5), cornerRadius: 2)
        energyBack.name = "jetpackEnergyBack"
        energyBack.position.y = -24
        energyBack.fillColor = .darkGray
        energyBack.strokeColor = .white
        energyBack.lineWidth = 1
        jetpackButton.addChild(energyBack)
        let energy = SKShapeNode(rectOf: CGSize(width: 40, height: 3), cornerRadius: 1)
        energy.name = "jetpackEnergy"
        energy.position.x = -20
        energy.xScale = 0
        energy.fillColor = .systemOrange
        energy.strokeColor = .clear
        energyBack.addChild(energy)
    }

    private func buildGrenadeButtonIcon() {
        guard let label = grenadeButton.childNode(withName: "grenade") as? SKLabelNode else { return }
        label.position.y = -14
        label.fontSize = 10
        let body = SKShapeNode(circleOfRadius: 8)
        body.position.y = 8
        body.fillColor = SKColor(red: 0.16, green: 0.28, blue: 0.12, alpha: 1)
        body.strokeColor = .lightGray
        body.lineWidth = 2
        body.zPosition = 2
        grenadeButton.addChild(body)
        let fuse = SKShapeNode(rectOf: CGSize(width: 5, height: 7), cornerRadius: 2)
        fuse.position = CGPoint(x: 4, y: 9)
        fuse.zRotation = -0.4
        fuse.fillColor = .darkGray
        fuse.strokeColor = .systemYellow
        body.addChild(fuse)
    }

    private func buildMedicalButtonIcon() {
        guard let label = medicalButton.childNode(withName: "medical") as? SKLabelNode else { return }
        label.position.y = -15
        label.fontSize = 10
        let vertical = SKShapeNode(rectOf: CGSize(width: 7, height: 21), cornerRadius: 2)
        vertical.position.y = 8
        vertical.fillColor = .white
        vertical.strokeColor = .systemGreen
        vertical.lineWidth = 1
        medicalButton.addChild(vertical)
        let horizontal = SKShapeNode(rectOf: CGSize(width: 21, height: 7), cornerRadius: 2)
        horizontal.position.y = 8
        horizontal.fillColor = .white
        horizontal.strokeColor = .systemGreen
        horizontal.lineWidth = 1
        medicalButton.addChild(horizontal)
    }

    private func buildStimulantButtonIcon() {
        guard let label = stimulantButton.childNode(withName: "stimulant") as? SKLabelNode else { return }
        label.position.y = -15
        label.fontSize = 10
        let barrel = SKShapeNode(rectOf: CGSize(width: 21, height: 7), cornerRadius: 2)
        barrel.position = CGPoint(x: 0, y: 8)
        barrel.zRotation = 0.65
        barrel.fillColor = .white
        barrel.strokeColor = .systemBlue
        barrel.lineWidth = 2
        stimulantButton.addChild(barrel)
        let needle = SKShapeNode(rectOf: CGSize(width: 15, height: 2))
        needle.position = CGPoint(x: 11, y: 9)
        needle.fillColor = .lightGray
        needle.strokeColor = .clear
        barrel.addChild(needle)
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
        title.text = isBossLevel ? "终极巢穴 · BOSS关" : "上海行动"
        title.fontSize = 35
        title.position.y = 48
        panel.addChild(title)
        let story = SKLabelNode(fontNamed: "AvenirNext-Regular")
        story.text = isBossLevel ? "变异暴君封锁了救援通道。击破三阶段形态，终结巢穴。" : "穿越上海街道，登顶上海中心取得解药。"
        story.fontSize = 17
        story.fontColor = .lightGray
        story.position.y = 5
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "start"
        start.text = isBossLevel ? "挑战变异暴君" : "开始任务模式 · 第一章"
        start.fontSize = 21
        start.fontColor = isBossLevel ? .systemRed : .cyan
        start.position.y = -55
        panel.addChild(start)
    }

    private func showModeSelection() {
        let panel = makePanel(name: "modeSelection", size: CGSize(width: size.width + 6, height: size.height + 6), color: SKColor(red: 0.008, green: 0.035, blue: 0.055, alpha: 1), stroke: .clear, z: 260)
        panel.lineWidth = 0
        let horizon = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.42))
        horizon.position.y = size.height * 0.27
        horizon.fillColor = SKColor(red: 0.015, green: 0.11, blue: 0.15, alpha: 1)
        horizon.strokeColor = .clear
        horizon.zPosition = -1
        panel.addChild(horizon)
        for index in 0..<14 {
            let building = SKShapeNode(rectOf: CGSize(width: 36, height: CGFloat(24 + (index * 19) % 68)))
            building.position = CGPoint(x: CGFloat(index) * 66 - size.width / 2 + 12, y: size.height * 0.09)
            building.fillColor = SKColor(white: 0.025, alpha: 0.72)
            building.strokeColor = .clear
            panel.addChild(building)
        }
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "上海行动"
        title.fontSize = 42
        title.position.y = size.height / 2 - 70
        panel.addChild(title)
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        let account = activeAccount
        subtitle.text = "\(account.name) · Lv.\(account.level) · ▰ EXP \(account.experience)/\(experienceNeeded(for: account.level))"
        subtitle.fontSize = 16
        subtitle.fontColor = .lightGray
        subtitle.position.y = size.height / 2 - 108
        panel.addChild(subtitle)
        let accountButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        accountButton.name = "accountManager"
        accountButton.text = "账户管理"
        accountButton.fontSize = 14
        accountButton.fontColor = .systemYellow
        accountButton.position = CGPoint(x: size.width / 2 - 75, y: size.height / 2 - 60)
        panel.addChild(accountButton)
        let lobbyButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lobbyButton.name = "openLobby"
        lobbyButton.text = "行动大厅"
        lobbyButton.fontSize = 14
        lobbyButton.fontColor = .systemGreen
        lobbyButton.position = CGPoint(x: -size.width / 2 + 75, y: size.height / 2 - 60)
        panel.addChild(lobbyButton)
        let spacing = min(CGFloat(160), (size.width - 44) / 5)
        addModeCard(to: panel, name: "selectTaskMode", title: "任务模式", detail: "第一章7关·单波\n第二章4关·Boss", x: -spacing * 2, available: true)
        addModeCard(to: panel, name: "selectSurvivalMode", title: "生存模式", detail: account.level >= 2 ? "枪械补给\n挺过20波" : "Lv.2 解锁\n完成任务获取经验", x: -spacing, available: account.level >= 2)
        addModeCard(to: panel, name: "selectDefenseMode", title: "防守模式", detail: account.level >= 3 ? "守住3座堡垒\n警戒线防御" : "Lv.3 解锁\n完成任务获取经验", x: 0, available: account.level >= 3)
        addModeCard(to: panel, name: "selectMeleeMode", title: "刀战模式", detail: account.level >= 4 ? "仅限近战武器\n挑战20波" : "Lv.4 解锁\n完成任务获取经验", x: spacing, available: account.level >= 4)
        addModeCard(to: panel, name: "selectMechMode", title: "机甲模式", detail: account.jetpackUnlocked ? "仅限特殊武器\n维修需冷却" : "制造喷气背包\n即可解锁", x: spacing * 2, available: account.jetpackUnlocked)
        addPortalButton(to: panel, name: "openActivities", text: "活动", x: -150, color: .systemOrange)
        addPortalButton(to: panel, name: "openMissions", text: "任务", x: 0, color: .systemGreen)
        addPortalButton(to: panel, name: "openCollection", text: "收藏", x: 150, color: .systemPurple)
    }

    private func addPortalButton(to panel: SKNode, name: String, text: String, x: CGFloat, color: SKColor) {
        let button = SKShapeNode(rectOf: CGSize(width: 132, height: 38), cornerRadius: 10)
        button.name = name
        button.position = CGPoint(x: x, y: -166)
        button.fillColor = SKColor(white: 0.035, alpha: 0.96)
        button.strokeColor = color
        button.lineWidth = 2
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.name = name
        label.text = text
        label.fontSize = 17
        label.fontColor = color
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func showModeStory(for mode: GameMode) {
        childNode(withName: "modeStoryPanel")?.removeFromParent()
        let title: String
        let chapter: String
        let story: String
        let objective: String
        let continueName: String
        let accent: SKColor
        switch mode {
        case .task:
            title = "任务模式 · 火种计划"
            chapter = "上海失守后的第七天"
            story = "幸存者电台截获一段来自上海中心的加密信号。\n研究员确认，能够逆转感染的原始解药仍保存在塔顶实验室。\n你必须穿越七条封锁街道，再沿黄浦江突破水上感染区，\n把解药送到撤离船，并终结守卫航道的变异暴君。"
            objective = "行动目标：取得解药 · 净化感染者 · 打通水上撤离线"
            continueName = "continueStoryTask"
            accent = .systemCyan
        case .survival:
            title = "生存模式 · 最后一夜"
            chapter = "末日堡垒即将完成撤离"
            story = "数百名平民正在堡垒地下等待救援车队。\n感染者已循着发电机的声音包围正门，黎明前不会有援军。\n你和守备队必须独自撑过二十波尸潮，\n让堡垒中的每一个幸存者活着看到天亮。"
            objective = "行动目标：守住正门 · 挺过20波 · 等待黎明救援"
            continueName = "continueStorySurvival"
            accent = .systemOrange
        case .defense:
            title = "防守模式 · 三道防线"
            chapter = "上海西部安全走廊告急"
            story = "连接避难区的三座堡垒构成了最后一道生命走廊。\n尸潮正从不同方向冲击黄黑警戒线，一旦突破，撤离通道将被切断。\n你被任命为临时防线指挥官，部署炮塔并招募士兵，\n逐座守住堡垒，任何感染者都不能越线。"
            objective = "行动目标：防守3座堡垒 · 建造炮塔 · 警戒线零突破"
            continueName = "continueStoryDefense"
            accent = .systemYellow
        case .melee:
            title = "刀战模式 · 静默街区"
            chapter = "弹药库爆炸后的封锁区"
            story = "一场爆炸摧毁了小队全部枪械弹药，也惊醒了整片街区。\n枪声会引来更庞大的尸群，撤离路线只能保持绝对静默。\n你拾起消防斧与砍刀，在狭窄街巷中近身突围，\n飞刀与回旋镖将成为有限的远程支援。"
            objective = "行动目标：仅用近战武器 · 挺过20波 · 静默撤离"
            continueName = "continueStoryMelee"
            accent = .systemRed
        case .mech:
            title = "机甲模式 · 雷霆协议"
            chapter = "特殊武器试验场失去联络"
            story = "大厅技师从喷气背包技术中复原了第一套动力机甲。\n试验启动时，高能信号却唤醒了潜伏地下的变异尸群。\n常规武器无法承受机甲功率，你只能依靠激光、离子炮和等离子刀，\n在装甲损毁前完成二十波战斗测试。"
            objective = "行动目标：仅用特殊武器 · 管理充能 · 冷却后维修机甲"
            continueName = "continueStoryMech"
            accent = .systemPurple
        }
        let panelSize = CGSize(width: min(690, size.width - 55), height: 350)
        let panel = makePanel(name: "modeStoryPanel", size: panelSize, color: SKColor(red: 0.015, green: 0.025, blue: 0.045, alpha: 0.99), stroke: accent, z: 345)
        let glow = SKShapeNode(circleOfRadius: 145)
        glow.fillColor = accent.withAlphaComponent(0.07)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: panelSize.width * 0.31, y: 45)
        glow.zPosition = -1
        panel.addChild(glow)
        let heading = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        heading.text = title
        heading.fontSize = 30
        heading.fontColor = accent
        heading.position.y = 142
        panel.addChild(heading)
        let time = SKLabelNode(fontNamed: "AvenirNext-Bold")
        time.text = chapter
        time.fontSize = 14
        time.fontColor = .lightGray
        time.position.y = 108
        panel.addChild(time)
        let narrative = SKLabelNode(fontNamed: "AvenirNext-Regular")
        narrative.text = story
        narrative.numberOfLines = 4
        narrative.fontSize = 16
        narrative.fontColor = .white
        narrative.position.y = 24
        narrative.preferredMaxLayoutWidth = panelSize.width - 70
        panel.addChild(narrative)
        let mission = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        mission.text = objective
        mission.fontSize = 14
        mission.fontColor = .systemYellow
        mission.position.y = -82
        panel.addChild(mission)
        let start = SKShapeNode(rectOf: CGSize(width: 180, height: 44), cornerRadius: 10)
        start.name = continueName
        start.position = CGPoint(x: 105, y: -132)
        start.fillColor = accent.withAlphaComponent(0.22)
        start.strokeColor = accent
        panel.addChild(start)
        let startText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        startText.name = continueName
        startText.text = mode == .task ? "选择章节与关卡" : "进入行动准备"
        startText.fontSize = 16
        startText.verticalAlignmentMode = .center
        start.addChild(startText)
        let back = SKLabelNode(fontNamed: "AvenirNext-Bold")
        back.name = "closeModeStory"
        back.text = "返回模式选择"
        back.fontSize = 15
        back.fontColor = .lightGray
        back.position = CGPoint(x: -115, y: -137)
        panel.addChild(back)
    }

    private var todayActivityKey: String {
        String(Int(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970))
    }

    private func showActivities() {
        childNode(withName: "activityPanel")?.removeFromParent()
        childNode(withName: "activityStoryPanel")?.removeFromParent()
        playBackgroundMusic("activity_music.m4a", volume: 0.68)
        let panelSize = CGSize(width: min(700, size.width - 50), height: 350)
        let panel = makePanel(name: "activityPanel", size: panelSize, color: SKColor(red: 0.025, green: 0.035, blue: 0.06, alpha: 0.98), stroke: .systemOrange, z: 360)
        let backdrop = SKSpriteNode(texture: cachedTexture("activity_night_drop"))
        backdrop.name = "activityBackdrop"
        backdrop.size = panelSize
        backdrop.alpha = 0.72
        backdrop.zPosition = 0.2
        panel.addChild(backdrop)
        let shade = SKShapeNode(rectOf: panelSize, cornerRadius: 18)
        shade.fillColor = SKColor(red: 0.01, green: 0.015, blue: 0.035, alpha: 0.28)
        shade.strokeColor = .clear
        shade.zPosition = 0.4
        panel.addChild(shade)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "夜雨空投 · 行动活动中心"
        title.fontSize = 29
        title.fontColor = .systemOrange
        title.position.y = 145
        title.zPosition = 2
        panel.addChild(title)
        let account = activeAccount
        let claimed = account.lastActivityClaimDate == todayActivityKey
        let daily = SKShapeNode(rectOf: CGSize(width: 500, height: 80), cornerRadius: 13)
        daily.fillColor = SKColor(red: 0.16, green: 0.075, blue: 0.02, alpha: 1)
        daily.strokeColor = claimed ? .gray : .systemYellow
        daily.position.y = 66
        daily.zPosition = 2
        panel.addChild(daily)
        let dailyText = SKLabelNode(fontNamed: "AvenirNext-Bold")
        dailyText.text = "每日空投补给\n◆ 碎片 +10 · ★ 声望 +5 · 藤条甲进度 \(min(14, account.activityClaimCount))/14"
        dailyText.numberOfLines = 2
        dailyText.fontSize = 16
        dailyText.position.x = -90
        daily.addChild(dailyText)
        let claim = SKShapeNode(rectOf: CGSize(width: 112, height: 42), cornerRadius: 9)
        claim.name = claimed ? "activityClaimed" : "claimDailyActivity"
        claim.position.x = 178
        claim.fillColor = claimed ? .darkGray : .systemOrange
        claim.strokeColor = .white
        daily.addChild(claim)
        let claimText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        claimText.name = claim.name
        claimText.text = claimed ? "今日已领取" : "领取补给"
        claimText.fontSize = 14
        claimText.verticalAlignmentMode = .center
        claim.addChild(claimText)
        let story = SKShapeNode(rectOf: CGSize(width: 500, height: 62), cornerRadius: 12)
        story.name = "openActivityStory"
        story.position.y = -16
        story.fillColor = SKColor(red: 0.025, green: 0.08, blue: 0.13, alpha: 0.88)
        story.strokeColor = .systemCyan
        story.zPosition = 2
        panel.addChild(story)
        let storyText = SKLabelNode(fontNamed: "AvenirNext-Bold")
        storyText.name = "openActivityStory"
        storyText.text = "活动剧情：夜雨空投  ›"
        storyText.fontSize = 18
        storyText.fontColor = .systemCyan
        storyText.verticalAlignmentMode = .center
        story.addChild(storyText)
        let event = SKLabelNode(fontNamed: "AvenirNext-Regular")
        event.text = "暴君追猎：击败最终 Boss 3次获得深海斧\n尸潮动员：任意模式通关均计入累计任务"
        event.numberOfLines = 2
        event.fontSize = 14
        event.fontColor = .white
        event.position.y = -78
        event.zPosition = 2
        panel.addChild(event)
        addPanelCloseButton(to: panel, name: "closeMetaPanel", y: -151)
    }

    private func showActivityStory() {
        childNode(withName: "activityStoryPanel")?.removeFromParent()
        let panelSize = CGSize(width: min(650, size.width - 65), height: 315)
        let panel = makePanel(name: "activityStoryPanel", size: panelSize, color: SKColor(red: 0.015, green: 0.025, blue: 0.055, alpha: 0.97), stroke: .systemCyan, z: 380)
        let backdrop = SKSpriteNode(texture: cachedTexture("activity_night_drop"))
        backdrop.size = panelSize
        backdrop.alpha = 0.58
        backdrop.zPosition = 0.2
        panel.addChild(backdrop)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "活动剧情 · 夜雨空投"
        title.fontSize = 28
        title.fontColor = .systemOrange
        title.position.y = 125
        panel.addChild(title)
        let chapter = SKLabelNode(fontNamed: "AvenirNext-Regular")
        chapter.text = "台风雨夜，浦东补给线被尸潮切断。\n一架无人机正携带最后一批净化样本飞向临时据点，\n但暴君的感染信号吸引了大批感染者。\n\n你的任务：守住空投区、回收样本，追踪暴君并夺回深海斧。"
        chapter.numberOfLines = 6
        chapter.fontSize = 17
        chapter.fontColor = .white
        chapter.position.y = 30
        chapter.preferredMaxLayoutWidth = panelSize.width - 90
        panel.addChild(chapter)
        let directive = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        directive.text = "行动代号：SH-RAIN · 样本不得失守"
        directive.fontSize = 15
        directive.fontColor = .systemYellow
        directive.position.y = -88
        panel.addChild(directive)
        addPanelCloseButton(to: panel, name: "closeActivityStory", y: -132)
    }

    private func claimDailyActivity() {
        let index = activeAccountIndex
        guard accounts[index].lastActivityClaimDate != todayActivityKey else { showToast("今日活动补给已经领取", color: .systemOrange); return }
        accounts[index].lastActivityClaimDate = todayActivityKey
        accounts[index].specialWeaponFragments += 10
        accounts[index].reputation += 5
        accounts[index].activityClaimCount += 1
        if accounts[index].activityClaimCount >= 14 { unlockCollectible("藤条甲", at: index, announce: false) }
        saveAccounts()
        showActivities()
        showToast("每日活动：◆ +10 · ★ +5", color: .systemYellow)
    }

    private func unlockCollectible(_ name: String, at index: Int? = nil, announce: Bool = true) {
        let accountIndex = index ?? activeAccountIndex
        guard !accounts[accountIndex].collectibleItems.contains(name) else { return }
        accounts[accountIndex].collectibleItems.append(name)
        saveAccounts()
        if announce { showToast("获得珍稀藏品：\(name)", color: .systemYellow) }
    }

    private struct MissionGoal {
        let id: String
        let title: String
        let target: Int
        let progress: (AccountProfile) -> Int
        let fragments: Int
        let reputation: Int
    }

    private var missionGoals: [MissionGoal] {
        [
            MissionGoal(id: "kills50", title: "清除感染者 I", target: 50, progress: { $0.totalKills }, fragments: 12, reputation: 5),
            MissionGoal(id: "kills200", title: "清除感染者 II", target: 200, progress: { $0.totalKills }, fragments: 28, reputation: 10),
            MissionGoal(id: "clear1", title: "首次凯旋", target: 1, progress: { $0.totalModeClears }, fragments: 15, reputation: 10),
            MissionGoal(id: "clear10", title: "上海守护者", target: 10, progress: { $0.totalModeClears }, fragments: 40, reputation: 25)
        ]
    }

    private func showMissions() {
        childNode(withName: "missionPanel")?.removeFromParent()
        let panel = makePanel(name: "missionPanel", size: CGSize(width: min(680, size.width - 55), height: 350), color: SKColor(red: 0.015, green: 0.09, blue: 0.055, alpha: 0.98), stroke: .systemGreen, z: 360)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "行动任务"
        title.fontSize = 29
        title.fontColor = .systemGreen
        title.position.y = 143
        panel.addChild(title)
        let account = activeAccount
        for (index, goal) in missionGoals.enumerated() {
            let progress = min(goal.target, goal.progress(account))
            let claimed = account.claimedMissionRewards.contains(goal.id)
            let complete = progress >= goal.target
            let row = SKShapeNode(rectOf: CGSize(width: 570, height: 55), cornerRadius: 10)
            row.position.y = 91 - CGFloat(index) * 62
            row.fillColor = SKColor(white: 0.045, alpha: 1)
            row.strokeColor = claimed ? .gray : (complete ? .systemYellow : .systemGreen)
            panel.addChild(row)
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "\(goal.title)  \(progress)/\(goal.target)   奖励：◆\(goal.fragments)  ★\(goal.reputation)"
            label.fontSize = 14
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: -266, y: -5)
            row.addChild(label)
            let button = SKShapeNode(rectOf: CGSize(width: 86, height: 34), cornerRadius: 8)
            button.name = claimed ? "missionClaimed" : (complete ? "claimMission_\(goal.id)" : "missionLocked")
            button.position.x = 232
            button.fillColor = claimed ? .darkGray : (complete ? .systemOrange : SKColor(white: 0.10, alpha: 1))
            button.strokeColor = complete && !claimed ? .white : .gray
            row.addChild(button)
            let text = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            text.name = button.name
            text.text = claimed ? "已领取" : (complete ? "领取" : "进行中")
            text.fontSize = 12
            text.verticalAlignmentMode = .center
            button.addChild(text)
        }
        addPanelCloseButton(to: panel, name: "closeMetaPanel", y: -147)
    }

    private func claimMission(_ id: String) {
        guard let goal = missionGoals.first(where: { $0.id == id }) else { return }
        let index = activeAccountIndex
        guard !accounts[index].claimedMissionRewards.contains(id), goal.progress(accounts[index]) >= goal.target else { return }
        accounts[index].claimedMissionRewards.append(id)
        accounts[index].specialWeaponFragments += goal.fragments
        accounts[index].reputation += goal.reputation
        saveAccounts()
        showMissions()
        showToast("任务完成：◆ +\(goal.fragments) · ★ +\(goal.reputation)", color: .systemGreen)
    }

    private func showCollection() {
        childNode(withName: "collectionPanel")?.removeFromParent()
        let panelSize = CGSize(width: size.width + 6, height: size.height + 6)
        let panel = makePanel(name: "collectionPanel", size: panelSize, color: SKColor(red: 0.018, green: 0.012, blue: 0.035, alpha: 1), stroke: .clear, z: 360)
        panel.lineWidth = 0
        let account = activeAccount
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "上海行动 · 收藏室"
        title.fontSize = 32
        title.fontColor = .systemPurple
        title.position.y = size.height / 2 - 42
        panel.addChild(title)
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.text = "珍稀藏品 (account.collectibleItems.count)/5 · 完成高难度行动点亮展台"
        subtitle.fontSize = 13
        subtitle.fontColor = .lightGray
        subtitle.position.y = size.height / 2 - 70
        panel.addChild(subtitle)
        let specialNames = [("激光发射器", account.laserUnlocked), ("离子子母炮", account.ionCannonUnlocked), ("等离子大刀", account.plasmaBladeUnlocked)]
        let equipmentNames = [("喷气背包", account.jetpackUnlocked), ("动力头盔", account.powerHelmetUnlocked), ("动力装甲", account.powerArmorUnlocked)]
        let vehicleNames = [("突击车", account.vehicleUnlocked), ("直升机", account.helicopterUnlocked), ("榴弹炮坦克", account.tankUnlocked), ("双联炮气垫船", account.hovercraftUnlocked)]
        let exhibits = [
            ("铂金钩爪", "collectible_platinum_hook", min(25, account.totalModeClears), 25, "累计通关"),
            ("龙息霰弹枪", "collectible_dragon_shotgun", min(1000, account.totalKills), 1000, "累计击杀"),
            ("磐石防爆盾", "collectible_riot_shield", min(5, account.defenseModeClears), 5, "防守胜利"),
            ("藤条甲", "collectible_rattan_armor", min(14, account.activityClaimCount), 14, "活动签到"),
            ("深海斧", "collectible_deep_sea_axe", min(3, account.bossDefeats), 3, "击败暴君")
        ]
        let spacing = min(CGFloat(148), (size.width - 80) / 5)
        for (index, exhibit) in exhibits.enumerated() {
            addCollectionExhibit(to: panel, name: exhibit.0, asset: exhibit.1, unlocked: account.collectibleItems.contains(exhibit.0), progress: exhibit.2, target: exhibit.3, condition: exhibit.4, x: (CGFloat(index) - 2) * spacing)
        }
        addCollectionRow(to: panel, title: "特殊武器", items: specialNames, y: -116, color: .systemCyan)
        addCollectionRow(to: panel, title: "动力装备", items: equipmentNames, y: -139, color: .systemOrange)
        addCollectionRow(to: panel, title: "行动载具", items: vehicleNames, y: -162, color: .systemGreen)
        let medal = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        medal.text = account.bossMedalUnlocked ? "◆ 收藏勋章：海上暴君终结者" : "◇ 未获得：击败第二章最终暴君"
        medal.fontSize = 13
        medal.fontColor = account.bossMedalUnlocked ? .systemYellow : .gray
        medal.position = CGPoint(x: -size.width / 2 + 165, y: size.height / 2 - 45)
        panel.addChild(medal)
        let close = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        close.name = "closeMetaPanel"
        close.text = "返回大厅"
        close.fontSize = 16
        close.fontColor = .white
        close.position = CGPoint(x: size.width / 2 - 75, y: size.height / 2 - 49)
        panel.addChild(close)
    }

    private func addCollectionExhibit(to panel: SKNode, name: String, asset: String, unlocked: Bool, progress: Int, target: Int, condition: String, x: CGFloat) {
        let card = SKShapeNode(rectOf: CGSize(width: 132, height: 190), cornerRadius: 13)
        card.position = CGPoint(x: x, y: 6)
        card.fillColor = SKColor(red: 0.035, green: 0.035, blue: 0.06, alpha: 0.98)
        card.strokeColor = unlocked ? .systemYellow : SKColor(white: 0.2, alpha: 1)
        card.lineWidth = unlocked ? 2.5 : 1.2
        panel.addChild(card)
        if unlocked {
            let glow = SKShapeNode(circleOfRadius: 48)
            glow.fillColor = SKColor.systemYellow.withAlphaComponent(0.1)
            glow.strokeColor = .clear
            glow.position.y = 25
            card.addChild(glow)
        }
        let icon = SKSpriteNode(texture: cachedTexture(asset))
        icon.size = CGSize(width: 108, height: 108)
        icon.position.y = 27
        if !unlocked {
            icon.color = .black
            icon.colorBlendFactor = 0.9
            icon.alpha = 0.42
        }
        card.addChild(icon)
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = unlocked ? name : "未解锁 · \(name)"
        label.fontSize = unlocked ? 13 : 10
        label.fontColor = unlocked ? .systemYellow : .gray
        label.position.y = -41
        card.addChild(label)
        let conditionLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        conditionLabel.text = unlocked ? "已陈列" : "\(condition) \(progress)/\(target)"
        conditionLabel.fontSize = 10
        conditionLabel.fontColor = unlocked ? .systemGreen : .lightGray
        conditionLabel.position.y = -63
        card.addChild(conditionLabel)
        let bar = SKShapeNode(rectOf: CGSize(width: 104, height: 6), cornerRadius: 3)
        bar.fillColor = SKColor(white: 0.12, alpha: 1)
        bar.strokeColor = .clear
        bar.position.y = -78
        card.addChild(bar)
        let ratio = min(1, CGFloat(progress) / CGFloat(max(1, target)))
        let fill = SKShapeNode(rectOf: CGSize(width: max(2, 104 * ratio), height: 6), cornerRadius: 3)
        fill.fillColor = unlocked ? .systemYellow : .systemPurple
        fill.strokeColor = .clear
        fill.position.x = -52 + max(2, 104 * ratio) / 2
        bar.addChild(fill)
    }

    private func addCollectionRow(to panel: SKNode, title: String, items: [(String, Bool)], y: CGFloat, color: SKColor) {
        let unlocked = items.filter(\.1).count
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "\(title) \(unlocked)/\(items.count)  " + items.map { $0.1 ? "◆\($0.0)" : "◇???" }.joined(separator: "  ")
        label.fontSize = 13
        label.fontColor = color
        label.position.y = y
        panel.addChild(label)
    }

    private func addPanelCloseButton(to panel: SKNode, name: String, y: CGFloat) {
        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.name = name
        close.text = "返回"
        close.fontSize = 16
        close.fontColor = .lightGray
        close.position.y = y
        panel.addChild(close)
    }

    private func showTaskLevelSelection() {
        childNode(withName: "taskLevelSelection")?.removeFromParent()
        let panel = makePanel(name: "taskLevelSelection", size: CGSize(width: min(760, size.width - 40), height: 340), color: SKColor(red: 0.01, green: 0.055, blue: 0.075, alpha: 0.99), stroke: .cyan, z: 320)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "任务模式 · 选择章节与关卡"
        title.fontSize = 28
        title.position.y = 140
        panel.addChild(title)
        addTaskChapterRow(to: panel, chapter: 1, title: "第一章 · 上海陆上行动", levels: levels, y: 62)
        addTaskChapterRow(to: panel, chapter: 2, title: "第二章 · 水上撤离线", levels: waterLevels, y: -65)
        let back = SKLabelNode(fontNamed: "AvenirNext-Bold")
        back.name = "closeTaskLevelSelection"
        back.text = "返回模式选择"
        back.fontSize = 16
        back.fontColor = .lightGray
        back.position.y = -150
        panel.addChild(back)
    }

    private func addTaskChapterRow(to panel: SKNode, chapter: Int, title: String, levels chapterLevels: [Level], y: CGFloat) {
        let heading = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        heading.text = title
        heading.fontSize = 18
        heading.fontColor = chapter == 1 ? .systemYellow : .systemCyan
        heading.position = CGPoint(x: -285, y: y + 35)
        heading.horizontalAlignmentMode = .left
        panel.addChild(heading)
        let spacing = min(CGFloat(88), 620 / CGFloat(chapterLevels.count))
        for index in chapterLevels.indices {
            let button = SKShapeNode(rectOf: CGSize(width: spacing - 8, height: 58), cornerRadius: 9)
            button.name = "selectTaskLevel_\(chapter)_\(index)"
            button.position = CGPoint(x: (CGFloat(index) - CGFloat(chapterLevels.count - 1) / 2) * spacing, y: y - 7)
            button.fillColor = chapter == 1 ? SKColor(red: 0.12, green: 0.10, blue: 0.035, alpha: 1) : SKColor(red: 0.025, green: 0.15, blue: 0.20, alpha: 1)
            button.strokeColor = chapter == 1 ? .systemYellow : .systemCyan
            panel.addChild(button)
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.name = button.name
            label.text = "\(index + 1)\n\(chapterLevels[index].name)"
            label.numberOfLines = 2
            label.fontSize = chapterLevels.count > 5 ? 9 : 11
            label.verticalAlignmentMode = .center
            button.addChild(label)
        }
    }

    private func selectTaskLevel(chapter: Int, level: Int) {
        childNode(withName: "taskLevelSelection")?.removeFromParent()
        childNode(withName: "modeSelection")?.removeFromParent()
        taskChapter = chapter
        currentLevel = level
        taskWave = 1
        kills = 0
        if chapter == 1 {
            enemiesToSpawn = levels[level].enemies
            torpedoButton.isHidden = true
            buildBackground()
            updateHUD()
            showIntro()
        } else {
            pendingWaterLevel = level
            showWaterChapterTransition()
        }
    }

    private func showLobby() {
        childNode(withName: "lobbyPanel")?.removeFromParent()
        let panel = makePanel(name: "lobbyPanel", size: CGSize(width: min(650, size.width - 60), height: 380), color: SKColor(red: 0.025, green: 0.09, blue: 0.08, alpha: 0.98), stroke: .systemGreen, z: 335)
        let account = activeAccount
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "幸存者行动大厅"
        title.fontSize = 29
        title.fontColor = .systemGreen
        title.position.y = 151
        panel.addChild(title)
        let resources = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resources.text = "★ 声望 \(account.reputation)    ◆ 武器碎片 \(account.specialWeaponFragments)    ⚙ 技师 \(account.weaponTechnicians)/10"
        resources.fontSize = 16
        resources.position.y = 117
        panel.addChild(resources)

        let workshop = SKShapeNode(rectOf: CGSize(width: 500, height: 78), cornerRadius: 12)
        workshop.position.y = 65
        workshop.fillColor = SKColor(white: 0.06, alpha: 1)
        workshop.strokeColor = .systemTeal
        panel.addChild(workshop)
        let gear = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        gear.text = "⚙"
        gear.fontSize = 38
        gear.fontColor = .systemYellow
        gear.position = CGPoint(x: -205, y: -13)
        workshop.addChild(gear)
        let production = SKLabelNode(fontNamed: "AvenirNext-Regular")
        production.text = account.weaponTechnicians == 0 ? "尚未雇佣技师，无法制造特殊武器碎片" : "每次任意模式通关，当前团队制造 \(account.weaponTechnicians * 2) 个碎片"
        production.fontSize = 15
        production.position = CGPoint(x: 28, y: 3)
        workshop.addChild(production)
        let rule = SKLabelNode(fontNamed: "AvenirNext-Regular")
        rule.text = "每名技师：20声望 · 每次通关制造2个碎片"
        rule.fontSize = 13
        rule.fontColor = .lightGray
        rule.position = CGPoint(x: 28, y: -23)
        workshop.addChild(rule)

        let special = SKLabelNode(fontNamed: "AvenirNext-Bold")
        special.text = "特殊装备制造区 · 武器自动充能，动力护具受击消耗能量"
        special.fontSize = 12
        special.fontColor = .systemOrange
        special.position.y = 5
        panel.addChild(special)
        addAccountButton(to: panel, name: account.jetpackUnlocked ? "craftJetpackBattery" : "craftJetpack", text: account.jetpackUnlocked ? "背包电池·6" : "喷气背包·30", x: -145, y: -41, color: .systemOrange)
        addAccountButton(to: panel, name: account.laserUnlocked ? "specialWeaponOwned" : "craftLaserEmitter", text: account.laserUnlocked ? "激光·已拥有" : "激光发射器·50", x: 0, y: -41, color: .systemCyan)
        addAccountButton(to: panel, name: account.ionCannonUnlocked ? "specialWeaponOwned" : "craftIonCannon", text: account.ionCannonUnlocked ? "离子炮·已拥有" : "离子炮·80", x: 145, y: -41, color: .systemPurple)
        addAccountButton(to: panel, name: account.plasmaBladeUnlocked ? "specialWeaponOwned" : "craftPlasmaBlade", text: account.plasmaBladeUnlocked ? "等离子刀·已拥有" : "等离子大刀·100", x: -145, y: -94, color: .systemBlue)
        addAccountButton(to: panel, name: account.powerHelmetUnlocked ? "specialWeaponOwned" : "craftPowerHelmet", text: account.powerHelmetUnlocked ? "动力头盔·已拥有" : "动力头盔·120", x: 0, y: -94, color: .systemYellow)
        addAccountButton(to: panel, name: account.powerArmorUnlocked ? "specialWeaponOwned" : "craftPowerArmor", text: account.powerArmorUnlocked ? "动力装甲·已拥有" : "动力装甲·160", x: 145, y: -94, color: .systemRed)
        addAccountButton(to: panel, name: account.vehicleUnlocked ? "specialWeaponOwned" : "craftVehicle", text: account.vehicleUnlocked ? "突击车·柴油\(account.dieselCanisters)" : "突击车·20", x: -248, y: -151, color: .systemGreen)
        addAccountButton(to: panel, name: account.helicopterUnlocked ? "specialWeaponOwned" : "craftHelicopter", text: account.helicopterUnlocked ? "直升机·油\(account.aviationFuelCanisters)" : "直升机·40", x: -124, y: -151, color: .systemCyan)
        addAccountButton(to: panel, name: account.tankUnlocked ? "specialWeaponOwned" : "craftTank", text: account.tankUnlocked ? "坦克·柴油\(account.dieselCanisters)" : "坦克榴弹炮·60", x: 0, y: -151, color: .systemOrange)
        addAccountButton(to: panel, name: account.hovercraftUnlocked ? "specialWeaponOwned" : "craftHovercraft", text: account.hovercraftUnlocked ? "气垫船·柴油\(account.dieselCanisters)" : "双联炮气垫船·45", x: 124, y: -151, color: .systemTeal)
        addAccountButton(to: panel, name: account.weaponTechnicians >= 10 ? "technicianMax" : "hireTechnician", text: account.weaponTechnicians >= 10 ? "技师已满" : "雇佣武器技师", x: 248, y: -151, color: .systemYellow)
        addAccountButton(to: panel, name: "closeLobby", text: "返回", x: 260, y: 160)
    }

    private func hireTechnician() {
        let index = activeAccountIndex
        guard accounts[index].weaponTechnicians < 10 else { showToast("武器技师已达到10人上限", color: .systemOrange); return }
        guard accounts[index].reputation >= 20 else { showToast("需要20声望才能雇佣技师", color: .systemRed); return }
        accounts[index].reputation -= 20
        accounts[index].weaponTechnicians += 1
        saveAccounts()
        childNode(withName: "lobbyPanel")?.removeFromParent()
        childNode(withName: "modeSelection")?.removeFromParent()
        showModeSelection()
        showLobby()
        showToast("武器技师已加入大厅", color: .systemGreen)
    }

    private func craftJetpack() {
        let index = activeAccountIndex
        guard !accounts[index].jetpackUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 30 else { showToast("制造喷气背包需要30个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 30
        accounts[index].jetpackUnlocked = true
        accounts[index].jetpackBatteries += 2
        saveAccounts()
        refreshLobby()
        updateJetpackHUD()
        showToast("喷气背包制造完成 · 获得2块电池", color: .systemOrange)
    }

    private func craftJetpackBattery() {
        let index = activeAccountIndex
        guard accounts[index].jetpackUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 6 else { showToast("制造电池需要6个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 6
        accounts[index].jetpackBatteries += 1
        saveAccounts()
        refreshLobby()
        updateJetpackHUD()
        showToast("喷气背包电池 +1", color: .systemYellow)
    }

    private func craftLaserEmitter() {
        let index = activeAccountIndex
        guard !accounts[index].laserUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 50 else { showToast("制造激光发射器需要50个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 50
        accounts[index].laserUnlocked = true
        unlocked.insert(.laserEmitter)
        saveAccounts()
        refreshLobby()
        showToast("激光发射器制造完成 · 充能6秒", color: .systemCyan)
    }

    private func craftIonCannon() {
        let index = activeAccountIndex
        guard !accounts[index].ionCannonUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 80 else { showToast("制造离子炮需要80个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 80
        accounts[index].ionCannonUnlocked = true
        unlocked.insert(.ionCannon)
        saveAccounts()
        refreshLobby()
        showToast("离子炮制造完成 · 充能12秒 · 配备8枚子弹", color: .systemPurple)
    }

    private func craftSpecialEquipment(cost: Int, kind: String) {
        let index = activeAccountIndex
        guard accounts[index].specialWeaponFragments >= cost else { showToast("制造\(kind)需要\(cost)个碎片", color: .systemRed); return }
        switch kind {
        case "等离子大刀":
            guard !accounts[index].plasmaBladeUnlocked else { return }
            accounts[index].plasmaBladeUnlocked = true
            unlocked.insert(.plasmaBlade)
        case "动力头盔":
            guard !accounts[index].powerHelmetUnlocked else { return }
            accounts[index].powerHelmetUnlocked = true
            powerHelmetCharge = 1
        default:
            guard !accounts[index].powerArmorUnlocked else { return }
            accounts[index].powerArmorUnlocked = true
            powerArmorCharge = 1
        }
        accounts[index].specialWeaponFragments -= cost
        saveAccounts()
        updateArmorGraphics()
        refreshLobby()
        showToast("\(kind)制造完成", color: .systemCyan)
    }

    private func craftVehicle() {
        let index = activeAccountIndex
        guard !accounts[index].vehicleUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 20 else { showToast("制造行动载具需要20个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 20
        accounts[index].vehicleUnlocked = true
        accounts[index].dieselCanisters += 1
        saveAccounts()
        refreshLobby()
        updateVehicleHUD()
        showToast("突击车制造完成 · 附赠1桶柴油", color: .systemGreen)
    }

    private func craftHelicopter() {
        let index = activeAccountIndex
        guard !accounts[index].helicopterUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 40 else { showToast("制造直升机需要40个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 40
        accounts[index].helicopterUnlocked = true
        accounts[index].aviationFuelCanisters += 1
        saveAccounts()
        refreshLobby()
        updateHelicopterHUD()
        showToast("直升机制造完成 · 附赠1桶航空燃料", color: .systemCyan)
    }

    private func craftTank() {
        let index = activeAccountIndex
        guard !accounts[index].tankUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 60 else { showToast("制造榴弹炮坦克需要60个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 60
        accounts[index].tankUnlocked = true
        accounts[index].dieselCanisters += 2
        saveAccounts()
        refreshLobby()
        updateTankHUD()
        showToast("榴弹炮坦克制造完成 · 附赠2桶柴油", color: .systemOrange)
    }

    private func craftHovercraft() {
        let index = activeAccountIndex
        guard !accounts[index].hovercraftUnlocked else { return }
        guard accounts[index].specialWeaponFragments >= 45 else { showToast("制造双联炮气垫船需要45个碎片", color: .systemRed); return }
        accounts[index].specialWeaponFragments -= 45
        accounts[index].hovercraftUnlocked = true
        accounts[index].dieselCanisters += 1
        saveAccounts()
        refreshLobby()
        updateHovercraftHUD()
        showToast("双联炮气垫船制造完成 · 附赠1桶柴油", color: .systemTeal)
    }

    private func refreshLobby() {
        childNode(withName: "lobbyPanel")?.removeFromParent()
        childNode(withName: "modeSelection")?.removeFromParent()
        showModeSelection()
        showLobby()
    }

    private func showAccountManager() {
        childNode(withName: "accountPanel")?.removeFromParent()
        let panel = makePanel(name: "accountPanel", size: CGSize(width: min(480, size.width - 90), height: 270), color: SKColor(white: 0.025, alpha: 0.98), stroke: .systemYellow, z: 330)
        let account = activeAccount
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "账户管理"
        title.fontSize = 28
        title.position.y = 96
        panel.addChild(title)
        let info = SKLabelNode(fontNamed: "AvenirNext-Regular")
        info.text = "当前：\(account.name) · Lv.\(account.level) · \(account.experience)/\(experienceNeeded(for: account.level)) EXP"
        info.fontSize = 16
        info.position.y = 58
        panel.addChild(info)
        addAccountButton(to: panel, name: "createAccount", text: "新建账户", x: -130, y: 5)
        addAccountButton(to: panel, name: "switchAccount", text: "切换账户（\(accounts.count)）", x: 0, y: 5)
        addAccountButton(to: panel, name: "renameAccount", text: "账户改名", x: 130, y: 5)
        addAccountButton(to: panel, name: "deleteAccount", text: "删除账户", x: -65, y: -50, color: .systemRed)
        addAccountButton(to: panel, name: "closeAccount", text: "返回", x: 65, y: -50)
        let note = SKLabelNode(fontNamed: "AvenirNext-Regular")
        note.text = "每个账户独立保存等级与经验"
        note.fontSize = 13
        note.fontColor = .lightGray
        note.position.y = -108
        panel.addChild(note)
    }

    private func addAccountButton(to panel: SKNode, name: String, text: String, x: CGFloat, y: CGFloat, color: SKColor = .cyan) {
        let button = SKShapeNode(rectOf: CGSize(width: 118, height: 42), cornerRadius: 10)
        button.name = name
        button.position = CGPoint(x: x, y: y)
        button.fillColor = SKColor(red: 0.04, green: 0.16, blue: 0.18, alpha: 1)
        button.strokeColor = color
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = text
        label.fontSize = text.count > 8 ? 11 : 14
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func createAccount() {
        guard let presenter = view?.window?.rootViewController else { return }
        let alert = UIAlertController(title: "新建幸存者账户", message: "输入账户名称（最多12个字符）", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "幸存者名称"; $0.text = "幸存者\(self.accounts.count + 1)" }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "创建", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let raw = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let name = String((raw.isEmpty ? "幸存者\(self.accounts.count + 1)" : raw).prefix(12))
            let account = AccountProfile(id: UUID().uuidString, name: name, level: 1, experience: 0)
            self.accounts.append(account)
            self.activeAccountID = account.id
            self.applyAccountItemLocks()
            self.saveAccounts()
            self.childNode(withName: "accountPanel")?.removeFromParent()
            self.childNode(withName: "modeSelection")?.removeFromParent()
            self.showModeSelection()
            self.showAccountManager()
        })
        presenter.present(alert, animated: true)
    }

    private func switchAccount() {
        guard accounts.count > 1 else { showToast("请先新建另一个账户", color: .systemOrange); return }
        let next = (activeAccountIndex + 1) % accounts.count
        activeAccountID = accounts[next].id
        applyAccountItemLocks()
        saveAccounts()
        childNode(withName: "accountPanel")?.removeFromParent()
        childNode(withName: "modeSelection")?.removeFromParent()
        showModeSelection()
        showAccountManager()
    }

    private func renameAccount() {
        guard let presenter = view?.window?.rootViewController else { return }
        let account = activeAccount
        let alert = UIAlertController(title: "账户改名", message: "输入新的账户名称（最多12个字符）", preferredStyle: .alert)
        alert.addTextField { $0.text = account.name; $0.clearButtonMode = .whileEditing }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let raw = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !raw.isEmpty else { self.showToast("账户名称不能为空", color: .systemRed); return }
            self.accounts[self.activeAccountIndex].name = String(raw.prefix(12))
            self.saveAccounts()
            self.refreshAccountPanels()
        })
        presenter.present(alert, animated: true)
    }

    private func deleteAccount() {
        guard accounts.count > 1 else { showToast("至少需要保留一个账户", color: .systemRed); return }
        guard let presenter = view?.window?.rootViewController else { return }
        let account = activeAccount
        let alert = UIAlertController(title: "删除账户？", message: "“\(account.name)”的等级与经验将永久删除。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认删除", style: .destructive) { [weak self] _ in
            guard let self else { return }
            let deletedIndex = self.activeAccountIndex
            self.accounts.remove(at: deletedIndex)
            self.activeAccountID = self.accounts[min(deletedIndex, self.accounts.count - 1)].id
            self.applyAccountItemLocks()
            self.saveAccounts()
            self.refreshAccountPanels()
            self.showToast("账户已删除", color: .systemOrange)
        })
        presenter.present(alert, animated: true)
    }

    private func refreshAccountPanels() {
        childNode(withName: "accountPanel")?.removeFromParent()
        childNode(withName: "modeSelection")?.removeFromParent()
        showModeSelection()
        showAccountManager()
    }

    private func showSurvivalIntro() {
        gameMode = .survival
        currentLevel = 0
        survivalWave = 1
        survivalTarget = 6
        enemiesToSpawn = survivalTarget
        buildBackground()
        updateHUD()
        let panel = makePanel(name: "survivalIntro", size: CGSize(width: min(620, size.width - 80), height: 220), color: SKColor(red: 0.10, green: 0.035, blue: 0.025, alpha: 0.96), stroke: .systemOrange, z: 250)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "生存模式 · 末日堡垒"
        title.fontSize = 31
        title.fontColor = .systemOrange
        title.position.y = 55
        panel.addChild(title)
        let story = SKLabelNode(fontNamed: "AvenirNext-Regular")
        story.text = "守住堡垒正门，挺过逐渐增强的20波尸潮。"
        story.fontSize = 17
        story.position.y = 8
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "startSurvival"
        start.text = "开始第 1 波"
        start.fontSize = 21
        start.fontColor = .systemYellow
        start.position.y = -57
        panel.addChild(start)
    }

    private func showDefenseIntro() {
        gameMode = .defense
        defenseFort = 1
        defenseWave = 1
        defenseTarget = 7
        defenseResolved = 0
        fortHealth = 100
        coins = max(coins, 220)
        currentLevel = 0
        enemiesToSpawn = defenseTarget
        buildBackground()
        updateHUD()
        let panel = makePanel(name: "defenseIntro", size: CGSize(width: min(640, size.width - 70), height: 225), color: SKColor(red: 0.12, green: 0.08, blue: 0.02, alpha: 0.97), stroke: .systemYellow, z: 250)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "防守模式 · 三道防线"
        title.fontSize = 31
        title.fontColor = .systemYellow
        title.position.y = 57
        panel.addChild(title)
        let story = SKLabelNode(fontNamed: "AvenirNext-Regular")
        story.text = "守住3座堡垒，不让丧尸越过黄黑警戒线。"
        story.fontSize = 17
        story.position.y = 9
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "startDefense"
        start.text = "开始防守堡垒 1"
        start.fontSize = 21
        start.fontColor = .systemOrange
        start.position.y = -58
        panel.addChild(start)
    }

    private func showMeleeIntro() {
        gameMode = .melee
        currentLevel = 0
        survivalWave = 1
        survivalTarget = 6
        enemiesToSpawn = survivalTarget
        unlocked = [.axe, .machete]
        if activeAccount.plasmaBladeUnlocked { unlocked.insert(.plasmaBlade) }
        weapon = .machete
        coins = max(coins, 90)
        updateWeaponGraphic()
        buildBackground()
        updateHUD()
        let panel = makePanel(name: "meleeIntro", size: CGSize(width: min(620, size.width - 80), height: 220), color: SKColor(red: 0.11, green: 0.025, blue: 0.025, alpha: 0.97), stroke: .systemRed, z: 250)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "刀战模式 · 近身尸潮"
        title.fontSize = 31
        title.fontColor = .systemRed
        title.position.y = 55
        panel.addChild(title)
        let story = SKLabelNode(fontNamed: "AvenirNext-Regular")
        story.text = "禁止枪械与弹药，只能用消防斧、砍刀和武士刀生存20波。"
        story.fontSize = 16
        story.position.y = 8
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "startMelee"
        start.text = "拔刀 · 开始第 1 波"
        start.fontSize = 21
        start.fontColor = .systemYellow
        start.position.y = -57
        panel.addChild(start)
    }

    private func showMechIntro() {
        gameMode = .mech
        currentLevel = 0
        survivalWave = 1
        survivalTarget = 8
        enemiesToSpawn = survivalTarget
        unlocked = [.laserEmitter]
        if activeAccount.ionCannonUnlocked { unlocked.insert(.ionCannon) }
        if activeAccount.plasmaBladeUnlocked { unlocked.insert(.plasmaBlade) }
        weapon = .laserEmitter
        laserCharge = 1
        ionCharge = 1
        plasmaBladeCharge = 1
        health = maxHealth
        repairCooldownRemaining = 0
        repairButton.isHidden = false
        coins = max(coins, 120)
        showMechArmor()
        updateWeaponGraphic()
        buildBackground()
        updateHUD()
        let panel = makePanel(name: "mechIntro", size: CGSize(width: min(650, size.width - 70), height: 225), color: SKColor(red: 0.035, green: 0.08, blue: 0.13, alpha: 0.98), stroke: .systemCyan, z: 250)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "机甲模式 · 动力突击"
        title.fontSize = 31
        title.fontColor = .systemCyan
        title.position.y = 58
        panel.addChild(title)
        let story = SKLabelNode(fontNamed: "AvenirNext-Regular")
        story.text = "仅可使用充能型特殊武器。机甲受损后可维修，每次维修需冷却20秒。"
        story.fontSize = 15
        story.position.y = 8
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "startMech"
        start.text = "启动机甲 · 开始第 1 波"
        start.fontSize = 21
        start.fontColor = .systemYellow
        start.position.y = -58
        panel.addChild(start)
    }

    private func showMechArmor() {
        player.childNode(withName: "mechArmor")?.removeFromParent()
        let armor = SKNode()
        armor.name = "mechArmor"
        armor.zPosition = 12
        let chest = SKShapeNode(rectOf: CGSize(width: 70, height: 72), cornerRadius: 15)
        chest.position.y = -42
        chest.fillColor = SKColor(red: 0.08, green: 0.18, blue: 0.23, alpha: 0.94)
        chest.strokeColor = .systemCyan
        chest.lineWidth = 4
        armor.addChild(chest)
        for x in [-43, 43] as [CGFloat] {
            let shoulder = SKShapeNode(circleOfRadius: 18)
            shoulder.position = CGPoint(x: x, y: -25)
            shoulder.fillColor = .darkGray
            shoulder.strokeColor = .systemOrange
            armor.addChild(shoulder)
            let servo = SKShapeNode(rectOf: CGSize(width: 16, height: 48), cornerRadius: 7)
            servo.position = CGPoint(x: x, y: -58)
            servo.fillColor = SKColor(white: 0.12, alpha: 1)
            servo.strokeColor = .systemCyan
            armor.addChild(servo)
        }
        let core = SKShapeNode(circleOfRadius: 11)
        core.position.y = -38
        core.fillColor = .systemCyan
        core.strokeColor = .white
        core.glowWidth = 7
        armor.addChild(core)
        player.addChild(armor)
    }

    private func repairMech() {
        guard gameMode == .mech, gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        guard repairCooldownRemaining <= 0 else { showToast("维修系统冷却中：\(Int(ceil(repairCooldownRemaining)))秒", color: .systemYellow); return }
        guard health < maxHealth else { showToast("机甲耐久已满", color: .systemGreen); return }
        let restored = min(45, maxHealth - health)
        health += restored
        repairCooldownRemaining = 20
        pulse(at: player.position, color: .systemGreen, radius: 62)
        updateHUD()
        showToast("机甲维修完成：耐久 +\(restored)", color: .systemGreen)
    }

    private func addModeCard(to panel: SKNode, name: String, title: String, detail: String, x: CGFloat, available: Bool) {
        let card = SKShapeNode(rectOf: CGSize(width: 154, height: 132), cornerRadius: 14)
        let actionName = available ? name : (name == "selectMechMode" ? "lockedMechMode" : "lockedMode")
        card.name = actionName
        card.position = CGPoint(x: x, y: -25)
        card.fillColor = available ? SKColor(red: 0.03, green: 0.18, blue: 0.22, alpha: 1) : SKColor(white: 0.08, alpha: 1)
        card.strokeColor = available ? .cyan : .darkGray
        card.lineWidth = available ? 3 : 2
        panel.addChild(card)
        let heading = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        heading.name = actionName
        heading.text = title
        heading.fontSize = 21
        heading.fontColor = available ? .cyan : .gray
        heading.position.y = name == "selectMechMode" ? 47 : 28
        card.addChild(heading)
        let description = SKLabelNode(fontNamed: "AvenirNext-Regular")
        description.name = actionName
        description.text = detail
        description.numberOfLines = 2
        description.fontSize = 13
        description.fontColor = available ? .white : .gray
        description.position.y = name == "selectMechMode" ? -45 : -22
        card.addChild(description)
        if name == "selectMechMode" { addMechModeIcon(to: card, actionName: actionName, available: available) }
    }

    private func addMechModeIcon(to card: SKNode, actionName: String, available: Bool) {
        let icon = SKNode()
        icon.name = actionName
        icon.position.y = 4
        icon.setScale(0.72)
        let metal = available ? SKColor(red: 0.11, green: 0.24, blue: 0.30, alpha: 1) : .darkGray
        let light = available ? SKColor.systemCyan : .gray

        let torsoPath = CGMutablePath()
        torsoPath.move(to: CGPoint(x: -31, y: 17))
        torsoPath.addLine(to: CGPoint(x: -39, y: -25))
        torsoPath.addLine(to: CGPoint(x: -22, y: -38))
        torsoPath.addLine(to: CGPoint(x: 22, y: -38))
        torsoPath.addLine(to: CGPoint(x: 39, y: -25))
        torsoPath.addLine(to: CGPoint(x: 31, y: 17))
        torsoPath.closeSubpath()
        let torso = SKShapeNode(path: torsoPath)
        torso.name = actionName
        torso.fillColor = metal
        torso.strokeColor = light
        torso.lineWidth = 3
        icon.addChild(torso)

        let helmet = SKShapeNode(rectOf: CGSize(width: 48, height: 35), cornerRadius: 9)
        helmet.name = actionName
        helmet.position.y = 27
        helmet.fillColor = SKColor(white: available ? 0.12 : 0.16, alpha: 1)
        helmet.strokeColor = light
        helmet.lineWidth = 3
        icon.addChild(helmet)
        let faceplate = SKShapeNode(rectOf: CGSize(width: 35, height: 15), cornerRadius: 4)
        faceplate.name = actionName
        faceplate.position.y = 24
        faceplate.fillColor = .black
        faceplate.strokeColor = available ? .systemBlue : .gray
        helmet.addChild(faceplate)
        for x in [-10, 10] as [CGFloat] {
            let eye = SKShapeNode(rectOf: CGSize(width: 12, height: 3), cornerRadius: 1)
            eye.name = actionName
            eye.position.x = x
            eye.fillColor = light
            eye.strokeColor = .clear
            eye.glowWidth = available ? 5 : 0
            faceplate.addChild(eye)
        }

        for x in [-47, 47] as [CGFloat] {
            let shoulder = SKShapeNode(rectOf: CGSize(width: 25, height: 20), cornerRadius: 6)
            shoulder.name = actionName
            shoulder.position = CGPoint(x: x, y: 4)
            shoulder.zRotation = x < 0 ? 0.18 : -0.18
            shoulder.fillColor = metal
            shoulder.strokeColor = available ? .systemOrange : .gray
            shoulder.lineWidth = 3
            icon.addChild(shoulder)
            let arm = SKShapeNode(rectOf: CGSize(width: 12, height: 36), cornerRadius: 5)
            arm.name = actionName
            arm.position = CGPoint(x: x, y: -23)
            arm.fillColor = .darkGray
            arm.strokeColor = light
            icon.addChild(arm)
        }

        let coreOuter = SKShapeNode(circleOfRadius: 12)
        coreOuter.name = actionName
        coreOuter.position.y = -8
        coreOuter.fillColor = .black
        coreOuter.strokeColor = available ? .systemOrange : .gray
        coreOuter.lineWidth = 3
        icon.addChild(coreOuter)
        let core = SKShapeNode(circleOfRadius: 6)
        core.name = actionName
        core.fillColor = light
        core.strokeColor = .white
        core.glowWidth = available ? 6 : 0
        coreOuter.addChild(core)
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
        if weapon == .plasmaBlade {
            let icon = plasmaBladeNode()
            icon.position = CGPoint(x: 66, y: -12)
            icon.zPosition = 5
            player.addChild(icon)
            weaponSprite = icon
            return
        }
        if weapon.isEnergyWeapon {
            let icon = energyWeaponNode(for: weapon)
            icon.position = CGPoint(x: 58, y: -12)
            icon.zPosition = 5
            player.addChild(icon)
            weaponSprite = icon
            return
        }
        if weapon.isThrownMelee {
            let icon = thrownWeaponNode(for: weapon)
            icon.position = CGPoint(x: 43, y: -12)
            icon.setScale(0.82)
            icon.zPosition = 5
            player.addChild(icon)
            weaponSprite = icon
            return
        }
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
        case .rpg:
            sprite.size = CGSize(width: 166, height: 55)
            sprite.position = CGPoint(x: 73, y: -11)
        case .machete:
            sprite.size = CGSize(width: 118, height: 40)
            sprite.position = CGPoint(x: 54, y: -13)
        case .katana:
            sprite.size = CGSize(width: 142, height: 42)
            sprite.position = CGPoint(x: 66, y: -13)
        case .throwingKnife, .boomerang, .laserEmitter, .ionCannon, .plasmaBlade:
            break
        }
        sprite.zPosition = 5
        player.addChild(sprite)
        weaponSprite = sprite
    }

    private func plasmaBladeNode() -> SKNode {
        let node = SKNode()
        let bladePath = CGMutablePath()
        bladePath.move(to: CGPoint(x: -34, y: -8))
        bladePath.addLine(to: CGPoint(x: 70, y: -4))
        bladePath.addLine(to: CGPoint(x: 86, y: 0))
        bladePath.addLine(to: CGPoint(x: 70, y: 8))
        bladePath.addLine(to: CGPoint(x: -34, y: 10))
        bladePath.closeSubpath()
        let blade = SKShapeNode(path: bladePath)
        blade.fillColor = SKColor(red: 0.05, green: 0.35, blue: 0.48, alpha: 0.9)
        blade.strokeColor = .cyan
        blade.lineWidth = 4
        blade.glowWidth = 10
        node.addChild(blade)
        let core = SKShapeNode(rectOf: CGSize(width: 82, height: 4), cornerRadius: 2)
        core.position.x = 19
        core.fillColor = .white
        core.strokeColor = .cyan
        node.addChild(core)
        let guardNode = SKShapeNode(rectOf: CGSize(width: 12, height: 32), cornerRadius: 3)
        guardNode.position.x = -39
        guardNode.fillColor = .darkGray
        guardNode.strokeColor = .systemBlue
        node.addChild(guardNode)
        let grip = SKShapeNode(rectOf: CGSize(width: 36, height: 13), cornerRadius: 4)
        grip.position.x = -62
        grip.fillColor = .black
        grip.strokeColor = .lightGray
        node.addChild(grip)
        for x in [-8, 15, 38, 61] as [CGFloat] {
            let emitter = SKShapeNode(circleOfRadius: 4)
            emitter.position = CGPoint(x: x, y: 1)
            emitter.fillColor = .white
            emitter.strokeColor = .cyan
            emitter.glowWidth = 4
            node.addChild(emitter)
        }
        let pommel = SKShapeNode(circleOfRadius: 8)
        pommel.position.x = -84
        pommel.fillColor = .systemBlue
        pommel.strokeColor = .white
        pommel.glowWidth = 5
        node.addChild(pommel)
        return node
    }

    private func energyWeaponNode(for item: Weapon) -> SKNode {
        let node = SKNode()
        let ion = item == .ionCannon
        let body = SKShapeNode(rectOf: CGSize(width: ion ? 118 : 104, height: ion ? 38 : 28), cornerRadius: 9)
        body.fillColor = ion ? SKColor(red: 0.16, green: 0.05, blue: 0.28, alpha: 1) : SKColor(red: 0.02, green: 0.20, blue: 0.24, alpha: 1)
        body.strokeColor = ion ? .systemPurple : .systemCyan
        body.lineWidth = 3
        node.addChild(body)
        let core = SKShapeNode(rectOf: CGSize(width: ion ? 56 : 64, height: 8), cornerRadius: 4)
        core.fillColor = ion ? .systemPurple : .cyan
        core.strokeColor = .white
        core.glowWidth = 5
        node.addChild(core)
        let muzzle = SKShapeNode(circleOfRadius: ion ? 17 : 11)
        muzzle.position.x = ion ? 62 : 55
        muzzle.fillColor = .black
        muzzle.strokeColor = ion ? .systemPurple : .cyan
        muzzle.lineWidth = 4
        node.addChild(muzzle)
        let grip = SKShapeNode(rectOf: CGSize(width: 18, height: 28), cornerRadius: 4)
        grip.position = CGPoint(x: -25, y: -24)
        grip.zRotation = -0.18
        grip.fillColor = .darkGray
        grip.strokeColor = .lightGray
        node.addChild(grip)
        let battery = SKShapeNode(rectOf: CGSize(width: ion ? 30 : 24, height: 19), cornerRadius: 4)
        battery.position = CGPoint(x: -44, y: -4)
        battery.fillColor = .black
        battery.strokeColor = ion ? .systemPurple : .systemCyan
        node.addChild(battery)
        for index in 0..<(ion ? 4 : 3) {
            let ring = SKShapeNode(rectOf: CGSize(width: 5, height: ion ? 42 : 31), cornerRadius: 2)
            ring.position.x = CGFloat(index) * 18 - 6
            ring.fillColor = ion ? .systemPurple : .cyan
            ring.strokeColor = .white
            ring.alpha = 0.75
            node.addChild(ring)
        }
        let sight = SKShapeNode(rectOf: CGSize(width: 27, height: 8), cornerRadius: 3)
        sight.position = CGPoint(x: -14, y: ion ? 25 : 19)
        sight.fillColor = .darkGray
        sight.strokeColor = ion ? .systemPurple : .cyan
        node.addChild(sight)
        return node
    }

    private func thrownWeaponNode(for item: Weapon) -> SKNode {
        let node = SKNode()
        if item == .throwingKnife {
            let bladePath = CGMutablePath()
            bladePath.move(to: CGPoint(x: -18, y: -4))
            bladePath.addLine(to: CGPoint(x: 20, y: 0))
            bladePath.addLine(to: CGPoint(x: -18, y: 5))
            bladePath.closeSubpath()
            let blade = SKShapeNode(path: bladePath)
            blade.fillColor = .lightGray
            blade.strokeColor = .white
            let grip = SKShapeNode(rectOf: CGSize(width: 15, height: 9), cornerRadius: 2)
            grip.position.x = -24
            grip.fillColor = SKColor(red: 0.20, green: 0.12, blue: 0.06, alpha: 1)
            grip.strokeColor = .systemOrange
            node.addChild(blade)
            node.addChild(grip)
        } else {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -22, y: 12))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 22, y: 12))
            path.addLine(to: CGPoint(x: 17, y: 21))
            path.addLine(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: -17, y: 21))
            path.closeSubpath()
            let body = SKShapeNode(path: path)
            body.fillColor = SKColor(red: 0.16, green: 0.22, blue: 0.24, alpha: 1)
            body.strokeColor = .systemTeal
            body.lineWidth = 3
            node.addChild(body)
        }
        return node
    }

    private func spawnBoss() {
        bossDefeated = false
        lastBossShock = lastUpdate
        lastBossSummon = lastUpdate
        let boss = SKShapeNode(circleOfRadius: 52)
        boss.name = "enemyBoss"
        boss.position = CGPoint(x: size.width + 80, y: size.height * 0.43)
        boss.zPosition = 19
        boss.fillColor = SKColor(red: 0.10, green: 0.025, blue: 0.02, alpha: 0.98)
        boss.strokeColor = .systemRed
        boss.lineWidth = 7
        boss.glowWidth = 5
        let maxHP = 160
        boss.userData = ["hp": maxHP, "maxHP": maxHP, "phase": 1, "summoning": false]

        let portrait = SKSpriteNode(texture: cachedTexture("zombie_heavy"))
        portrait.name = "bossPortrait"
        portrait.size = CGSize(width: 98, height: 98)
        portrait.color = .systemRed
        portrait.colorBlendFactor = 0.30
        portrait.zPosition = 2
        boss.addChild(portrait)
        addEnemyBody(to: boss, heavy: true, radius: 52)

        for side in [-1, 1] as [CGFloat] {
            let hornPath = CGMutablePath()
            hornPath.move(to: CGPoint(x: side * 28, y: 38))
            hornPath.addLine(to: CGPoint(x: side * 62, y: 70))
            hornPath.addLine(to: CGPoint(x: side * 45, y: 27))
            hornPath.closeSubpath()
            let horn = SKShapeNode(path: hornPath)
            horn.fillColor = .darkGray
            horn.strokeColor = .systemOrange
            horn.lineWidth = 3
            horn.zPosition = 1
            boss.addChild(horn)
            let shoulder = SKShapeNode(rectOf: CGSize(width: 46, height: 32), cornerRadius: 8)
            shoulder.position = CGPoint(x: side * 54, y: -45)
            shoulder.zRotation = side * -0.18
            shoulder.fillColor = SKColor(white: 0.07, alpha: 1)
            shoulder.strokeColor = .systemRed
            shoulder.lineWidth = 4
            boss.addChild(shoulder)
        }

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "变异暴君"
        title.fontSize = 17
        title.fontColor = .systemRed
        title.position.y = 78
        boss.addChild(title)
        let healthBack = SKShapeNode(rectOf: CGSize(width: 144, height: 14), cornerRadius: 6)
        healthBack.position.y = 60
        healthBack.fillColor = .black
        healthBack.strokeColor = .white
        healthBack.lineWidth = 2
        boss.addChild(healthBack)
        let healthFill = SKShapeNode(rectOf: CGSize(width: 138, height: 9), cornerRadius: 4)
        healthFill.name = "bossHealthFill"
        healthFill.fillColor = .systemRed
        healthFill.strokeColor = .clear
        healthBack.addChild(healthFill)

        boss.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 110, height: 178), center: CGPoint(x: 0, y: -40))
        boss.physicsBody?.affectedByGravity = false
        boss.physicsBody?.categoryBitMask = Mask.enemy
        boss.physicsBody?.contactTestBitMask = Mask.player | Mask.bullet
        boss.physicsBody?.collisionBitMask = 0
        world.addChild(boss)
        showToast("BOSS出现 · 变异暴君进入三阶段战斗", color: .systemRed)
    }

    private func summonBossMinions(around boss: SKNode, count: Int) {
        for index in 0..<count {
            let minion = SKShapeNode(circleOfRadius: 22)
            minion.name = "enemyBossMinion"
            let angle = CGFloat(index) * (.pi * 2 / CGFloat(max(1, count)))
            minion.position = CGPoint(x: boss.position.x + cos(angle) * 78, y: boss.position.y + sin(angle) * 58)
            minion.zPosition = 17
            minion.fillColor = SKColor(red: 0.06, green: 0.10, blue: 0.04, alpha: 0.98)
            minion.strokeColor = .systemPurple
            minion.lineWidth = 4
            minion.userData = ["hp": 5, "bossMinion": true]
            let portrait = SKSpriteNode(texture: cachedTexture("zombie_standard"))
            portrait.size = CGSize(width: 42, height: 42)
            portrait.color = .systemPurple
            portrait.colorBlendFactor = 0.32
            portrait.zPosition = 2
            minion.addChild(portrait)
            addEnemyBody(to: minion, heavy: false, radius: 22)
            let badge = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            badge.text = "暴君召唤物"
            badge.fontSize = 9
            badge.fontColor = .systemPurple
            badge.position.y = -42
            minion.addChild(badge)
            minion.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 46, height: 100), center: CGPoint(x: 0, y: -34))
            minion.physicsBody?.affectedByGravity = false
            minion.physicsBody?.categoryBitMask = Mask.enemy
            minion.physicsBody?.contactTestBitMask = Mask.player | Mask.bullet
            minion.physicsBody?.collisionBitMask = 0
            minion.setScale(0.15)
            world.addChild(minion)
            minion.run(.sequence([.wait(forDuration: Double(index) * 0.12), .scale(to: 1, duration: 0.28)]))
            pulse(at: minion.position, color: .systemPurple, radius: 38)
        }
        showToast("暴君召唤感染者增援 ×\(count)", color: .systemPurple)
    }

    private func spawnEnemy() {
        guard gameStarted, !gameEnded, enemiesToSpawn > 0 else { return }
        enemiesToSpawn -= 1
        if isBossLevel {
            spawnBoss()
            return
        }
        let typeRoll = Int.random(in: 0..<100)
        let heavy = currentLevel >= 2 && typeRoll < 25
        let runner = !heavy && currentLevel >= 1 && typeRoll < 55
        let radius: CGFloat = heavy ? 31 : (runner ? 21 : 25)
        let enemy = SKShapeNode(circleOfRadius: radius)
        enemy.name = heavy ? "enemyHeavy" : (runner ? "enemyRunner" : "enemy")
        enemy.position = CGPoint(x: size.width + 35, y: CGFloat.random(in: 95...size.height * 0.53))
        let swimming = isWaterChapter && Bool.random()
        if isWaterChapter {
            enemy.name = swimming ? "enemySwimmer" : "enemyBoatRaider"
            enemy.position = swimming
                ? CGPoint(x: CGFloat.random(in: 80...(size.width - 80)), y: 48)
                : CGPoint(x: Bool.random() ? -45 : size.width + 45, y: CGFloat.random(in: 125...size.height * 0.52))
        }
        enemy.zPosition = 15
        enemy.fillColor = SKColor(white: 0.03, alpha: 0.96)
        enemy.strokeColor = heavy ? .systemOrange : (runner ? .systemGreen : .systemRed)
        enemy.lineWidth = heavy ? 5 : (runner ? 4 : 3)
        let enemyHP = heavy ? 9 + currentLevel : (runner ? 1 + currentLevel / 3 : 2 + currentLevel / 2)
        enemy.userData = ["hp": enemyHP, "waterEnemy": isWaterChapter, "swimming": swimming]

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

        if isWaterChapter {
            if swimming {
                let waterMark = SKShapeNode(ellipseOf: CGSize(width: 82, height: 24))
                waterMark.position.y = -52
                waterMark.fillColor = SKColor.systemCyan.withAlphaComponent(0.18)
                waterMark.strokeColor = .cyan
                waterMark.lineWidth = 3
                waterMark.zPosition = -4
                waterMark.run(.repeatForever(.sequence([.scaleX(to: 1.25, duration: 0.35), .scaleX(to: 0.82, duration: 0.35)])))
                enemy.addChild(waterMark)
                for side: CGFloat in [-1, 1] {
                    let splash = SKShapeNode(circleOfRadius: 5)
                    splash.position = CGPoint(x: side * 30, y: -49)
                    splash.fillColor = .white
                    splash.strokeColor = .cyan
                    splash.alpha = 0.7
                    splash.run(.repeatForever(.sequence([.moveBy(x: side * 9, y: 8, duration: 0.28), .moveBy(x: -side * 9, y: -8, duration: 0), .wait(forDuration: 0.2)])))
                    enemy.addChild(splash)
                }
            } else {
                let boat = makeEnemyAssaultBoat()
                boat.position.y = -72
                boat.zPosition = -4
                enemy.addChild(boat)
            }
            let badge = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            badge.name = "waterEnemyBadge"
            badge.text = swimming ? "游泳丧尸" : "敌船登船者"
            badge.fontSize = 9
            badge.fontColor = swimming ? .cyan : .systemOrange
            badge.position = CGPoint(x: 0, y: -radius - 15)
            badge.zPosition = 3
            enemy.addChild(badge)
        }

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

    private func makeEnemyAssaultBoat() -> SKNode {
        let boat = SKNode()
        boat.name = "enemyAssaultBoat"
        let hullPath = CGMutablePath()
        hullPath.move(to: CGPoint(x: -68, y: 10))
        hullPath.addLine(to: CGPoint(x: 66, y: 10))
        hullPath.addLine(to: CGPoint(x: 48, y: -24))
        hullPath.addLine(to: CGPoint(x: -52, y: -24))
        hullPath.closeSubpath()
        let hull = SKShapeNode(path: hullPath)
        hull.fillColor = SKColor(red: 0.12, green: 0.13, blue: 0.12, alpha: 1)
        hull.strokeColor = .systemOrange
        hull.lineWidth = 3
        boat.addChild(hull)
        let lowerHull = SKShapeNode(rectOf: CGSize(width: 104, height: 10), cornerRadius: 4)
        lowerHull.position = CGPoint(x: -2, y: -19)
        lowerHull.fillColor = SKColor(white: 0.055, alpha: 1)
        lowerHull.strokeColor = .systemRed
        lowerHull.lineWidth = 2
        boat.addChild(lowerHull)
        for x in [-42, -18, 6, 30] as [CGFloat] {
            let rib = SKShapeNode(rectOf: CGSize(width: 3, height: 28))
            rib.position = CGPoint(x: x, y: -6)
            rib.fillColor = .darkGray
            rib.strokeColor = .clear
            boat.addChild(rib)
        }
        let cabin = SKShapeNode(rectOf: CGSize(width: 48, height: 25), cornerRadius: 6)
        cabin.position = CGPoint(x: 5, y: 21)
        cabin.fillColor = .darkGray
        cabin.strokeColor = .systemRed
        boat.addChild(cabin)
        let window = SKShapeNode(rectOf: CGSize(width: 29, height: 10), cornerRadius: 3)
        window.fillColor = SKColor(red: 0.35, green: 0.08, blue: 0.04, alpha: 1)
        window.strokeColor = .systemOrange
        cabin.addChild(window)
        let roof = SKShapeNode(rectOf: CGSize(width: 60, height: 5), cornerRadius: 2)
        roof.position = CGPoint(x: 5, y: 35)
        roof.fillColor = .black
        roof.strokeColor = .systemOrange
        boat.addChild(roof)
        let mast = SKShapeNode(rectOf: CGSize(width: 4, height: 28), cornerRadius: 2)
        mast.position = CGPoint(x: -15, y: 50)
        mast.fillColor = .gray
        mast.strokeColor = .white
        boat.addChild(mast)
        let warningLamp = SKShapeNode(circleOfRadius: 4)
        warningLamp.position.y = 16
        warningLamp.fillColor = .systemRed
        warningLamp.strokeColor = .white
        warningLamp.glowWidth = 5
        warningLamp.run(.repeatForever(.sequence([.fadeAlpha(to: 0.25, duration: 0.18), .fadeAlpha(to: 1, duration: 0.18)])))
        mast.addChild(warningLamp)
        let deckGun = SKShapeNode(rectOf: CGSize(width: 42, height: 7), cornerRadius: 3)
        deckGun.position = CGPoint(x: 49, y: 23)
        deckGun.fillColor = .darkGray
        deckGun.strokeColor = .systemYellow
        boat.addChild(deckGun)
        let bowPlate = SKShapeNode(rectOf: CGSize(width: 12, height: 30), cornerRadius: 3)
        bowPlate.position = CGPoint(x: 58, y: -5)
        bowPlate.zRotation = -0.22
        bowPlate.fillColor = SKColor(red: 0.25, green: 0.08, blue: 0.04, alpha: 1)
        bowPlate.strokeColor = .systemOrange
        boat.addChild(bowPlate)
        let wake = SKShapeNode(ellipseOf: CGSize(width: 155, height: 20))
        wake.position.y = -25
        wake.fillColor = SKColor.white.withAlphaComponent(0.08)
        wake.strokeColor = SKColor.white.withAlphaComponent(0.45)
        wake.zPosition = -1
        wake.run(.repeatForever(.sequence([.scaleX(to: 1.18, duration: 0.4), .scaleX(to: 0.86, duration: 0.4)])))
        boat.addChild(wake)
        for side in [-1, 1] as [CGFloat] {
            let spray = SKShapeNode(ellipseOf: CGSize(width: 34, height: 8))
            spray.position = CGPoint(x: -58, y: -18 + side * 11)
            spray.fillColor = SKColor.white.withAlphaComponent(0.28)
            spray.strokeColor = .cyan
            spray.alpha = 0.7
            spray.run(.repeatForever(.sequence([.moveBy(x: -18, y: side * 5, duration: 0.25), .fadeOut(withDuration: 0.18), .moveBy(x: 18, y: -side * 5, duration: 0), .fadeIn(withDuration: 0)])))
            boat.addChild(spray)
        }
        return boat
    }

    private func spawnWave() {
        let count = enemiesToSpawn
        for index in 0..<count {
            run(.sequence([.wait(forDuration: Double(index) * 0.72), .run { [weak self] in self?.spawnEnemy() }]))
        }
        let chestCount = min(4, 2 + currentLevel / 3)
        let waveLevel = usesSurvivalWaves ? 1000 + survivalWave : (gameMode == .defense ? 2000 + defenseFort * 10 + defenseWave : currentLevel * 10 + taskWave)
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
        if weapon.isEnergyWeapon {
            let charge = weapon == .laserEmitter ? laserCharge : ionCharge
            guard charge >= 1 else {
                showToast("\(weapon.name)充能中 · \(Int(charge * 100))%", color: weapon == .laserEmitter ? .systemCyan : .systemPurple)
                return
            }
            if weapon == .laserEmitter {
                laserCharge = 0
                fireLaser(dx: dx, dy: dy)
            } else {
                ionCharge = 0
                launchIonCharge(toward: target.position)
            }
            updateHUD()
            return
        }
        if weapon.isThrownMelee {
            launchThrownMelee(weapon, toward: target)
            return
        }
        if weapon.isMelee {
            if distance < 125 {
                run(kickSound)
                hit(target, damage: weapon.damage)
                pulse(at: target.position, color: weapon == .plasmaBlade ? .cyan : .systemOrange, radius: weapon == .plasmaBlade ? 78 : (weapon == .katana ? 52 : 42))
                weaponSprite?.run(.sequence([
                    .rotate(byAngle: -0.72, duration: 0.10),
                    .rotate(byAngle: 0.72, duration: 0.18)
                ]))
                updateHUD()
            }
            return
        }
        guard ammo[weapon, default: 0] > 0 else { showToast("弹药耗尽，寻找空投！", color: .systemRed); return }
        ammo[weapon, default: 0] -= 1
        switch weapon {
        case .shotgun: run(shotgunSound)
        case .thompson: run(thompsonSound)
        case .barrett: run(barrettSound)
        case .rpg: run(barrettSound)
        default: run(pistolSound)
        }
        updateHUD()
        if weapon == .rpg {
            launchRocket(toward: target.position)
            pulse(at: CGPoint(x: player.position.x + cos(player.zRotation) * 78, y: player.position.y + sin(player.zRotation) * 78), color: .systemOrange, radius: 28)
            return
        }
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

    private func releasePlasmaBladeUltimate() {
        guard weapon == .plasmaBlade, plasmaBladeCharge >= 1 else {
            let seconds = Int(ceil((1 - plasmaBladeCharge) * 15))
            showToast("等离子大刀大招冷却中 · \(seconds)秒", color: .systemBlue)
            return
        }
        plasmaBladeCharge = 0
        run(explosionSound)
        let radius: CGFloat = 215
        let targets = world.children.filter {
            $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) <= radius
        }
        for enemy in targets { hit(enemy, damage: 22) }
        for index in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: 44 + CGFloat(index) * 18)
            ring.position = player.position
            ring.fillColor = .clear
            ring.strokeColor = index.isMultiple(of: 2) ? .systemCyan : .systemPurple
            ring.lineWidth = 8 - CGFloat(index)
            ring.glowWidth = 13
            ring.zPosition = 48
            world.addChild(ring)
            ring.run(.sequence([.wait(forDuration: Double(index) * 0.06), .group([.scale(to: 3.1, duration: 0.34), .fadeOut(withDuration: 0.34)]), .removeFromParent()]))
        }
        weaponSprite?.run(.sequence([.rotate(byAngle: .pi * 2, duration: 0.32), .scale(to: 1.18, duration: 0.08), .scale(to: 1, duration: 0.10)]))
        updateHUD()
        showToast("等离子风暴 · 范围斩击", color: .systemCyan)
    }

    private func handleHeldFire(at currentTime: TimeInterval) {
        guard fireTouch != nil else { return }
        if weapon == .plasmaBlade,
           !plasmaUltimateTriggered,
           currentTime - firePressStartedAt >= 0.8 {
            plasmaUltimateTriggered = true
            releasePlasmaBladeUltimate()
        }
        fire(now: currentTime)
    }

    private func fireLaser(dx: CGFloat, dy: CGFloat) {
        let length = max(1, hypot(dx, dy))
        let ux = dx / length, uy = dy / length
        let end = CGPoint(x: player.position.x + ux * 1100, y: player.position.y + uy * 1100)
        let path = CGMutablePath()
        path.move(to: player.position)
        path.addLine(to: end)
        let beam = SKShapeNode(path: path)
        beam.strokeColor = .cyan
        beam.lineWidth = 9
        beam.glowWidth = 14
        beam.zPosition = 42
        world.addChild(beam)
        run(barrettSound)
        let enemies = world.children.filter { $0.name?.hasPrefix("enemy") == true }
        for enemy in enemies {
            let ex = enemy.position.x - player.position.x
            let ey = enemy.position.y - player.position.y
            let forward = ex * ux + ey * uy
            let perpendicular = abs(ex * uy - ey * ux)
            if forward > 0, perpendicular < 34 { hit(enemy, damage: Weapon.laserEmitter.damage) }
        }
        pulse(at: CGPoint(x: player.position.x + ux * 72, y: player.position.y + uy * 72), color: .cyan, radius: 38)
        beam.run(.sequence([.fadeOut(withDuration: 0.22), .removeFromParent()]))
    }

    private func launchIonCharge(toward destination: CGPoint) {
        let orb = SKShapeNode(circleOfRadius: 18)
        orb.fillColor = .systemPurple
        orb.strokeColor = .white
        orb.lineWidth = 4
        orb.glowWidth = 16
        orb.position = player.position
        orb.zPosition = 43
        world.addChild(orb)
        let distance = hypot(destination.x - player.position.x, destination.y - player.position.y)
        orb.run(.sequence([
            .group([.move(to: destination, duration: TimeInterval(distance / 480)), .rotate(byAngle: .pi * 5, duration: TimeInterval(distance / 480))]),
            .run { [weak self, weak orb] in
                guard let self else { return }
                orb?.removeFromParent()
                self.run(self.explosionSound)
                self.pulse(at: destination, color: .systemPurple, radius: 185)
                let enemies = self.world.children.filter { $0.name?.hasPrefix("enemy") == true }
                for enemy in enemies where hypot(enemy.position.x - destination.x, enemy.position.y - destination.y) <= 185 {
                    self.hit(enemy, damage: Weapon.ionCannon.damage)
                }
                self.launchIonSubmunitions(from: destination)
            }
        ]))
    }

    private func launchIonSubmunitions(from origin: CGPoint) {
        let nearbyTargets = world.children
            .filter { $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - origin.x, $0.position.y - origin.y) <= 460 }
            .sorted { hypot($0.position.x - origin.x, $0.position.y - origin.y) < hypot($1.position.x - origin.x, $1.position.y - origin.y) }
        let childCount = 8
        for index in 0..<childCount {
            let angle: CGFloat
            if index < nearbyTargets.count {
                let target = nearbyTargets[index].position
                angle = atan2(target.y - origin.y, target.x - origin.x)
            } else {
                angle = CGFloat(index) * (.pi * 2 / CGFloat(childCount))
            }
            let child = SKShapeNode(circleOfRadius: 7)
            child.name = "bullet"
            child.userData = ["damage": 5]
            child.position = origin
            child.fillColor = index.isMultiple(of: 2) ? .systemPurple : .systemBlue
            child.strokeColor = .white
            child.lineWidth = 2
            child.glowWidth = 9
            child.zPosition = 44
            child.physicsBody = SKPhysicsBody(circleOfRadius: 7)
            child.physicsBody?.affectedByGravity = false
            child.physicsBody?.categoryBitMask = Mask.bullet
            child.physicsBody?.contactTestBitMask = Mask.enemy
            child.physicsBody?.collisionBitMask = 0
            child.physicsBody?.velocity = CGVector(dx: cos(angle) * 560, dy: sin(angle) * 560)
            world.addChild(child)
            child.run(.sequence([
                .group([.scale(to: 0.55, duration: 0.75), .fadeOut(withDuration: 0.75)]),
                .removeFromParent()
            ]))
        }
        pulse(at: origin, color: .systemBlue, radius: 245)
        showToast("离子母弹分裂 · 8枚定向子弹", color: .systemPurple)
    }

    private func launchThrownMelee(_ item: Weapon, toward target: SKNode) {
        let projectile = thrownWeaponNode(for: item)
        projectile.name = item == .throwingKnife ? "throwingKnife" : "boomerang"
        projectile.position = player.position
        projectile.zPosition = 35
        let destination = target.position
        let distance = max(1, hypot(destination.x - player.position.x, destination.y - player.position.y))
        projectile.zRotation = atan2(destination.y - player.position.y, destination.x - player.position.x)
        world.addChild(projectile)
        run(kickSound)

        if item == .throwingKnife {
            projectile.run(.sequence([
                .move(to: destination, duration: TimeInterval(distance / 720)),
                .run { [weak self, weak target] in
                    if let target { self?.hit(target, damage: item.damage) }
                    self?.pulse(at: destination, color: .white, radius: 30)
                },
                .fadeOut(withDuration: 0.10),
                .removeFromParent()
            ]))
        } else {
            let outward = SKAction.group([
                .move(to: destination, duration: TimeInterval(distance / 520)),
                .rotate(byAngle: .pi * 7, duration: TimeInterval(distance / 520))
            ])
            projectile.run(.sequence([
                outward,
                .run { [weak self] in
                    guard let self else { return }
                    self.world.children.filter { $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - destination.x, $0.position.y - destination.y) < 92 }.forEach {
                        self.hit($0, damage: item.damage)
                    }
                    self.pulse(at: destination, color: .systemTeal, radius: 72)
                },
                .group([
                    .move(to: player.position, duration: TimeInterval(distance / 620)),
                    .rotate(byAngle: .pi * 7, duration: TimeInterval(distance / 620))
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func launchRocket(toward destination: CGPoint) {
        let rocket = SKNode()
        rocket.name = "rpgRocket"
        rocket.position = player.position
        rocket.zPosition = 34
        let dx = destination.x - player.position.x
        let dy = destination.y - player.position.y
        let distance = max(1, hypot(dx, dy))
        rocket.zRotation = atan2(dy, dx)

        let body = SKShapeNode(rectOf: CGSize(width: 34, height: 10), cornerRadius: 4)
        body.fillColor = SKColor(red: 0.27, green: 0.32, blue: 0.20, alpha: 1)
        body.strokeColor = .black
        body.lineWidth = 2
        rocket.addChild(body)
        let nosePath = CGMutablePath()
        nosePath.move(to: CGPoint(x: 17, y: 7))
        nosePath.addLine(to: CGPoint(x: 28, y: 0))
        nosePath.addLine(to: CGPoint(x: 17, y: -7))
        nosePath.closeSubpath()
        let nose = SKShapeNode(path: nosePath)
        nose.fillColor = .systemOrange
        nose.strokeColor = .black
        rocket.addChild(nose)
        let flame = SKShapeNode(circleOfRadius: 6)
        flame.position.x = -22
        flame.fillColor = .systemYellow
        flame.strokeColor = .systemOrange
        flame.glowWidth = 5
        rocket.addChild(flame)
        world.addChild(rocket)

        let duration = TimeInterval(distance / 430)
        rocket.run(.sequence([
            .move(to: destination, duration: duration),
            .run { [weak self, weak rocket] in
                rocket?.removeFromParent()
                self?.explodeRocket(at: destination)
            }
        ]))
    }

    private func explodeRocket(at position: CGPoint) {
        run(explosionSound)
        pulse(at: position, color: .systemOrange, radius: 138)
        let targets = world.children.filter {
            $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - position.x, $0.position.y - position.y) <= 138
        }
        for enemy in targets { hit(enemy, damage: Weapon.rpg.damage) }
        showToast("RPG爆炸：范围伤害", color: .systemOrange)
    }

    private func kick(now: TimeInterval) {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen, !isKicking, now - lastKick > 0.8 else { return }
        guard let target = nearestEnemy() else { return }
        let dx = target.position.x - player.position.x
        let dy = target.position.y - player.position.y
        let distance = max(1, hypot(dx, dy))
        guard distance < 105 else { showToast("距离太远，无法踢击", color: .systemOrange); return }
        guard let leg = player.childNode(withName: "playerLegRight") else { return }
        lastKick = now
        isKicking = true
        player.zRotation = atan2(dy, dx)
        let level = trainingLevels[.kick, default: 0]
        let damage = 2 + level * 2
        let push = CGFloat(42 + level * 18)

        let trailPath = CGMutablePath()
        trailPath.addArc(center: CGPoint(x: 0, y: -50), radius: 68, startAngle: -1.25, endAngle: 0.18, clockwise: false)
        let trail = SKShapeNode(path: trailPath)
        trail.strokeColor = .systemOrange
        trail.lineWidth = 6
        trail.glowWidth = 4
        trail.alpha = 0
        trail.zPosition = 4
        player.addChild(trail)
        trail.run(.sequence([.fadeIn(withDuration: 0.07), .fadeOut(withDuration: 0.25), .removeFromParent()]))

        let torso = player.childNode(withName: "playerTorso")
        torso?.run(.sequence([.moveBy(x: 7, y: 3, duration: 0.10), .moveBy(x: -7, y: -3, duration: 0.20)]))
        let extend = SKAction.group([
            .move(to: CGPoint(x: 48, y: -61), duration: 0.13),
            .rotate(toAngle: -0.92, duration: 0.13, shortestUnitArc: true),
            .scaleY(to: 1.18, duration: 0.13)
        ])
        extend.timingMode = .easeOut
        let retract = SKAction.group([
            .move(to: CGPoint(x: 11, y: -87), duration: 0.20),
            .rotate(toAngle: 0, duration: 0.20, shortestUnitArc: true),
            .scaleY(to: 1, duration: 0.20)
        ])
        retract.timingMode = .easeIn
        leg.run(.sequence([
            extend,
            .run { [weak self, weak target] in
                guard let self, let target, target.parent != nil else { return }
                let impactDX = target.position.x - self.player.position.x
                let impactDY = target.position.y - self.player.position.y
                let impactDistance = max(1, hypot(impactDX, impactDY))
                guard impactDistance < 125 else { return }
                target.position.x += impactDX / impactDistance * push
                target.position.y += impactDY / impactDistance * push
                self.run(self.kickSound)
                self.hit(target, damage: damage)
                self.pulse(at: target.position, color: .systemOrange, radius: 38 + CGFloat(level) * 5)
            },
            retract,
            .run { [weak self] in self?.isKicking = false }
        ]))
    }

    private func useMedicalKit() {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        guard medicalKits > 0 else { showToast("医疗包不足，可从空投或商店补给", color: .systemRed); return }
        guard health < maxHealth else { showToast("生命值已满，未消耗医疗包", color: .systemGreen); return }
        let before = health
        health = min(maxHealth, health + 50)
        medicalKits -= 1
        updateHUD()
        pulse(at: player.position, color: .systemGreen, radius: 48)
        showToast("使用医疗包：生命 +\(health - before)", color: .systemGreen)
    }

    private func useStimulant() {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        guard stimulantShots > 0 else { showToast("体力针不足，可从空投或商店补给", color: .systemRed); return }
        guard stimulantRemaining <= 0 else { showToast("速度强化仍在生效", color: .systemBlue); return }
        stimulantShots -= 1
        stimulantRemaining = 30
        updateHUD()
        pulse(at: player.position, color: .systemBlue, radius: 52)
        showToast("注射体力针：30秒内速度 +50%", color: .systemBlue)
    }

    private func toggleJetpack() {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        let index = activeAccountIndex
        guard accounts[index].jetpackUnlocked else { showToast("请先在行动大厅制造喷气背包", color: .systemOrange); return }
        guard !jetpackActive else { showToast("本次喷射尚未结束", color: .systemCyan); return }
        if jetpackBurstsRemaining <= 0 {
            guard accounts[index].jetpackBatteries > 0 else { showToast("电池耗尽，请在大厅制造新电池", color: .systemRed); return }
            accounts[index].jetpackBatteries -= 1
            jetpackBurstsRemaining = 10
            saveAccounts()
            showToast("已装入新电池 · 可喷射10次", color: .systemYellow)
        }
        jetpackBurstsRemaining -= 1
        jetpackBatteryRemaining = 1.8
        jetpackActive = true
        showJetpackFlame()
        updateJetpackHUD()
        pulse(at: player.position, color: .systemOrange, radius: 45)
    }

    private func deactivateJetpack() {
        jetpackActive = false
        jetpackFlame?.removeFromParent()
        jetpackFlame = nil
        updateJetpackHUD()
    }

    private func showJetpackFlame() {
        jetpackFlame?.removeFromParent()
        let flameRoot = SKNode()
        flameRoot.name = "jetpackFlame"
        flameRoot.position = CGPoint(x: -29, y: -45)
        flameRoot.zPosition = 1
        for y in [-10, 10] as [CGFloat] {
            let flame = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
            flame.position.y = y
            flame.fillColor = .systemYellow
            flame.strokeColor = .systemOrange
            flame.glowWidth = 5
            flame.run(.repeatForever(.sequence([.scaleX(to: 1.45, duration: 0.10), .scaleX(to: 0.72, duration: 0.10)])))
            flameRoot.addChild(flame)
        }
        player.addChild(flameRoot)
        jetpackFlame = flameRoot
    }

    private func beginGrenadePlacement() {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        guard grenades > 0 else { showToast("手榴弹不足，可从空投或商店补给", color: .systemRed); return }
        grenadePlacementOpen = true
        queuedGrenadeDestinations.removeAll()
        gamePaused = true
        stopControls()
        world.isPaused = true
        speed = 0

        let overlay = SKNode()
        overlay.name = "grenadePlacementUI"
        overlay.zPosition = 600
        let dim = SKShapeNode(rectOf: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = .black
        dim.strokeColor = .clear
        dim.alpha = 0.25
        overlay.addChild(dim)

        let destination = nearestEnemy()?.position ?? CGPoint(x: min(size.width - 70, player.position.x + 180), y: player.position.y)
        let landing = SKShapeNode(circleOfRadius: 115)
        landing.name = "grenadeTarget"
        landing.position = destination
        landing.fillColor = SKColor.systemRed.withAlphaComponent(0.12)
        landing.strokeColor = .systemRed
        landing.lineWidth = 3
        landing.alpha = 0.88
        let cross = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        cross.text = "＋"
        cross.fontSize = 25
        cross.fontColor = .systemRed
        cross.position.y = -9
        landing.addChild(cross)
        overlay.addChild(landing)
        grenadePlacementGhost = landing

        let hint = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hint.name = "grenadePlacementHint"
        hint.text = "拖动红色范围选择手榴弹落点 · 剩余\(grenades)"
        hint.fontSize = 18
        hint.fontColor = .systemYellow
        hint.position = CGPoint(x: size.width / 2, y: size.height - 47)
        overlay.addChild(hint)
        addPlacementButton(to: overlay, name: "confirmGrenade", text: "确认投掷", position: CGPoint(x: size.width - 95, y: 44), color: .systemGreen)
        addPlacementButton(to: overlay, name: "cancelGrenade", text: "取消", position: CGPoint(x: size.width - 215, y: 44), color: .systemRed)
        addPlacementButton(to: overlay, name: "toggleGrenadeContinuous", text: continuousGrenadePlacement ? "连续：开" : "连续：关", position: CGPoint(x: size.width - 335, y: 44), color: continuousGrenadePlacement ? .systemBlue : .darkGray)
        addChild(overlay)
        updateGrenadePlacement(destination)
    }

    private func launchGrenade(at destination: CGPoint) {
        let path = CGMutablePath()
        path.move(to: player.position)
        let control = CGPoint(x: (player.position.x + destination.x) / 2, y: max(player.position.y, destination.y) + 88)
        path.addQuadCurve(to: destination, control: control)

        let indicator = SKNode()
        indicator.name = "grenadeAim"
        indicator.zPosition = 34
        let arc = SKShapeNode(path: path)
        arc.strokeColor = .systemYellow
        arc.lineWidth = 3
        arc.alpha = 0.72
        arc.glowWidth = 2
        indicator.addChild(arc)
        let landing = SKShapeNode(circleOfRadius: 115)
        landing.position = destination
        landing.fillColor = SKColor.systemRed.withAlphaComponent(0.10)
        landing.strokeColor = .systemRed
        landing.lineWidth = 3
        landing.alpha = 0.82
        indicator.addChild(landing)
        let cross = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        cross.text = "＋"
        cross.fontSize = 25
        cross.fontColor = .systemRed
        cross.position = CGPoint(x: destination.x, y: destination.y - 9)
        indicator.addChild(cross)
        world.addChild(indicator)

        let grenade = SKShapeNode(circleOfRadius: 9)
        grenade.fillColor = .darkGray
        grenade.strokeColor = .systemGreen
        grenade.lineWidth = 3
        grenade.position = player.position
        grenade.zPosition = 36
        world.addChild(grenade)
        grenade.run(.sequence([
            .group([.follow(path, asOffset: false, orientToPath: true, duration: 0.55), .rotate(byAngle: .pi * 3, duration: 0.55)]),
            .wait(forDuration: 0.25),
            .run { [weak self, weak grenade, weak indicator] in
                grenade?.removeFromParent()
                indicator?.removeFromParent()
                self?.explodeGrenade(at: destination)
            }
        ]))
    }

    private func confirmGrenadePlacement() {
        guard grenadePlacementOpen, let destination = grenadePlacementGhost?.position else { return }
        grenades -= 1
        if continuousGrenadePlacement {
            queuedGrenadeDestinations.append(destination)
            updateHUD()
            if grenades > 0 {
                let next = CGPoint(x: min(size.width - 115, destination.x + 55), y: max(115, destination.y - 20))
                updateGrenadePlacement(next)
                (childNode(withName: "grenadePlacementUI")?.childNode(withName: "grenadePlacementHint") as? SKLabelNode)?.text = "继续选择落点 · 已排队\(queuedGrenadeDestinations.count)枚 · 剩余\(grenades)"
                return
            }
        } else {
            queuedGrenadeDestinations = [destination]
        }
        finishGrenadePlacement()
        updateHUD()
        launchQueuedGrenades()
    }

    private func cancelGrenadePlacement() {
        guard grenadePlacementOpen else { return }
        finishGrenadePlacement()
        if queuedGrenadeDestinations.isEmpty {
            showToast("已取消投掷，未消耗手榴弹", color: .lightGray)
        } else {
            launchQueuedGrenades()
        }
    }

    private func launchQueuedGrenades() {
        let destinations = queuedGrenadeDestinations
        queuedGrenadeDestinations.removeAll()
        var actions: [SKAction] = []
        for destination in destinations {
            actions.append(.run { [weak self] in self?.launchGrenade(at: destination) })
            actions.append(.wait(forDuration: 0.24))
        }
        run(.sequence(actions))
        showToast("连续投掷 \(destinations.count) 枚手榴弹", color: .systemOrange)
    }

    private func toggleGrenadeContinuousMode() {
        continuousGrenadePlacement.toggle()
        guard let button = childNode(withName: "grenadePlacementUI")?.childNode(withName: "toggleGrenadeContinuous") as? SKShapeNode else { return }
        button.fillColor = continuousGrenadePlacement ? .systemBlue : .darkGray
        (button.childNode(withName: "toggleGrenadeContinuous") as? SKLabelNode)?.text = continuousGrenadePlacement ? "连续：开" : "连续：关"
    }

    private func finishGrenadePlacement() {
        childNode(withName: "grenadePlacementUI")?.removeFromParent()
        grenadePlacementGhost = nil
        grenadePlacementTouch = nil
        grenadePlacementOpen = false
        gamePaused = false
        world.isPaused = false
        speed = 1
        lastUpdate = 0
    }

    private func updateGrenadePlacement(_ point: CGPoint) {
        let destination = CGPoint(
            x: max(115, min(size.width - 115, point.x)),
            y: max(115, min(size.height * 0.68, point.y))
        )
        grenadePlacementGhost?.position = destination
        guard let overlay = childNode(withName: "grenadePlacementUI") else { return }
        overlay.childNode(withName: "grenadePreviewArc")?.removeFromParent()
        let path = CGMutablePath()
        path.move(to: player.position)
        let control = CGPoint(x: (player.position.x + destination.x) / 2, y: max(player.position.y, destination.y) + 88)
        path.addQuadCurve(to: destination, control: control)
        let arc = SKShapeNode(path: path)
        arc.name = "grenadePreviewArc"
        arc.strokeColor = .systemYellow
        arc.lineWidth = 3
        arc.glowWidth = 2
        arc.alpha = 0.82
        overlay.addChild(arc)
    }

    private func explodeGrenade(at position: CGPoint) {
        run(explosionSound)
        pulse(at: position, color: .systemRed, radius: 115)
        let targets = world.children.filter {
            $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - position.x, $0.position.y - position.y) <= 115
        }
        for enemy in targets { hit(enemy, damage: 5) }
        showToast("手榴弹爆炸：范围伤害", color: .systemOrange)
    }

    private func beginAirstrikePlacement() {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        guard activeAccount.level >= 7 else { showToast("呼叫空袭在 Lv.7 解锁", color: .systemOrange); return }
        guard airstrikes > 0 else { showToast("空袭次数不足，可在商店购买", color: .systemRed); return }
        airstrikePlacementOpen = true
        gamePaused = true
        stopControls()
        world.isPaused = true
        speed = 0

        let overlay = SKNode()
        overlay.name = "airstrikePlacementUI"
        overlay.zPosition = 610
        let dim = SKShapeNode(rectOf: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = .black
        dim.strokeColor = .clear
        dim.alpha = 0.28
        overlay.addChild(dim)
        let target = SKShapeNode(circleOfRadius: 150)
        target.name = "airstrikeTarget"
        target.position = nearestEnemy()?.position ?? CGPoint(x: size.width * 0.62, y: size.height * 0.42)
        target.fillColor = SKColor.systemOrange.withAlphaComponent(0.12)
        target.strokeColor = .systemOrange
        target.lineWidth = 4
        let cross = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        cross.text = "◎"
        cross.fontSize = 42
        cross.fontColor = .systemYellow
        cross.position.y = -14
        target.addChild(cross)
        overlay.addChild(target)
        airstrikePlacementGhost = target
        let hint = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hint.text = "拖动橙色区域选择空袭中心"
        hint.fontSize = 18
        hint.fontColor = .systemOrange
        hint.position = CGPoint(x: size.width / 2, y: size.height - 47)
        overlay.addChild(hint)
        addPlacementButton(to: overlay, name: "confirmAirstrike", text: "确认空袭", position: CGPoint(x: size.width - 95, y: 44), color: .systemOrange)
        addPlacementButton(to: overlay, name: "cancelAirstrike", text: "取消", position: CGPoint(x: size.width - 215, y: 44), color: .systemRed)
        addChild(overlay)
    }

    private func updateAirstrikePlacement(_ point: CGPoint) {
        airstrikePlacementGhost?.position = CGPoint(x: max(150, min(size.width - 150, point.x)), y: max(120, min(size.height * 0.65, point.y)))
    }

    private func confirmAirstrikePlacement() {
        guard airstrikePlacementOpen, let destination = airstrikePlacementGhost?.position else { return }
        airstrikes -= 1
        finishAirstrikePlacement()
        updateHUD()
        launchAirstrike(at: destination)
    }

    private func cancelAirstrikePlacement() {
        guard airstrikePlacementOpen else { return }
        finishAirstrikePlacement()
        showToast("已取消空袭，未消耗次数", color: .lightGray)
    }

    private func finishAirstrikePlacement() {
        childNode(withName: "airstrikePlacementUI")?.removeFromParent()
        airstrikePlacementGhost = nil
        airstrikePlacementOpen = false
        gamePaused = false
        world.isPaused = false
        speed = 1
        lastUpdate = 0
    }

    private func launchAirstrike(at center: CGPoint) {
        showToast("空袭编队已抵达 · 注意爆炸区域", color: .systemOrange)
        let aircraft = SKShapeNode(rectOf: CGSize(width: 78, height: 16), cornerRadius: 7)
        aircraft.fillColor = .darkGray
        aircraft.strokeColor = .systemCyan
        aircraft.position = CGPoint(x: -70, y: size.height * 0.72)
        aircraft.zPosition = 48
        world.addChild(aircraft)
        aircraft.run(.sequence([.moveTo(x: size.width + 80, duration: 1.15), .removeFromParent()]))
        let offsets = [CGPoint(x: -90, y: 25), CGPoint(x: -40, y: -45), CGPoint(x: 10, y: 35), CGPoint(x: 65, y: -20), CGPoint(x: 100, y: 42)]
        for (index, offset) in offsets.enumerated() {
            let point = CGPoint(x: center.x + offset.x, y: center.y + offset.y)
            run(.sequence([.wait(forDuration: 0.42 + Double(index) * 0.18), .run { [weak self] in self?.explodeAirstrikeBomb(at: point) }]))
        }
    }

    private func explodeAirstrikeBomb(at position: CGPoint) {
        run(explosionSound)
        pulse(at: position, color: .systemOrange, radius: 92)
        let targets = world.children.filter { $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - position.x, $0.position.y - position.y) <= 92 }
        for enemy in targets { hit(enemy, damage: 7) }
    }

    private func launchTorpedo() {
        guard isWaterChapter else { showToast("鱼雷仅能在第二章水战使用", color: .systemCyan); return }
        guard torpedoes > 0 else { showToast("鱼雷不足，可在商店补给", color: .systemRed); return }
        guard let target = nearestEnemy() else { showToast("当前没有可锁定目标", color: .lightGray); return }
        torpedoes -= 1
        updateHUD()
        let destination = target.position
        let torpedo = SKShapeNode(rectOf: CGSize(width: 56, height: 13), cornerRadius: 7)
        torpedo.fillColor = .darkGray
        torpedo.strokeColor = .cyan
        torpedo.glowWidth = 5
        torpedo.position = CGPoint(x: 22, y: max(45, destination.y))
        torpedo.zPosition = 38
        world.addChild(torpedo)
        let trail = SKShapeNode(rectOf: CGSize(width: 36, height: 3), cornerRadius: 2)
        trail.position.x = -43
        trail.fillColor = .white
        trail.strokeColor = .clear
        torpedo.addChild(trail)
        let distance = abs(destination.x - torpedo.position.x)
        torpedo.run(.sequence([.move(to: destination, duration: TimeInterval(max(0.25, distance / 620))), .run { [weak self, weak torpedo] in
            torpedo?.removeFromParent()
            self?.explodeTorpedo(at: destination)
        }]))
    }

    private func explodeTorpedo(at position: CGPoint) {
        run(explosionSound)
        pulse(at: position, color: .systemCyan, radius: 130)
        let targets = world.children.filter { $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - position.x, $0.position.y - position.y) <= 130 }
        for enemy in targets { hit(enemy, damage: 10) }
        showToast("鱼雷命中 · 水面范围伤害", color: .systemCyan)
    }

    private func toggleVehicle() {
        guard activeAccount.vehicleUnlocked else { showToast("请先在行动大厅制造载具", color: .systemOrange); return }
        if vehicleActive {
            deactivateVehicle()
            return
        }
        if helicopterActive { deactivateHelicopter() }
        if tankActive { deactivateTank() }
        if hovercraftActive { deactivateHovercraft() }
        if vehicleFuelRemaining <= 0 {
            let index = activeAccountIndex
            guard accounts[index].dieselCanisters > 0 else { showToast("柴油不足，请在商店购买", color: .systemRed); return }
            accounts[index].dieselCanisters -= 1
            vehicleFuelRemaining = 45
            saveAccounts()
        }
        vehicleActive = true
        showVehicleBody()
        updateVehicleHUD()
        showToast("行动载具启动 · 可撞击丧尸", color: .systemGreen)
    }

    private func deactivateVehicle() {
        vehicleActive = false
        vehicleBody?.removeFromParent()
        vehicleBody = nil
        updateVehicleHUD()
    }

    private func showVehicleBody() {
        vehicleBody?.removeFromParent()
        let body = SKShapeNode(rectOf: CGSize(width: 112, height: 66), cornerRadius: 18)
        body.name = "vehicleBody"
        body.fillColor = SKColor(red: 0.06, green: 0.24, blue: 0.13, alpha: 0.88)
        body.strokeColor = .systemGreen
        body.lineWidth = 4
        body.zPosition = 18
        for x in [-43, 43] as [CGFloat] {
            for y in [-31, 31] as [CGFloat] {
                let wheel = SKShapeNode(circleOfRadius: 12)
                wheel.position = CGPoint(x: x, y: y)
                wheel.fillColor = .black
                wheel.strokeColor = .gray
                body.addChild(wheel)
            }
        }
        let hood = SKShapeNode(rectOf: CGSize(width: 48, height: 54), cornerRadius: 10)
        hood.position.x = 42
        hood.fillColor = SKColor(red: 0.08, green: 0.30, blue: 0.16, alpha: 1)
        hood.strokeColor = .systemGreen
        body.addChild(hood)
        let windshield = SKShapeNode(rectOf: CGSize(width: 34, height: 46), cornerRadius: 7)
        windshield.position.x = -13
        windshield.fillColor = SKColor(red: 0.03, green: 0.22, blue: 0.28, alpha: 1)
        windshield.strokeColor = .cyan
        body.addChild(windshield)
        for y in [-18, 18] as [CGFloat] {
            let lamp = SKShapeNode(circleOfRadius: 6)
            lamp.position = CGPoint(x: 57, y: y)
            lamp.fillColor = .systemYellow
            lamp.strokeColor = .white
            lamp.glowWidth = 5
            body.addChild(lamp)
        }
        let bumper = SKShapeNode(rectOf: CGSize(width: 8, height: 70), cornerRadius: 3)
        bumper.position.x = 62
        bumper.fillColor = .darkGray
        bumper.strokeColor = .white
        body.addChild(bumper)
        player.addChild(body)
        vehicleBody = body
    }

    private func buyDiesel() {
        guard activeAccount.vehicleUnlocked else { showToast("请先在大厅制造行动载具", color: .systemOrange); return }
        guard coins >= 45 else { showToast("购买柴油需要45申城币", color: .systemRed); return }
        coins -= 45
        accounts[activeAccountIndex].dieselCanisters += 1
        saveAccounts()
        updateHUD()
        refreshShop()
        showToast("柴油 +1桶 · 每桶可运行45秒", color: .systemYellow)
    }

    private func toggleHelicopter() {
        guard activeAccount.helicopterUnlocked else { showToast("请先在行动大厅制造直升机", color: .systemOrange); return }
        if helicopterActive {
            deactivateHelicopter()
            return
        }
        if vehicleActive { deactivateVehicle() }
        if tankActive { deactivateTank() }
        if hovercraftActive { deactivateHovercraft() }
        if helicopterFuelRemaining <= 0 {
            let index = activeAccountIndex
            guard accounts[index].aviationFuelCanisters > 0 else { showToast("航空燃料不足，请在商店购买", color: .systemRed); return }
            accounts[index].aviationFuelCanisters -= 1
            helicopterFuelRemaining = 40
            saveAccounts()
        }
        helicopterActive = true
        showHelicopterBody()
        updateHelicopterHUD()
        showToast("直升机起飞 · 自动攻击附近目标", color: .systemCyan)
    }

    private func deactivateHelicopter() {
        helicopterActive = false
        helicopterBody?.removeFromParent()
        helicopterBody = nil
        updateHelicopterHUD()
    }

    private func showHelicopterBody() {
        helicopterBody?.removeFromParent()
        let root = SKNode()
        root.name = "helicopterBody"
        root.zPosition = 18
        let cabin = SKShapeNode(ellipseOf: CGSize(width: 112, height: 62))
        cabin.fillColor = SKColor(red: 0.05, green: 0.20, blue: 0.24, alpha: 0.88)
        cabin.strokeColor = .cyan
        cabin.lineWidth = 4
        root.addChild(cabin)
        let tail = SKShapeNode(rectOf: CGSize(width: 76, height: 12), cornerRadius: 5)
        tail.position.x = -78
        tail.fillColor = .darkGray
        tail.strokeColor = .systemCyan
        root.addChild(tail)
        let cockpit = SKShapeNode(ellipseOf: CGSize(width: 52, height: 46))
        cockpit.position.x = 24
        cockpit.fillColor = SKColor(red: 0.02, green: 0.30, blue: 0.38, alpha: 1)
        cockpit.strokeColor = .white
        root.addChild(cockpit)
        for x in [-30, 30] as [CGFloat] {
            let pod = SKShapeNode(rectOf: CGSize(width: 42, height: 12), cornerRadius: 5)
            pod.position = CGPoint(x: x, y: -31)
            pod.fillColor = .darkGray
            pod.strokeColor = .systemOrange
            root.addChild(pod)
        }
        for x in [-34, 34] as [CGFloat] {
            let skid = SKShapeNode(rectOf: CGSize(width: 68, height: 5), cornerRadius: 2)
            skid.position = CGPoint(x: x, y: -47)
            skid.fillColor = .gray
            skid.strokeColor = .white
            root.addChild(skid)
        }
        let rotor = SKShapeNode(rectOf: CGSize(width: 180, height: 5), cornerRadius: 2)
        rotor.name = "helicopterRotor"
        rotor.position.y = 39
        rotor.fillColor = .lightGray
        rotor.strokeColor = .white
        rotor.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.08)))
        root.addChild(rotor)
        let tailRotor = SKShapeNode(rectOf: CGSize(width: 4, height: 38), cornerRadius: 2)
        tailRotor.position = CGPoint(x: -116, y: 0)
        tailRotor.fillColor = .lightGray
        tailRotor.strokeColor = .white
        tailRotor.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.07)))
        root.addChild(tailRotor)
        player.addChild(root)
        helicopterBody = root
    }

    private func buyAviationFuel() {
        guard activeAccount.helicopterUnlocked else { showToast("请先在大厅制造直升机", color: .systemOrange); return }
        guard coins >= 65 else { showToast("购买航空燃料需要65申城币", color: .systemRed); return }
        coins -= 65
        accounts[activeAccountIndex].aviationFuelCanisters += 1
        saveAccounts()
        updateHUD()
        refreshShop()
        showToast("航空燃料 +1桶 · 可飞行40秒", color: .systemCyan)
    }

    private func toggleTank() {
        guard activeAccount.tankUnlocked else { showToast("请先在行动大厅制造榴弹炮坦克", color: .systemOrange); return }
        if tankActive { deactivateTank(); return }
        if vehicleActive { deactivateVehicle() }
        if helicopterActive { deactivateHelicopter() }
        if hovercraftActive { deactivateHovercraft() }
        if tankFuelRemaining <= 0 {
            let index = activeAccountIndex
            guard accounts[index].dieselCanisters > 0 else { showToast("坦克柴油不足，请在商店购买", color: .systemRed); return }
            accounts[index].dieselCanisters -= 1
            tankFuelRemaining = 50
            saveAccounts()
        }
        tankActive = true
        showTankBody()
        updateTankHUD()
        showToast("榴弹炮坦克启动 · 自动轰击敌群", color: .systemOrange)
    }

    private func deactivateTank() {
        tankActive = false
        tankBody?.removeFromParent()
        tankBody = nil
        updateTankHUD()
    }

    private func showTankBody() {
        tankBody?.removeFromParent()
        let root = SKNode()
        root.name = "tankBody"
        root.zPosition = 19
        for y in [-35, 35] as [CGFloat] {
            let track = SKShapeNode(rectOf: CGSize(width: 142, height: 22), cornerRadius: 10)
            track.position.y = y
            track.fillColor = SKColor(white: 0.08, alpha: 1)
            track.strokeColor = .lightGray
            root.addChild(track)
            for x in stride(from: -52 as CGFloat, through: 52, by: 26) {
                let wheel = SKShapeNode(circleOfRadius: 8)
                wheel.position = CGPoint(x: x, y: y)
                wheel.fillColor = .darkGray
                wheel.strokeColor = .systemOrange
                root.addChild(wheel)
            }
        }
        let hull = SKShapeNode(rectOf: CGSize(width: 128, height: 64), cornerRadius: 14)
        hull.fillColor = SKColor(red: 0.18, green: 0.25, blue: 0.10, alpha: 0.96)
        hull.strokeColor = .systemOrange
        hull.lineWidth = 4
        root.addChild(hull)
        let turret = SKShapeNode(ellipseOf: CGSize(width: 72, height: 56))
        turret.fillColor = SKColor(red: 0.24, green: 0.32, blue: 0.12, alpha: 1)
        turret.strokeColor = .systemYellow
        root.addChild(turret)
        let barrel = SKShapeNode(rectOf: CGSize(width: 94, height: 14), cornerRadius: 6)
        barrel.name = "tankBarrel"
        barrel.position.x = 68
        barrel.fillColor = .darkGray
        barrel.strokeColor = .systemOrange
        root.addChild(barrel)
        let muzzle = SKShapeNode(rectOf: CGSize(width: 18, height: 22), cornerRadius: 4)
        muzzle.position.x = 113
        muzzle.fillColor = .black
        muzzle.strokeColor = .systemYellow
        root.addChild(muzzle)
        player.addChild(root)
        tankBody = root
    }

    private func fireTankHowitzer(at enemy: SKNode) {
        let start = player.position
        let destination = enemy.position
        let angle = atan2(destination.y - start.y, destination.x - start.x)
        tankBody?.childNode(withName: "tankBarrel")?.zRotation = angle - player.zRotation
        let shell = SKShapeNode(circleOfRadius: 9)
        shell.name = "tankShell"
        shell.position = start
        shell.fillColor = .systemOrange
        shell.strokeColor = .yellow
        shell.glowWidth = 5
        shell.zPosition = 45
        world.addChild(shell)
        shell.run(.sequence([.move(to: destination, duration: 0.38), .run { [weak self, weak shell] in
            shell?.removeFromParent()
            self?.explodeTankShell(at: destination)
        }]))
    }

    private func explodeTankShell(at position: CGPoint) {
        run(explosionSound)
        pulse(at: position, color: .systemOrange, radius: 115)
        let targets = world.children.filter { $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - position.x, $0.position.y - position.y) <= 115 }
        for enemy in targets { hit(enemy, damage: 9) }
    }

    private func toggleHovercraft() {
        guard isWaterChapter else { showToast("气垫船只能在第二章水战使用", color: .systemCyan); return }
        guard activeAccount.hovercraftUnlocked else { showToast("请先在行动大厅制造双联炮气垫船", color: .systemOrange); return }
        if hovercraftActive { deactivateHovercraft(); return }
        if vehicleActive { deactivateVehicle() }
        if helicopterActive { deactivateHelicopter() }
        if tankActive { deactivateTank() }
        if hovercraftFuelRemaining <= 0 {
            let index = activeAccountIndex
            guard accounts[index].dieselCanisters > 0 else { showToast("气垫船柴油不足，请在商店购买", color: .systemRed); return }
            accounts[index].dieselCanisters -= 1
            hovercraftFuelRemaining = 55
            saveAccounts()
        }
        hovercraftActive = true
        showHovercraftBody()
        updateHovercraftHUD()
        showToast("双联炮气垫船启动 · 自动压制登船丧尸", color: .systemTeal)
    }

    private func deactivateHovercraft() {
        hovercraftActive = false
        hovercraftBody?.removeFromParent()
        hovercraftBody = nil
        updateHovercraftHUD()
    }

    private func showHovercraftBody() {
        hovercraftBody?.removeFromParent()
        let root = SKNode()
        root.name = "hovercraftBody"
        root.zPosition = 20
        let skirt = SKShapeNode(ellipseOf: CGSize(width: 170, height: 92))
        skirt.fillColor = SKColor(white: 0.08, alpha: 0.96)
        skirt.strokeColor = .systemCyan
        skirt.lineWidth = 5
        root.addChild(skirt)
        let deck = SKShapeNode(ellipseOf: CGSize(width: 145, height: 70))
        deck.fillColor = SKColor(red: 0.12, green: 0.30, blue: 0.29, alpha: 1)
        deck.strokeColor = .white
        root.addChild(deck)
        let cabin = SKShapeNode(rectOf: CGSize(width: 52, height: 42), cornerRadius: 10)
        cabin.position.x = -25
        cabin.fillColor = SKColor(red: 0.04, green: 0.20, blue: 0.28, alpha: 1)
        cabin.strokeColor = .systemCyan
        root.addChild(cabin)
        for y in [-20, 20] as [CGFloat] {
            let mount = SKShapeNode(circleOfRadius: 13)
            mount.position = CGPoint(x: 24, y: y)
            mount.fillColor = .darkGray
            mount.strokeColor = .systemYellow
            root.addChild(mount)
            let barrel = SKShapeNode(rectOf: CGSize(width: 58, height: 7), cornerRadius: 3)
            barrel.position = CGPoint(x: 48, y: y)
            barrel.fillColor = .gray
            barrel.strokeColor = .systemOrange
            root.addChild(barrel)
        }
        let fan = SKShapeNode(circleOfRadius: 22)
        fan.position.x = -72
        fan.fillColor = .black
        fan.strokeColor = .systemCyan
        root.addChild(fan)
        let blades = SKShapeNode(rectOf: CGSize(width: 38, height: 5), cornerRadius: 2)
        blades.fillColor = .lightGray
        blades.strokeColor = .clear
        blades.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.08)))
        fan.addChild(blades)
        player.addChild(root)
        hovercraftBody = root
    }

    private func fireHovercraftCannons(at enemy: SKNode) {
        hovercraftBarrelSide *= -1
        let start = CGPoint(x: player.position.x + 48, y: player.position.y + hovercraftBarrelSide * 20)
        let dx = enemy.position.x - start.x
        let dy = enemy.position.y - start.y
        let distance = max(1, hypot(dx, dy))
        let bullet = SKShapeNode(circleOfRadius: 4)
        bullet.name = "bullet"
        bullet.userData = ["damage": 2]
        bullet.position = start
        bullet.fillColor = .systemYellow
        bullet.strokeColor = .white
        bullet.zPosition = 42
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = Mask.bullet
        bullet.physicsBody?.contactTestBitMask = Mask.enemy
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.velocity = CGVector(dx: dx / distance * 760, dy: dy / distance * 760)
        world.addChild(bullet)
        bullet.run(.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
    }

    private func buyTorpedo() {
        guard isWaterChapter else { showToast("鱼雷仅在第二章水战供应", color: .systemCyan); return }
        guard coins >= 70 else { showToast("购买鱼雷需要70申城币", color: .systemRed); return }
        coins -= 70
        torpedoes += 1
        updateHUD()
        refreshShop()
        showToast("鱼雷 +1", color: .systemCyan)
    }

    private func beginTrapPlacement() {
        guard gameStarted, !gameEnded, !gamePaused, !shopOpen, !trainingOpen else { return }
        guard traps > 0 else { showToast("陷阱不足，可从空投或商店补给", color: .systemRed); return }
        trapPlacementOpen = true
        gamePaused = true
        stopControls()
        world.isPaused = true
        speed = 0

        let overlay = SKNode()
        overlay.name = "trapPlacementUI"
        overlay.zPosition = 600
        let dim = SKShapeNode(rectOf: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = .black
        dim.strokeColor = .clear
        dim.alpha = 0.28
        overlay.addChild(dim)
        let ghost = makeTrapNode(name: "trapGhost", preview: true)
        ghost.position = player.position
        ghost.zPosition = 2
        overlay.addChild(ghost)
        trapPlacementGhost = ghost

        let hint = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hint.name = "trapPlacementHint"
        hint.text = "拖动陷阱到目标位置 · 剩余\(traps)"
        hint.fontSize = 18
        hint.fontColor = .systemPurple
        hint.position = CGPoint(x: size.width / 2, y: size.height - 47)
        overlay.addChild(hint)
        addPlacementButton(to: overlay, name: "confirmTrap", text: "放置", position: CGPoint(x: size.width - 95, y: 44), color: .systemGreen)
        addPlacementButton(to: overlay, name: "cancelTrap", text: "取消", position: CGPoint(x: size.width - 215, y: 44), color: .systemRed)
        addPlacementButton(to: overlay, name: "toggleTrapContinuous", text: continuousTrapPlacement ? "连续：开" : "连续：关", position: CGPoint(x: size.width - 335, y: 44), color: continuousTrapPlacement ? .systemBlue : .darkGray)
        addChild(overlay)
    }

    private func addPlacementButton(to parent: SKNode, name: String, text: String, position: CGPoint, color: SKColor) {
        let button = SKShapeNode(rectOf: CGSize(width: 100, height: 42), cornerRadius: 10)
        button.name = name
        button.position = position
        button.fillColor = color
        button.strokeColor = .white
        parent.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = text
        label.fontSize = 17
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func makeTrapNode(name: String, preview: Bool) -> SKShapeNode {
        let trap = SKShapeNode(circleOfRadius: 28)
        trap.name = name
        trap.zPosition = 12
        trap.fillColor = SKColor(red: 0.18, green: 0.05, blue: 0.22, alpha: preview ? 0.48 : 0.72)
        trap.strokeColor = .systemPurple
        trap.lineWidth = preview ? 5 : 3
        for angle in stride(from: CGFloat(0), to: .pi * 2, by: .pi / 3) {
            let spike = SKShapeNode(rectOf: CGSize(width: 4, height: 24), cornerRadius: 2)
            spike.position = CGPoint(x: cos(angle) * 17, y: sin(angle) * 17)
            spike.zRotation = angle
            spike.fillColor = .lightGray
            spike.strokeColor = .clear
            trap.addChild(spike)
        }
        return trap
    }

    private func confirmTrapPlacement() {
        guard trapPlacementOpen, let position = trapPlacementGhost?.position else { return }
        traps -= 1
        trapSerial += 1
        let trap = makeTrapNode(name: "trap_\(trapSerial)", preview: false)
        trap.position = position
        trap.userData = ["uses": 4]
        world.addChild(trap)
        trap.run(.repeatForever(.sequence([.fadeAlpha(to: 0.62, duration: 0.5), .fadeAlpha(to: 1, duration: 0.5)])))
        updateHUD()
        if continuousTrapPlacement, traps > 0 {
            let next = CGPoint(x: min(size.width - 45, position.x + 65), y: position.y)
            trapPlacementGhost?.position = next
            (childNode(withName: "trapPlacementUI")?.childNode(withName: "trapPlacementHint") as? SKLabelNode)?.text = "继续放置 · 剩余\(traps)"
        } else {
            finishTrapPlacement()
            showToast(continuousTrapPlacement ? "连续陷阱放置完成" : "阻拦陷阱已放置", color: .systemPurple)
        }
    }

    private func toggleTrapContinuousMode() {
        continuousTrapPlacement.toggle()
        guard let button = childNode(withName: "trapPlacementUI")?.childNode(withName: "toggleTrapContinuous") as? SKShapeNode else { return }
        button.fillColor = continuousTrapPlacement ? .systemBlue : .darkGray
        (button.childNode(withName: "toggleTrapContinuous") as? SKLabelNode)?.text = continuousTrapPlacement ? "连续：开" : "连续：关"
    }

    private func cancelTrapPlacement() {
        guard trapPlacementOpen else { return }
        finishTrapPlacement()
        showToast("已取消放置，未消耗陷阱", color: .lightGray)
    }

    private func finishTrapPlacement() {
        childNode(withName: "trapPlacementUI")?.removeFromParent()
        trapPlacementGhost = nil
        trapPlacementTouch = nil
        trapPlacementOpen = false
        gamePaused = false
        world.isPaused = false
        speed = 1
        lastUpdate = 0
    }

    private func updateTrapPlacement(_ point: CGPoint) {
        trapPlacementGhost?.position = CGPoint(
            x: max(45, min(size.width - 45, point.x)),
            y: max(88, min(size.height * 0.68, point.y))
        )
    }

    private func triggerTrapIfNeeded(_ enemy: SKNode, at currentTime: TimeInterval) -> Bool {
        guard let trap = world.children.first(where: {
            $0.name?.hasPrefix("trap_") == true && hypot($0.position.x - enemy.position.x, $0.position.y - enemy.position.y) < 46 && enemy.userData?["lastTrap"] as? String != $0.name
        }) else { return true }
        enemy.userData?["lastTrap"] = trap.name
        enemy.userData?["slowedUntil"] = currentTime + 2.4
        let remaining = (trap.userData?["uses"] as? Int ?? 1) - 1
        trap.userData?["uses"] = remaining
        pulse(at: trap.position, color: .systemPurple, radius: 45)
        hit(enemy, damage: 1)
        if remaining <= 0 { trap.removeFromParent() }
        return enemy.name?.hasPrefix("enemy") == true
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

    private func performEnemyDeath(_ enemy: SKNode) {
        guard enemy.parent != nil, enemy.name?.hasPrefix("enemy") == true else { return }
        enemy.name = "dyingZombie"
        enemy.physicsBody = nil
        enemy.removeAllActions()

        let bloodColor = SKColor(red: 0.20, green: 0.63, blue: 0.10, alpha: 0.82)
        let darkBlood = SKColor(red: 0.06, green: 0.29, blue: 0.03, alpha: 0.86)
        let pool = SKShapeNode(ellipseOf: CGSize(width: 82, height: 28))
        pool.name = "zombieBloodPool"
        pool.position = CGPoint(x: enemy.position.x, y: max(72, enemy.position.y - 48))
        pool.fillColor = darkBlood.withAlphaComponent(0.55)
        pool.strokeColor = .clear
        pool.zPosition = enemy.zPosition - 2
        pool.setScale(0.18)
        world.addChild(pool)
        pool.run(.sequence([
            .scale(to: 1, duration: 0.42),
            .wait(forDuration: 1.25),
            .fadeOut(withDuration: 0.65),
            .removeFromParent()
        ]))

        let stains: [(CGPoint, CGFloat)] = [
            (CGPoint(x: -8, y: 7), 5),
            (CGPoint(x: 9, y: -28), 6),
            (CGPoint(x: -14, y: -48), 4),
            (CGPoint(x: 13, y: -69), 5),
            (CGPoint(x: -7, y: -88), 4)
        ]
        for (index, stain) in stains.enumerated() {
            let mark = SKShapeNode(circleOfRadius: stain.1)
            mark.name = "zombieGreenBlood"
            mark.position = stain.0
            mark.fillColor = index.isMultiple(of: 2) ? bloodColor : darkBlood
            mark.strokeColor = .clear
            mark.alpha = 0
            mark.zPosition = 7
            enemy.addChild(mark)
            mark.run(.sequence([.wait(forDuration: Double(index) * 0.035), .fadeIn(withDuration: 0.09)]))
        }

        enemy.childNode(withName: "enemyArmLeft")?.run(.rotate(toAngle: -0.82, duration: 0.28, shortestUnitArc: true))
        enemy.childNode(withName: "enemyArmRight")?.run(.rotate(toAngle: 0.76, duration: 0.28, shortestUnitArc: true))
        enemy.childNode(withName: "enemyLegLeft")?.run(.rotate(toAngle: -0.28, duration: 0.32, shortestUnitArc: true))
        enemy.childNode(withName: "enemyLegRight")?.run(.rotate(toAngle: 0.31, duration: 0.32, shortestUnitArc: true))
        let fallAngle: CGFloat = Int(enemy.position.y).isMultiple(of: 2) ? -.pi / 2 : .pi / 2
        enemy.run(.sequence([
            .group([
                .rotate(toAngle: fallAngle, duration: 0.46, shortestUnitArc: true),
                .moveBy(x: 0, y: -18, duration: 0.46)
            ]),
            .wait(forDuration: 0.85),
            .fadeOut(withDuration: 0.48),
            .removeFromParent()
        ]))
    }

    private func hit(_ enemy: SKNode, damage: Int) {
        guard enemy.parent != nil, let data = enemy.userData else { return }
        let hp = (data["hp"] as? Int ?? 1) - damage
        data["hp"] = hp
        if enemy.name == "enemyBoss", hp > 0 {
            let maxHP = data["maxHP"] as? Int ?? 160
            let ratio = max(0, CGFloat(hp) / CGFloat(maxHP))
            if let fill = enemy.childNode(withName: "//bossHealthFill") as? SKShapeNode {
                fill.xScale = ratio
                fill.fillColor = ratio > 0.66 ? .systemRed : (ratio > 0.33 ? .systemOrange : .systemPurple)
            }
            let oldPhase = data["phase"] as? Int ?? 1
            let newPhase = ratio <= 0.33 ? 3 : (ratio <= 0.66 ? 2 : 1)
            if ratio <= 0.50, data["summoning"] as? Bool != true {
                data["summoning"] = true
                lastBossSummon = lastUpdate
                summonBossMinions(around: enemy, count: 3)
                pulse(at: enemy.position, color: .systemPurple, radius: 155)
                showToast("暴君半血狂暴 · 开始持续召唤小弟", color: .systemRed)
            }
            if newPhase > oldPhase {
                data["phase"] = newPhase
                if let bossShape = enemy as? SKShapeNode {
                    bossShape.strokeColor = newPhase == 2 ? .systemOrange : .systemPurple
                    bossShape.glowWidth = CGFloat(5 + newPhase * 3)
                }
                enemy.childNode(withName: "bossPortrait")?.run(.sequence([.colorize(with: newPhase == 2 ? .systemOrange : .systemPurple, colorBlendFactor: 0.55, duration: 0.25), .scale(to: 1.12, duration: 0.16), .scale(to: 1, duration: 0.16)]))
                pulse(at: enemy.position, color: newPhase == 2 ? .systemOrange : .systemPurple, radius: CGFloat(105 + newPhase * 20))
                showToast("暴君进入第\(newPhase)阶段 · 速度与震击增强", color: newPhase == 2 ? .systemOrange : .systemPurple)
            }
            updateHUD()
        }
        if hp <= 0 {
            let soundTime = ProcessInfo.processInfo.systemUptime
            if !isCurePhase, soundTime - lastZombieCry > 0.16 {
                lastZombieCry = soundTime
                run(zombieCrySound)
            }
            let defeatedHeavy = enemy.name == "enemyHeavy"
            let defeatedBoss = enemy.name == "enemyBoss"
            if isCurePhase {
                convertToAlly(enemy)
            } else {
                performEnemyDeath(enemy)
            }
            kills += 1
            accounts[activeAccountIndex].totalKills += 1
            if accounts[activeAccountIndex].totalKills >= 1000 { unlockCollectible("龙息霰弹枪", announce: false) }
            saveAccounts()
            if gameMode == .defense { defenseResolved += 1 }
            if defeatedHeavy {
                let reward = 20 + currentLevel * 6
                coins += reward
                showToast("击败重型丧尸：申城币 +\(reward)", color: .systemYellow)
            }
            if defeatedBoss {
                bossDefeated = true
                accounts[activeAccountIndex].bossMedalUnlocked = true
                accounts[activeAccountIndex].bossDefeats += 1
                if accounts[activeAccountIndex].bossDefeats >= 3 { unlockCollectible("深海斧", announce: false) }
                coins += 500
                accounts[activeAccountIndex].reputation += 20
                saveAccounts()
                grantExperience(300, reason: "击败变异暴君")
                showToast("BOSS击破：申城币 +500 · 声望 +20", color: .systemYellow)
            }
            updateHUD()
            checkLevelCompletion()
        }
    }

    private func checkLevelCompletion() {
        let completedCount = gameMode == .defense ? defenseResolved : kills
        if isBossLevel {
            guard bossDefeated else { return }
        } else {
            guard completedCount >= objectiveCount else { return }
        }
        if usesSurvivalWaves {
            advanceSurvivalWave()
            return
        }
        if gameMode == .defense {
            advanceDefenseWave()
            return
        }
        if isWaterChapter {
            grantExperience(80 + currentLevel * 15, reason: "完成水战第 \(currentLevel + 1) 关")
            if currentLevel < waterLevels.count - 1 {
                currentLevel += 1
                kills = 0
                enemiesToSpawn = waterLevels[currentLevel].enemies
                health = min(maxHealth, health + 15)
                coins += 25 + currentLevel * 5
                world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
                buildBackground()
                updateHUD()
                showToast(isBossLevel ? "第二章最终关 · 海上暴君苏醒" : "第二章 · 进入\(waterLevels[currentLevel].name)", color: isBossLevel ? .systemRed : .systemCyan)
                run(.sequence([.wait(forDuration: transitionDelay), .run { [weak self] in self?.spawnWave() }]))
            } else {
                winGame()
            }
            return
        }
        taskWave = 1
        grantExperience(50 + currentLevel * 10, reason: "完成第 \(currentLevel + 1) 关")
        if currentLevel == 4 {
            if activeAccount.level >= 5 { showAntidoteTransition() }
            else { showAntidoteLevelGate() }
        } else if currentLevel < levels.count - 1 {
            currentLevel += 1
            kills = 0
            enemiesToSpawn = levels[currentLevel].enemies
            if isBossLevel { allies.forEach { $0.removeFromParent() } }
            health = min(maxHealth, health + 12)
            coins += 15 + currentLevel * 3
            world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
            buildBackground()
            showToast(isBossLevel ? "终极 BOSS 关开启 · 变异暴君苏醒" : "进入第 \(currentLevel + 1) 关 · 难度提升", color: isBossLevel ? .systemRed : .cyan)
            updateHUD()
            run(.sequence([.wait(forDuration: transitionDelay), .run { [weak self] in self?.spawnWave() }]))
        } else {
            pendingWaterLevel = 0
            showWaterChapterTransition()
        }
    }

    private func showWaterChapterTransition() {
        gameStarted = false
        stopControls()
        let panel = makePanel(name: "waterChapterIntro", size: CGSize(width: min(640, size.width - 70), height: 240), color: SKColor(red: 0.01, green: 0.10, blue: 0.18, alpha: 0.98), stroke: .systemCyan, z: 360)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = isBossLevel ? "第二章最终关 · 海上巢穴" : "第二章 · 水上撤离线"
        title.fontSize = 32
        title.fontColor = .cyan
        title.position.y = 67
        panel.addChild(title)
        let story = SKLabelNode(fontNamed: "AvenirNext-Regular")
        story.text = isBossLevel ? "撤离线尽头出现巨型变异暴君。\n半血后会持续召唤感染者增援。" : "解药必须经水路送出上海。\n游泳丧尸正从水下攀船，感染者船队也在逼近。"
        story.numberOfLines = 2
        story.fontSize = 17
        story.position.y = 12
        panel.addChild(story)
        let start = SKLabelNode(fontNamed: "AvenirNext-Bold")
        start.name = "startWaterChapter"
        start.text = isBossLevel ? "进入巢穴 · 挑战暴君" : "登船 · 开始水战"
        start.fontSize = 22
        start.fontColor = isBossLevel ? .systemRed : .systemYellow
        start.position.y = -70
        panel.addChild(start)
    }

    private func startWaterChapter() {
        childNode(withName: "waterChapterIntro")?.removeFromParent()
        taskChapter = 2
        currentLevel = pendingWaterLevel
        kills = 0
        enemiesToSpawn = waterLevels[currentLevel].enemies
        torpedoes = max(torpedoes, 2)
        allies.forEach { $0.removeFromParent() }
        gameStarted = true
        startBattleMusic()
        torpedoButton.isHidden = false
        player.position = CGPoint(x: size.width * 0.38, y: size.height * 0.34)
        buildBackground()
        updateHUD()
        showToast("水战开始 · 已配发2枚鱼雷", color: .systemCyan)
        run(.sequence([.wait(forDuration: transitionDelay), .run { [weak self] in self?.spawnWave() }]))
    }

    private func advanceSurvivalWave() {
        if survivalWave >= 20 {
            winGame()
            return
        }
        survivalWave += 1
        currentLevel = min(levels.count - 1, (survivalWave - 1) / 3)
        survivalTarget = 5 + survivalWave
        enemiesToSpawn = survivalTarget
        kills = 0
        health = min(maxHealth, health + 8)
        coins += 12 + survivalWave * 2
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
        updateHUD()
        let waveText = gameMode == .melee ? "刀战第 \(survivalWave)/20 波来袭" : (gameMode == .mech ? "机甲第 \(survivalWave)/20 波来袭" : "尸潮第 \(survivalWave)/20 波来袭")
        showToast(waveText, color: gameMode == .mech ? .systemCyan : (gameMode == .melee ? .systemRed : .systemOrange))
        run(.sequence([.wait(forDuration: transitionDelay), .run { [weak self] in self?.spawnWave() }]))
    }

    private func advanceDefenseWave() {
        if defenseWave >= 5 {
            if defenseFort >= 3 {
                winGame()
                return
            }
            defenseFort += 1
            defenseWave = 1
            fortHealth = 100
            coins += 100
            buildBackground()
            showToast("进入堡垒 \(defenseFort) · 新防线建立", color: .systemYellow)
        } else {
            defenseWave += 1
            fortHealth = min(100, fortHealth + 12)
            coins += 18 + defenseWave * 4
            showToast("堡垒 \(defenseFort) · 第 \(defenseWave)/5 波", color: .systemOrange)
        }
        let totalWave = (defenseFort - 1) * 5 + defenseWave
        currentLevel = min(levels.count - 1, (totalWave - 1) / 2)
        defenseTarget = 6 + defenseWave + (defenseFort - 1) * 3
        enemiesToSpawn = defenseTarget
        kills = 0
        defenseResolved = 0
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
        updateHUD()
        run(.sequence([.wait(forDuration: transitionDelay), .run { [weak self] in self?.spawnWave() }]))
    }

    private func showAntidoteTransition() {
        stopControls()
        gamePaused = true
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
        let panel = makePanel(name: "antidotePanel", size: CGSize(width: min(620, size.width - 60), height: 230), color: SKColor(red: 0.02, green: 0.12, blue: 0.14, alpha: 0.98), stroke: .cyan, z: 350)
        panel.alpha = 0
        panel.setScale(0.86)
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
        start.name = "antidoteAnimating"
        start.text = "携带解药，继续救援"
        start.fontSize = 20
        start.fontColor = .systemGreen
        start.position.y = -58
        panel.addChild(start)
        playAntidoteAcquisitionAnimation()
        panel.run(.sequence([
            .wait(forDuration: 1.35),
            .group([.fadeIn(withDuration: 0.42), .scale(to: 1, duration: 0.42)]),
            .run { start.name = "startCureMission" }
        ]))
    }

    private func playAntidoteAcquisitionAnimation() {
        let cinematic = SKNode()
        cinematic.name = "antidoteCinematic"
        cinematic.position = CGPoint(x: size.width / 2, y: size.height / 2 - 12)
        cinematic.zPosition = 345
        addChild(cinematic)
        let caseBody = SKShapeNode(rectOf: CGSize(width: 150, height: 62), cornerRadius: 12)
        caseBody.position.y = -48
        caseBody.fillColor = SKColor(red: 0.10, green: 0.18, blue: 0.19, alpha: 1)
        caseBody.strokeColor = .cyan
        caseBody.lineWidth = 4
        cinematic.addChild(caseBody)
        let lid = SKShapeNode(rectOf: CGSize(width: 150, height: 22), cornerRadius: 8)
        lid.position = CGPoint(x: 0, y: -15)
        lid.fillColor = .darkGray
        lid.strokeColor = .cyan
        lid.lineWidth = 3
        cinematic.addChild(lid)
        let vial = SKShapeNode(rectOf: CGSize(width: 24, height: 70), cornerRadius: 10)
        vial.position = CGPoint(x: 0, y: -44)
        vial.fillColor = SKColor(red: 0.08, green: 0.82, blue: 0.92, alpha: 0.95)
        vial.strokeColor = .white
        vial.lineWidth = 3
        vial.glowWidth = 8
        vial.alpha = 0
        cinematic.addChild(vial)
        let cap = SKShapeNode(rectOf: CGSize(width: 27, height: 12), cornerRadius: 3)
        cap.position.y = 38
        cap.fillColor = .systemRed
        cap.strokeColor = .white
        vial.addChild(cap)
        let ring = SKShapeNode(circleOfRadius: 28)
        ring.strokeColor = .cyan
        ring.lineWidth = 4
        ring.fillColor = .clear
        ring.alpha = 0
        cinematic.addChild(ring)
        lid.run(.sequence([.wait(forDuration: 0.18), .group([.moveBy(x: 0, y: 34, duration: 0.30), .rotate(toAngle: -0.12, duration: 0.30)])]))
        vial.run(.sequence([.wait(forDuration: 0.42), .fadeIn(withDuration: 0.16), .group([.moveTo(y: 35, duration: 0.58), .rotate(byAngle: .pi * 2, duration: 0.58)]), .repeat(.sequence([.scale(to: 1.08, duration: 0.18), .scale(to: 1, duration: 0.18)]), count: 2)]))
        ring.run(.sequence([.wait(forDuration: 0.82), .fadeIn(withDuration: 0.10), .group([.scale(to: 4.2, duration: 0.55), .fadeOut(withDuration: 0.55)])]))
        cinematic.run(.sequence([.wait(forDuration: 1.32), .fadeOut(withDuration: 0.35), .removeFromParent()]))
    }

    private func showAntidoteLevelGate() {
        gameEnded = true
        stopControls()
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
        let panel = makePanel(name: "antidoteLevelGate", size: CGSize(width: min(620, size.width - 60), height: 230), color: SKColor(red: 0.10, green: 0.06, blue: 0.02, alpha: 0.98), stroke: .systemYellow, z: 350)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "解药章节 · Lv.5 解锁"
        title.fontSize = 32
        title.fontColor = .systemYellow
        title.position.y = 58
        panel.addChild(title)
        let message = SKLabelNode(fontNamed: "AvenirNext-Regular")
        message.text = "当前 Lv.\(activeAccount.level)，任务经验已保存。继续行动提升等级。"
        message.fontSize = 17
        message.position.y = 10
        panel.addChild(message)
        let back = SKLabelNode(fontNamed: "AvenirNext-Bold")
        back.name = "restartGame"
        back.text = "返回主界面继续升级"
        back.fontSize = 20
        back.fontColor = .cyan
        back.position.y = -58
        panel.addChild(back)
    }

    private func startCureMission() {
        childNode(withName: "antidotePanel")?.removeFromParent()
        currentLevel = 5
        taskWave = 1
        kills = 0
        enemiesToSpawn = levels[currentLevel].enemies
        health = min(maxHealth, health + 25)
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
        guard !isWaterChapter else { return }
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

    private func updateDefenseUnits(_ currentTime: TimeInterval) {
        guard currentTime - lastDefenseShot > 0.58, let target = nearestEnemy() else { return }
        lastDefenseShot = currentTime
        let units = world.children.filter { $0.name == "defenseTurret" || $0.name == "defenseSoldier" }
        for unit in units {
            let dx = target.position.x - unit.position.x
            let dy = target.position.y - unit.position.y
            let distance = max(1, hypot(dx, dy))
            unit.zRotation = atan2(dy, dx)
            let bullet = SKShapeNode(circleOfRadius: unit.name == "defenseTurret" ? 4 : 3)
            bullet.name = "bullet"
            bullet.userData = ["damage": unit.name == "defenseTurret" ? 3 : 1]
            bullet.fillColor = unit.name == "defenseTurret" ? .systemOrange : .systemGreen
            bullet.strokeColor = .white
            bullet.position = unit.position
            bullet.zPosition = 30
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: 4)
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = Mask.bullet
            bullet.physicsBody?.contactTestBitMask = Mask.enemy
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.velocity = CGVector(dx: dx / distance * 650, dy: dy / distance * 650)
            world.addChild(bullet)
            bullet.run(.sequence([.wait(forDuration: 1.4), .removeFromParent()]))
        }
    }

    private func spawnAirdrop(for waveLevel: Int) {
        let activeWave = usesSurvivalWaves ? 1000 + survivalWave : (gameMode == .defense ? 2000 + defenseFort * 10 + defenseWave : currentLevel * 10 + taskWave)
        guard gameStarted, !gameEnded, activeWave == waveLevel else { return }
        let dropX = CGFloat.random(in: size.width * 0.55...size.width * 0.82)
        let landingY = CGFloat.random(in: 110...size.height * 0.48)
        let flightY = min(size.height - 62, max(landingY + 125, size.height * 0.72))
        let drone = makeSupplyDrone()
        drone.name = "supplyDrone"
        drone.position = CGPoint(x: -110, y: flightY)
        drone.zPosition = 42

        let box = SKShapeNode(rectOf: CGSize(width: 58, height: 44), cornerRadius: 7)
        box.name = "airdrop"
        box.position = CGPoint(x: 0, y: -46)
        box.zPosition = 25
        box.fillColor = .systemRed
        box.strokeColor = .white
        box.lineWidth = 3
        let stripe = SKShapeNode(rectOf: CGSize(width: 12, height: 40))
        stripe.fillColor = .white
        stripe.strokeColor = .clear
        box.addChild(stripe)
        let cable = SKShapeNode(rectOf: CGSize(width: 3, height: 20), cornerRadius: 1)
        cable.name = "droneCable"
        cable.position.y = -26
        cable.fillColor = .lightGray
        cable.strokeColor = .clear
        drone.addChild(cable)
        drone.addChild(box)
        world.addChild(drone)
        showToast("补给无人机正在进入投放区", color: .systemCyan)

        drone.run(.sequence([
            .moveTo(x: dropX, duration: 1.45),
            .wait(forDuration: 0.25),
            .run { [weak self, weak drone, weak box, weak cable] in
                guard let self, let drone, let box else { return }
                let releasePosition = box.convert(CGPoint.zero, to: self.world)
                box.removeFromParent()
                cable?.removeFromParent()
                box.position = releasePosition
                box.zPosition = 28
                self.world.addChild(box)
                self.attachParachute(to: box)
                box.run(.sequence([
                    .group([
                        .move(to: CGPoint(x: dropX, y: landingY), duration: 1.15),
                        .sequence([.rotate(toAngle: 0.08, duration: 0.25), .rotate(toAngle: -0.08, duration: 0.25), .rotate(toAngle: 0, duration: 0.65)])
                    ]),
                    .run { [weak self, weak box] in
                        box?.childNode(withName: "parachute")?.run(.sequence([.fadeOut(withDuration: 0.35), .removeFromParent()]))
                        self?.pulse(at: CGPoint(x: dropX, y: landingY), color: .systemYellow, radius: 42)
                        self?.showToast("无人机空投抵达，靠近自动开启", color: .systemYellow)
                    }
                ]))
                drone.run(.sequence([.moveTo(x: self.size.width + 130, duration: 1.25), .removeFromParent()]))
            }
        ]))
    }

    private func makeSupplyDrone() -> SKNode {
        let drone = SKNode()
        let body = SKShapeNode(rectOf: CGSize(width: 72, height: 25), cornerRadius: 11)
        body.fillColor = SKColor(red: 0.18, green: 0.23, blue: 0.25, alpha: 1)
        body.strokeColor = .systemCyan
        body.lineWidth = 2.5
        drone.addChild(body)
        let nose = SKShapeNode(circleOfRadius: 8)
        nose.position.x = 34
        nose.fillColor = .systemBlue
        nose.strokeColor = .white
        nose.glowWidth = 2
        drone.addChild(nose)
        let camera = SKShapeNode(circleOfRadius: 6)
        camera.position = CGPoint(x: 18, y: -14)
        camera.fillColor = .black
        camera.strokeColor = .systemRed
        camera.lineWidth = 2
        drone.addChild(camera)
        for x in [-44, 44] as [CGFloat] {
            let arm = SKShapeNode(rectOf: CGSize(width: 32, height: 5), cornerRadius: 2)
            arm.position.x = x > 0 ? 42 : -42
            arm.fillColor = .darkGray
            arm.strokeColor = .lightGray
            drone.addChild(arm)
            for y in [-18, 18] as [CGFloat] {
                let mast = SKShapeNode(rectOf: CGSize(width: 4, height: 22), cornerRadius: 2)
                mast.position = CGPoint(x: x, y: y / 2)
                mast.fillColor = .gray
                mast.strokeColor = .clear
                drone.addChild(mast)
                let rotor = SKShapeNode(rectOf: CGSize(width: 43, height: 4), cornerRadius: 2)
                rotor.position = CGPoint(x: x, y: y)
                rotor.fillColor = SKColor(white: 0.75, alpha: 0.82)
                rotor.strokeColor = .systemCyan
                rotor.lineWidth = 1
                rotor.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.07)))
                drone.addChild(rotor)
            }
        }
        let light = SKShapeNode(circleOfRadius: 3)
        light.position = CGPoint(x: -28, y: -11)
        light.fillColor = .systemGreen
        light.strokeColor = .clear
        light.run(.repeatForever(.sequence([.fadeAlpha(to: 0.15, duration: 0.22), .fadeAlpha(to: 1, duration: 0.22)])))
        drone.addChild(light)
        drone.run(.repeatForever(.sequence([.moveBy(x: 0, y: 3, duration: 0.28), .moveBy(x: 0, y: -3, duration: 0.28)])), withKey: "hover")
        return drone
    }

    private func attachParachute(to box: SKNode) {
        let parachute = SKNode()
        parachute.name = "parachute"
        parachute.position.y = 48
        let canopyPath = CGMutablePath()
        canopyPath.move(to: CGPoint(x: -32, y: 0))
        canopyPath.addQuadCurve(to: CGPoint(x: 32, y: 0), control: CGPoint(x: 0, y: 45))
        canopyPath.addLine(to: CGPoint(x: -32, y: 0))
        canopyPath.closeSubpath()
        let canopy = SKShapeNode(path: canopyPath)
        canopy.fillColor = .systemOrange
        canopy.strokeColor = .white
        canopy.lineWidth = 2
        parachute.addChild(canopy)
        for x in [-25, 25] as [CGFloat] {
            let cordPath = CGMutablePath()
            cordPath.move(to: CGPoint(x: x, y: 0))
            cordPath.addLine(to: CGPoint(x: x * 0.55, y: -31))
            let cord = SKShapeNode(path: cordPath)
            cord.strokeColor = .white
            cord.lineWidth = 1.5
            parachute.addChild(cord)
        }
        box.addChild(parachute)
    }

    private func openAirdrop(_ box: SKNode) {
        let pistol = Int.random(in: 10...18)
        let shotgun = Int.random(in: 3...7)
        let reward = Int.random(in: 25...45)
        let grenadeReward = activeAccount.level >= 6 ? Int.random(in: 1...2) : 0
        let trapReward = Int.random(in: 0...1)
        let medicalReward = activeAccount.level >= 5 ? Int.random(in: 0...1) : 0
        let stimulantReward = activeAccount.level >= 8 ? Int.random(in: 0...1) : 0
        if gameMode != .melee {
            ammo[.pistol, default: 0] += pistol
            ammo[.shotgun, default: 0] += shotgun
        }
        grenades += grenadeReward
        traps += trapReward
        medicalKits += medicalReward
        stimulantShots += stimulantReward
        var extra = ""
        if gameMode != .melee, unlocked.contains(.thompson) {
            let thompson = Int.random(in: 18...32)
            ammo[.thompson, default: 0] += thompson
            extra += " 汤普森 +\(thompson)"
        }
        if gameMode != .melee, unlocked.contains(.barrett) {
            let barrett = Int.random(in: 2...4)
            ammo[.barrett, default: 0] += barrett
            extra += " 巴雷特 +\(barrett)"
        }
        if gameMode != .melee, unlocked.contains(.rpg) {
            let rockets = Int.random(in: 1...2)
            ammo[.rpg, default: 0] += rockets
            extra += " 火箭弹 +\(rockets)"
        }
        coins += reward
        pulse(at: box.position, color: .systemYellow, radius: 42)
        box.removeFromParent()
        updateHUD()
        showToast("空投补给已获取 · 申城币 +\(reward)\(extra)", color: .systemYellow)
    }

    private func spawnCoinChest(for waveLevel: Int) {
        let activeWave = usesSurvivalWaves ? 1000 + survivalWave : (gameMode == .defense ? 2000 + defenseFort * 10 + defenseWave : currentLevel * 10 + taskWave)
        guard gameStarted, !gameEnded, activeWave == waveLevel else { return }
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
        let powerText = (activeAccount.powerHelmetUnlocked || activeAccount.powerArmorUnlocked) ? " · 动力 \(Int(powerHelmetCharge * 100))/\(Int(powerArmorCharge * 100))%" : ""
        hpLabel.text = "生命 \(max(0, health))/\(maxHealth) · 减伤 \(Int(armorDamageReduction * 100))%\(powerText)"
        switch gameMode {
        case .task:
            levelLabel.text = isBossLevel ? "第二章 · 最终BOSS · \(waterLevels[currentLevel].name)" : (isWaterChapter ? "第二章 · 水战 \(currentLevel + 1)/4 · \(waterLevels[currentLevel].name)" : "第一章 · \(currentLevel + 1)/7关 · \(levels[currentLevel].name)")
        case .survival: levelLabel.text = "生存 · 尸潮 \(survivalWave)/20 · 末日堡垒"
        case .melee: levelLabel.text = "刀战 · 尸潮 \(survivalWave)/20 · 近战求生"
        case .defense: levelLabel.text = "防守 · 堡垒 \(defenseFort)/3 · 波次 \(defenseWave)/5"
        case .mech: levelLabel.text = "机甲 · 尸潮 \(survivalWave)/20 · 动力突击"
        }
        let weaponPrefix = isCurePhase ? "解药·" : ""
        let weaponStatus: String
        if weapon == .plasmaBlade {
            weaponStatus = plasmaBladeCharge >= 1 ? "大招就绪·长按" : "大招冷却 \(Int(ceil((1 - plasmaBladeCharge) * 15)))s"
        } else if weapon.isEnergyWeapon {
            weaponStatus = "充能 \(Int((weapon == .laserEmitter ? laserCharge : ionCharge) * 100))%"
        } else {
            weaponStatus = (weapon.isMelee || weapon.isThrownMelee) ? "∞" : String(ammo[weapon, default: 0])
        }
        weaponLabel.text = "\(weaponPrefix)\(weapon.name) · \(weaponStatus)"
        coinLabel.text = "◎ 申城币 \(coins)"
        (grenadeButton.childNode(withName: "grenade") as? SKLabelNode)?.text = "雷×\(grenades)"
        (airstrikeButton.childNode(withName: "airstrike") as? SKLabelNode)?.text = activeAccount.level >= 7 ? "空袭×\(airstrikes)" : "空袭·锁"
        (torpedoButton.childNode(withName: "torpedo") as? SKLabelNode)?.text = "鱼雷×\(torpedoes)"
        torpedoButton.isHidden = !isWaterChapter
        tankButton.isHidden = isWaterChapter
        hovercraftButton.isHidden = !isWaterChapter
        updateVehicleHUD()
        updateHelicopterHUD()
        updateTankHUD()
        updateHovercraftHUD()
        repairButton.isHidden = gameMode != .mech
        if let label = repairButton.childNode(withName: "repairMech") as? SKLabelNode {
            label.text = repairCooldownRemaining > 0 ? "维修\n\(Int(ceil(repairCooldownRemaining)))s" : "维修"
            label.numberOfLines = 2
            repairButton.strokeColor = repairCooldownRemaining > 0 ? .systemYellow : .systemGreen
        }
        (trapButton.childNode(withName: "trap") as? SKLabelNode)?.text = "阱×\(traps)"
        (medicalButton.childNode(withName: "medical") as? SKLabelNode)?.text = "药×\(medicalKits)"
        updateStimulantHUD()
        updateJetpackHUD()
        if usesSurvivalWaves {
            missionLabel.text = gameMode == .melee ? "刀战目标 · 近战歼灭 \(kills)/\(survivalTarget)" : (gameMode == .mech ? "机甲目标 · 特殊武器歼灭 \(kills)/\(survivalTarget)" : "生存目标 · 击退本波尸潮 \(kills)/\(survivalTarget)")
        } else if gameMode == .defense {
            missionLabel.text = "堡垒耐久 \(fortHealth) · 本波 \(defenseResolved)/\(defenseTarget) · 歼敌 \(kills)"
        } else {
            if isBossLevel {
                let bossHP = world.children.first(where: { $0.name == "enemyBoss" })?.userData?["hp"] as? Int
                missionLabel.text = bossHP.map { "BOSS · 变异暴君生命 \(max(0, $0))/160" } ?? "BOSS · 变异暴君即将出现"
            } else if isWaterChapter {
                missionLabel.text = "水战 · 阻止登船 \(kills)/\(waterLevels[currentLevel].enemies)"
            } else {
                missionLabel.text = isCurePhase ? "任务 · 净化 \(kills)/\(levels[currentLevel].enemies) · 战友 \(allies.count)" : "任务 · 清除感染者 \(kills)/\(levels[currentLevel].enemies)"
            }
        }
    }

    private func updateVehicleHUD() {
        let label = vehicleButton.childNode(withName: "vehicle") as? SKLabelNode
        if !activeAccount.vehicleUnlocked {
            label?.text = "载具·锁"
            vehicleButton.strokeColor = .gray
        } else if vehicleActive {
            label?.text = "⛽ \(Int(ceil(vehicleFuelRemaining)))s"
            vehicleButton.strokeColor = vehicleFuelRemaining <= 8 ? .systemRed : .systemGreen
        } else if vehicleFuelRemaining > 0 {
            label?.text = "⛽ \(Int(ceil(vehicleFuelRemaining)))s"
            vehicleButton.strokeColor = .systemYellow
        } else {
            label?.text = "⛽ 柴油×\(activeAccount.dieselCanisters)"
            vehicleButton.strokeColor = activeAccount.dieselCanisters > 0 ? .systemGreen : .systemRed
        }
    }

    private func updateHelicopterHUD() {
        let label = helicopterButton.childNode(withName: "helicopter") as? SKLabelNode
        if !activeAccount.helicopterUnlocked {
            label?.text = "直升机·锁"
            helicopterButton.strokeColor = .gray
        } else if helicopterActive {
            label?.text = "⛽ \(Int(ceil(helicopterFuelRemaining)))s"
            helicopterButton.strokeColor = helicopterFuelRemaining <= 8 ? .systemRed : .systemCyan
        } else if helicopterFuelRemaining > 0 {
            label?.text = "⛽ \(Int(ceil(helicopterFuelRemaining)))s"
            helicopterButton.strokeColor = .systemYellow
        } else {
            label?.text = "⛽ 航油×\(activeAccount.aviationFuelCanisters)"
            helicopterButton.strokeColor = activeAccount.aviationFuelCanisters > 0 ? .systemCyan : .systemRed
        }
    }

    private func updateTankHUD() {
        let label = tankButton.childNode(withName: "tank") as? SKLabelNode
        if !activeAccount.tankUnlocked {
            label?.text = "坦克·锁"
            tankButton.strokeColor = .gray
        } else if tankActive {
            label?.text = "炮 \(Int(ceil(tankFuelRemaining)))s"
            tankButton.strokeColor = tankFuelRemaining <= 8 ? .systemRed : .systemOrange
        } else if tankFuelRemaining > 0 {
            label?.text = "柴油 \(Int(ceil(tankFuelRemaining)))s"
            tankButton.strokeColor = .systemYellow
        } else {
            label?.text = "坦克×\(activeAccount.dieselCanisters)"
            tankButton.strokeColor = activeAccount.dieselCanisters > 0 ? .systemOrange : .systemRed
        }
    }

    private func updateHovercraftHUD() {
        let label = hovercraftButton.childNode(withName: "hovercraft") as? SKLabelNode
        if !activeAccount.hovercraftUnlocked {
            label?.text = "气垫船·锁"
            hovercraftButton.strokeColor = .gray
        } else if hovercraftActive {
            label?.text = "双炮 \(Int(ceil(hovercraftFuelRemaining)))s"
            hovercraftButton.strokeColor = hovercraftFuelRemaining <= 8 ? .systemRed : .systemTeal
        } else if hovercraftFuelRemaining > 0 {
            label?.text = "柴油 \(Int(ceil(hovercraftFuelRemaining)))s"
            hovercraftButton.strokeColor = .systemYellow
        } else {
            label?.text = "船×\(activeAccount.dieselCanisters)"
            hovercraftButton.strokeColor = activeAccount.dieselCanisters > 0 ? .systemTeal : .systemRed
        }
    }

    private func updateStimulantHUD() {
        let label = stimulantButton.childNode(withName: "stimulant") as? SKLabelNode
        label?.text = stimulantRemaining > 0 ? "针 \(Int(ceil(stimulantRemaining)))s" : "针×\(stimulantShots)"
        stimulantButton.strokeColor = stimulantRemaining > 0 ? .systemYellow : .systemBlue
    }

    private func updateJetpackHUD() {
        guard !accounts.isEmpty else {
            (jetpackButton.childNode(withName: "jetpack") as? SKLabelNode)?.text = "背包"
            return
        }
        let account = activeAccount
        let label = jetpackButton.childNode(withName: "jetpack") as? SKLabelNode
        if !account.jetpackUnlocked {
            label?.text = "背包·锁"
            jetpackButton.strokeColor = .gray
        } else {
            label?.text = jetpackBurstsRemaining > 0 ? "喷×\(jetpackBurstsRemaining)" : "池×\(account.jetpackBatteries)"
            jetpackButton.strokeColor = jetpackActive ? .systemYellow : ((jetpackBurstsRemaining > 0 || account.jetpackBatteries > 0) ? .systemOrange : .systemRed)
        }
        let percent = account.jetpackUnlocked ? CGFloat(jetpackBurstsRemaining) / 10 : 0
        if let energy = jetpackButton.childNode(withName: "jetpackEnergyBack")?.childNode(withName: "jetpackEnergy") as? SKShapeNode {
            energy.xScale = percent
            energy.position.x = -20 + 20 * percent
            energy.fillColor = percent <= 0.3 ? .systemRed : (percent <= 0.6 ? .systemYellow : .systemGreen)
        }
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
        if gameMode == .mech {
            title.text = "机甲特殊装备站 · \(coins) 币"
            addShopItem(to: panel, weapon: .laserEmitter, position: CGPoint(x: -170, y: 100), width: 160)
            addShopItem(to: panel, weapon: .ionCannon, position: CGPoint(x: 0, y: 100), width: 160)
            addShopItem(to: panel, weapon: .plasmaBlade, position: CGPoint(x: 170, y: 100), width: 160)
        } else if gameMode == .melee {
            addShopItem(to: panel, weapon: .axe, position: CGPoint(x: -175, y: 112), width: 160)
            addShopItem(to: panel, weapon: .machete, position: CGPoint(x: 0, y: 112), width: 160)
            addShopItem(to: panel, weapon: .katana, position: CGPoint(x: 175, y: 112), width: 160)
            addShopItem(to: panel, weapon: .throwingKnife, position: CGPoint(x: -88, y: 66), width: 160)
            addShopItem(to: panel, weapon: .boomerang, position: CGPoint(x: 88, y: 66), width: 160)
        } else {
            addShopItem(to: panel, weapon: .shotgun, position: CGPoint(x: -175, y: 113), width: 160)
            addShopItem(to: panel, weapon: .axe, position: CGPoint(x: 0, y: 113), width: 160)
            addShopItem(to: panel, weapon: .thompson, position: CGPoint(x: 175, y: 113), width: 160)
            addShopItem(to: panel, weapon: .barrett, position: CGPoint(x: -88, y: 68), width: 160)
            addShopItem(to: panel, weapon: .rpg, position: CGPoint(x: 88, y: 68), width: 160)
            for (index, item) in [Weapon.pistol, .shotgun, .thompson, .barrett, .rpg].enumerated() {
                addAmmoItem(to: panel, weapon: item, position: CGPoint(x: CGFloat(index) * 103 - 206, y: 18))
            }
        }
        if isCurePhase && !isWaterChapter {
            addAllyWeaponItem(to: panel)
        } else {
            for level in 1...5 {
                let x = CGFloat(level - 3) * 101
                addArmorItem(to: panel, kind: .helmet, level: level, position: CGPoint(x: x, y: -38))
                addArmorItem(to: panel, kind: .vest, level: level, position: CGPoint(x: x, y: -104))
            }
        }
        let grenadeReady = activeAccount.level >= 6
        let medicalReady = activeAccount.level >= 5
        let stimulantReady = activeAccount.level >= 8
        let airstrikeReady = activeAccount.level >= 7
        if gameMode == .defense {
            let xs: [CGFloat] = [-217, -155, -93, -31, 31, 93, 155, 217]
            addTacticalShopItem(to: panel, name: grenadeReady ? "buyGrenade" : "tacticalLevelLocked", text: grenadeReady ? "手雷\n35" : "手雷\nLv6", position: CGPoint(x: xs[0], y: -158), color: grenadeReady ? .systemRed : .gray, width: 52)
            addTacticalShopItem(to: panel, name: "buyTrap", text: "陷阱\n30", position: CGPoint(x: xs[1], y: -158), color: .systemPurple, width: 52)
            addTacticalShopItem(to: panel, name: medicalReady ? "buyMedical" : "tacticalLevelLocked", text: medicalReady ? "医疗\n40" : "医疗\nLv5", position: CGPoint(x: xs[2], y: -158), color: medicalReady ? .systemGreen : .gray, width: 52)
            addTacticalShopItem(to: panel, name: airstrikeReady ? "buyAirstrike" : "tacticalLevelLocked", text: airstrikeReady ? "空袭\n100" : "空袭\nLv7", position: CGPoint(x: xs[3], y: -158), color: airstrikeReady ? .systemOrange : .gray, width: 52)
            addTacticalShopItem(to: panel, name: stimulantReady ? "buyStimulant" : "tacticalLevelLocked", text: stimulantReady ? "体力针\n50" : "体力针\nLv8", position: CGPoint(x: xs[4], y: -158), color: stimulantReady ? .systemBlue : .gray, width: 52)
            addTacticalShopItem(to: panel, name: activeAccount.vehicleUnlocked ? "buyDiesel" : "tacticalLevelLocked", text: activeAccount.vehicleUnlocked ? "柴油\n45" : "柴油\n需载具", position: CGPoint(x: xs[5], y: -158), color: activeAccount.vehicleUnlocked ? .systemYellow : .gray, width: 52)
            addTacticalShopItem(to: panel, name: "buyTurret", text: "炮塔\n120", position: CGPoint(x: xs[6], y: -158), color: .systemOrange, width: 52)
            addTacticalShopItem(to: panel, name: "buyDefenseSoldier", text: "士兵\n80", position: CGPoint(x: xs[7], y: -158), color: .systemGreen, width: 52)
        } else {
            let items: [(String, String, SKColor)] = [
                (grenadeReady ? "buyGrenade" : "tacticalLevelLocked", grenadeReady ? "手雷\n35" : "手雷\nLv6", grenadeReady ? .systemRed : .gray),
                ("buyTrap", "陷阱\n30", .systemPurple),
                (medicalReady ? "buyMedical" : "tacticalLevelLocked", medicalReady ? "医疗\n40" : "医疗\nLv5", medicalReady ? .systemGreen : .gray),
                (airstrikeReady ? "buyAirstrike" : "tacticalLevelLocked", airstrikeReady ? "空袭\n100" : "空袭\nLv7", airstrikeReady ? .systemOrange : .gray),
                (stimulantReady ? "buyStimulant" : "tacticalLevelLocked", stimulantReady ? "体力针\n50" : "体力针\nLv8", stimulantReady ? .systemBlue : .gray),
                (activeAccount.vehicleUnlocked ? "buyDiesel" : "tacticalLevelLocked", activeAccount.vehicleUnlocked ? "柴油\n45" : "柴油\n需突击车", activeAccount.vehicleUnlocked ? .systemYellow : .gray),
                (activeAccount.helicopterUnlocked ? "buyAviationFuel" : "tacticalLevelLocked", activeAccount.helicopterUnlocked ? "航油\n65" : "航油\n需直升机", activeAccount.helicopterUnlocked ? .systemCyan : .gray)
            ] + (isWaterChapter ? [("buyTorpedo", "鱼雷\n70", SKColor.systemCyan)] : [])
            let spacing: CGFloat = isWaterChapter ? 68 : 78
            for (index, item) in items.enumerated() {
                let x = (CGFloat(index) - CGFloat(items.count - 1) / 2) * spacing
                addTacticalShopItem(to: panel, name: item.0, text: item.1, position: CGPoint(x: x, y: -158), color: item.2, width: spacing - 8)
            }
        }
        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.name = "closeShop"
        close.text = "关闭"
        close.fontSize = 14
        close.position = CGPoint(x: 238, y: 153)
        panel.addChild(close)
    }

    private func addTacticalShopItem(to panel: SKNode, name: String, text: String, position: CGPoint, color: SKColor, width: CGFloat = 188) {
        let button = SKShapeNode(rectOf: CGSize(width: width, height: 34), cornerRadius: 8)
        button.name = name
        button.position = position
        button.fillColor = SKColor(white: 0.08, alpha: 1)
        button.strokeColor = color
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = text
        label.numberOfLines = text.contains("\n") ? 2 : 1
        label.fontSize = width < 120 ? 10 : 12
        label.verticalAlignmentMode = .center
        if name == "buyTurret" {
            let icon = makeDetailedTurret(scale: 0.30)
            icon.position = CGPoint(x: -22, y: -2)
            icon.zPosition = 2
            button.addChild(icon)
            label.position.x = 11
            label.fontSize = 8
        }
        button.addChild(label)
    }

    private func buyTacticalItem(grenade: Bool) {
        if grenade, activeAccount.level < 6 { showToast("手榴弹在 Lv.6 解锁", color: .systemOrange); return }
        let price = grenade ? 35 : 30
        guard coins >= price else { showToast("申城币不足，寻找金币宝箱", color: .systemRed); return }
        coins -= price
        if grenade { grenades += 1 } else { traps += 1 }
        updateHUD()
        refreshShop()
        showToast(grenade ? "手榴弹 +1" : "阻拦陷阱 +1", color: grenade ? .systemOrange : .systemPurple)
    }

    private func buyMedicalKit() {
        guard activeAccount.level >= 5 else { showToast("医疗道具在 Lv.5 解锁", color: .systemOrange); return }
        guard coins >= 40 else { showToast("申城币不足，寻找金币宝箱", color: .systemRed); return }
        coins -= 40
        medicalKits += 1
        updateHUD()
        refreshShop()
        showToast("医疗包 +1", color: .systemGreen)
    }

    private func buyAirstrike() {
        guard activeAccount.level >= 7 else { showToast("呼叫空袭在 Lv.7 解锁", color: .systemOrange); return }
        guard coins >= 100 else { showToast("购买空袭需要100申城币", color: .systemRed); return }
        coins -= 100
        airstrikes += 1
        updateHUD()
        refreshShop()
        showToast("空袭支援次数 +1", color: .systemOrange)
    }

    private func buyStimulant() {
        guard activeAccount.level >= 8 else { showToast("体力针在 Lv.8 解锁", color: .systemOrange); return }
        guard coins >= 50 else { showToast("申城币不足，寻找金币宝箱", color: .systemRed); return }
        coins -= 50
        stimulantShots += 1
        updateHUD()
        refreshShop()
        showToast("体力针 +1", color: .systemBlue)
    }

    private func buyDefenseUnit(turret: Bool) {
        guard gameMode == .defense else { return }
        let price = turret ? 120 : 80
        guard coins >= price else { showToast("申城币不足，击退尸潮或寻找宝箱", color: .systemRed); return }
        coins -= price
        if turret { deployTurret() } else { recruitDefenseSoldier() }
        updateHUD()
        refreshShop()
        showToast(turret ? "防御炮塔已部署" : "塔防士兵已加入", color: turret ? .systemOrange : .systemGreen)
    }

    private func deployTurret() {
        turretCount += 1
        let turret = makeDetailedTurret(scale: 1)
        turret.name = "defenseTurret"
        turret.position = CGPoint(x: size.width * 0.20 + 52, y: 108 + CGFloat((turretCount - 1) % 5) * 48)
        turret.zPosition = 17
        world.addChild(turret)
    }

    private func makeDetailedTurret(scale: CGFloat) -> SKNode {
        let root = SKNode()
        root.setScale(scale)

        let baseShadow = SKShapeNode(ellipseOf: CGSize(width: 46, height: 22))
        baseShadow.position = CGPoint(x: -2, y: -8)
        baseShadow.fillColor = SKColor(white: 0.06, alpha: 0.9)
        baseShadow.strokeColor = .black
        baseShadow.lineWidth = 2
        root.addChild(baseShadow)

        for y in [-12, 12] as [CGFloat] {
            let track = SKShapeNode(rectOf: CGSize(width: 38, height: 9), cornerRadius: 4)
            track.position = CGPoint(x: -3, y: y)
            track.fillColor = SKColor(red: 0.13, green: 0.15, blue: 0.15, alpha: 1)
            track.strokeColor = SKColor(white: 0.38, alpha: 1)
            track.lineWidth = 2
            root.addChild(track)
            for x in stride(from: -14, through: 12, by: 9) {
                let tread = SKShapeNode(rectOf: CGSize(width: 3, height: 7), cornerRadius: 1)
                tread.position = CGPoint(x: CGFloat(x), y: y)
                tread.fillColor = .darkGray
                tread.strokeColor = .clear
                root.addChild(tread)
            }
        }

        let chassis = SKShapeNode(rectOf: CGSize(width: 38, height: 28), cornerRadius: 8)
        chassis.fillColor = SKColor(red: 0.20, green: 0.24, blue: 0.22, alpha: 1)
        chassis.strokeColor = .systemOrange
        chassis.lineWidth = 2.5
        root.addChild(chassis)

        let armor = SKShapeNode(rectOf: CGSize(width: 24, height: 20), cornerRadius: 7)
        armor.position.x = 5
        armor.fillColor = SKColor(red: 0.30, green: 0.34, blue: 0.30, alpha: 1)
        armor.strokeColor = .lightGray
        armor.lineWidth = 1.5
        root.addChild(armor)

        let ammoBox = SKShapeNode(rectOf: CGSize(width: 13, height: 18), cornerRadius: 3)
        ammoBox.position = CGPoint(x: -18, y: -1)
        ammoBox.fillColor = SKColor(red: 0.28, green: 0.25, blue: 0.12, alpha: 1)
        ammoBox.strokeColor = .systemYellow
        ammoBox.lineWidth = 1.5
        root.addChild(ammoBox)

        for y in [-5, 5] as [CGFloat] {
            let barrel = SKShapeNode(rectOf: CGSize(width: 48, height: 5), cornerRadius: 2)
            barrel.name = "unitBarrel"
            barrel.position = CGPoint(x: 33, y: y)
            barrel.fillColor = SKColor(white: 0.48, alpha: 1)
            barrel.strokeColor = .black
            barrel.lineWidth = 1
            root.addChild(barrel)
            let muzzle = SKShapeNode(rectOf: CGSize(width: 8, height: 8), cornerRadius: 2)
            muzzle.position = CGPoint(x: 58, y: y)
            muzzle.fillColor = SKColor(white: 0.16, alpha: 1)
            muzzle.strokeColor = .systemOrange
            muzzle.lineWidth = 1.5
            root.addChild(muzzle)
        }

        let optic = SKShapeNode(circleOfRadius: 5)
        optic.position = CGPoint(x: 7, y: 0)
        optic.fillColor = .systemRed
        optic.strokeColor = .white
        optic.lineWidth = 1.5
        optic.glowWidth = 2
        root.addChild(optic)

        let status = SKShapeNode(circleOfRadius: 2.5)
        status.position = CGPoint(x: -8, y: 0)
        status.fillColor = .systemGreen
        status.strokeColor = .clear
        status.run(.repeatForever(.sequence([.fadeAlpha(to: 0.25, duration: 0.45), .fadeAlpha(to: 1, duration: 0.45)])))
        root.addChild(status)
        return root
    }

    private func recruitDefenseSoldier() {
        defenseSoldierCount += 1
        let soldier = SKShapeNode(circleOfRadius: 17)
        soldier.name = "defenseSoldier"
        soldier.position = CGPoint(x: size.width * 0.20 + 100, y: 105 + CGFloat((defenseSoldierCount - 1) % 6) * 42)
        soldier.fillColor = SKColor(red: 0.05, green: 0.20, blue: 0.12, alpha: 1)
        soldier.strokeColor = .systemGreen
        soldier.lineWidth = 3
        soldier.zPosition = 18
        let portrait = SKSpriteNode(texture: cachedTexture("player_survivor"))
        portrait.size = CGSize(width: 31, height: 31)
        soldier.addChild(portrait)
        world.addChild(soldier)
    }

    private func ammoPack(for item: Weapon) -> (count: Int, price: Int) {
        switch item {
        case .pistol: return (20, 15)
        case .shotgun: return (8, 22)
        case .thompson: return (40, 30)
        case .barrett: return (5, 35)
        case .rpg: return (2, 48)
        case .axe, .machete, .katana, .throwingKnife, .boomerang, .laserEmitter, .ionCannon, .plasmaBlade: return (0, 0)
        }
    }

    private func addAmmoItem(to panel: SKNode, weapon item: Weapon, position: CGPoint) {
        let available = unlocked.contains(item)
        let pack = ammoPack(for: item)
        let name = available ? "buyAmmo_\(item.rawValue)" : "ammoLocked"
        let button = SKShapeNode(rectOf: CGSize(width: 96, height: 40), cornerRadius: 8)
        button.name = name
        button.position = position
        button.fillColor = available ? SKColor(red: 0.16, green: 0.12, blue: 0.03, alpha: 1) : .darkGray
        button.strokeColor = available ? .systemYellow : .gray
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.numberOfLines = 2
        label.fontSize = 9
        label.verticalAlignmentMode = .center
        label.text = available ? "\(item.name)弹药 +\(pack.count)\n\(pack.price)币 · 现有\(ammo[item, default: 0])" : "\(item.name)弹药\n尚未解锁"
        button.addChild(label)
    }

    private func buyAmmo(for item: Weapon) {
        guard unlocked.contains(item), !item.isMelee, !item.isThrownMelee, !item.isEnergyWeapon else { showToast("该武器无需弹药", color: .systemOrange); return }
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
        let card = SKShapeNode(rectOf: CGSize(width: 94, height: 62), cornerRadius: 9)
        card.name = name
        card.position = position
        card.fillColor = owned ? .darkGray : SKColor(red: 0.06, green: 0.13, blue: 0.17, alpha: 1)
        card.strokeColor = owned ? .gray : (available ? .systemYellow : .darkGray)
        panel.addChild(card)

        let sourceLevel = min(level, 3)
        let icon = SKSpriteNode(texture: cachedTexture("\(kind.rawValue)_level\(sourceLevel)"))
        icon.name = name
        icon.size = CGSize(width: 40, height: 40)
        icon.position.x = -25
        if level == 4 {
            icon.color = .lightGray
            icon.colorBlendFactor = 0.24
        } else if level == 5 {
            icon.color = .systemYellow
            icon.colorBlendFactor = 0.30
        }
        card.addChild(icon)

        let badge = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        badge.text = "\(level)"
        badge.fontSize = 11
        badge.fontColor = level >= 4 ? .systemYellow : .cyan
        badge.position = CGPoint(x: -10, y: 14)
        badge.zPosition = 2
        card.addChild(badge)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        let reductionText = "减伤\(Int(kind.reductions[level] * 100))%"
        label.text = owned ? "\(kind.name)\(level)级\n\(reductionText)" : (available ? "\(kind.name)\(level)级 \(reductionText)\n\(kind.prices[level])币" : "\(kind.name)\(level)级\n需前一级")
        label.numberOfLines = 2
        label.fontSize = 9
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position.x = 2
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
        helmetSprite?.isHidden = helmetLevel == 0 && !activeAccount.powerHelmetUnlocked
        vestSprite?.isHidden = vestLevel == 0 && !activeAccount.powerArmorUnlocked
        if helmetLevel > 0 { helmetSprite?.texture = cachedTexture("helmet_level\(min(helmetLevel, 3))") }
        if vestLevel > 0 { vestSprite?.texture = cachedTexture("vest_level\(min(vestLevel, 3))") }
        helmetSprite?.color = helmetLevel >= 5 ? .systemYellow : (helmetLevel >= 4 ? .lightGray : .white)
        vestSprite?.color = vestLevel >= 5 ? .systemYellow : (vestLevel >= 4 ? .lightGray : .white)
        helmetSprite?.colorBlendFactor = helmetLevel >= 4 ? (helmetLevel == 5 ? 0.28 : 0.18) : 0
        vestSprite?.colorBlendFactor = vestLevel >= 4 ? (vestLevel == 5 ? 0.28 : 0.18) : 0
        helmetSprite?.alpha = 0.96
        vestSprite?.alpha = 0.96
        helmetSprite?.setScale(1 + CGFloat(max(0, helmetLevel - 1)) * 0.035)
        vestSprite?.setScale(1 + CGFloat(max(0, vestLevel - 1)) * 0.035)
        updateWearableLevelBadge(on: helmetSprite, level: helmetLevel)
        updateWearableLevelBadge(on: vestSprite, level: vestLevel)
        updatePowerArmorGlow(on: helmetSprite, enabled: activeAccount.powerHelmetUnlocked, charge: powerHelmetCharge, color: .systemYellow)
        updatePowerArmorGlow(on: vestSprite, enabled: activeAccount.powerArmorUnlocked, charge: powerArmorCharge, color: .systemRed)
    }

    private func updatePowerArmorGlow(on node: SKNode?, enabled: Bool, charge: TimeInterval, color: SKColor) {
        node?.childNode(withName: "powerGlow")?.removeFromParent()
        guard enabled, let node else { return }
        let glow = SKShapeNode(rectOf: CGSize(width: node.frame.width + 8, height: node.frame.height + 8), cornerRadius: 8)
        glow.name = "powerGlow"
        glow.fillColor = color.withAlphaComponent(CGFloat(0.08 + charge * 0.12))
        glow.strokeColor = charge > 0 ? color : .darkGray
        glow.lineWidth = 3
        glow.glowWidth = charge > 0 ? 7 : 0
        glow.zPosition = -1
        node.addChild(glow)
    }

    private func updateWearableLevelBadge(on node: SKNode?, level: Int) {
        node?.childNode(withName: "wearableLevel")?.removeFromParent()
        guard level >= 4 else { return }
        let badge = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        badge.name = "wearableLevel"
        badge.text = "\(level)"
        badge.fontSize = 10
        badge.fontColor = level >= 5 ? .black : .white
        badge.position = CGPoint(x: 16, y: 12)
        badge.zPosition = 3
        node?.addChild(badge)
    }

    private func addShopItem(to panel: SKNode, weapon item: Weapon, position: CGPoint, width: CGFloat = 240) {
        let owned = unlocked.contains(item)
        let levelReady = activeAccount.level >= item.requiredLevel
        let button = SKShapeNode(rectOf: CGSize(width: width, height: 42), cornerRadius: 9)
        button.name = owned ? "owned" : (levelReady ? "buy_\(item.rawValue)" : "weaponLevelLocked")
        button.position = position
        button.fillColor = owned || !levelReady ? .darkGray : SKColor(red: 0.08, green: 0.24, blue: 0.27, alpha: 1)
        button.strokeColor = owned || !levelReady ? .gray : .cyan
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = button.name
        label.text = owned ? "\(item.name) · 已拥有" : (levelReady ? "解锁 \(item.name) · \(item.price) 币" : "\(item.name) · Lv.\(item.requiredLevel) 解锁")
        label.fontSize = width < 200 ? 12 : 14
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func buyWeapon(_ item: Weapon) {
        guard !unlocked.contains(item) else { return }
        guard activeAccount.level >= item.requiredLevel else {
            showToast("账户达到 Lv.\(item.requiredLevel) 后可解锁 \(item.name)", color: .systemOrange)
            return
        }
        guard coins >= item.price else { showToast("申城币不足，继续搜寻空投和宝箱", color: .systemRed); return }
        coins -= item.price
        unlocked.insert(item)
        weapon = item
        switch item {
        case .shotgun: ammo[.shotgun, default: 0] += 5
        case .thompson: ammo[.thompson, default: 0] += 45
        case .barrett: ammo[.barrett, default: 0] += 8
        case .rpg: ammo[.rpg, default: 0] += 3
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
        let panel = makePanel(name: "trainingPanel", size: CGSize(width: min(650, size.width - 70), height: 370), color: SKColor(red: 0.025, green: 0.10, blue: 0.08, alpha: 0.98), stroke: .systemGreen, z: 310)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "幸存者训练 · \(coins) 币"
        title.fontSize = 25
        title.position = CGPoint(x: -105, y: 155)
        panel.addChild(title)
        for (index, item) in Training.allCases.enumerated() {
            addTrainingItem(to: panel, training: item, y: CGFloat(102 - index * 53))
        }
        addTrainingPentagon(to: panel)
        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.name = "closeTraining"
        close.text = "关闭"
        close.fontSize = 17
        close.position = CGPoint(x: 205, y: -166)
        panel.addChild(close)
    }

    private func addTrainingItem(to panel: SKNode, training item: Training, y: CGFloat) {
        let level = trainingLevels[item, default: 0]
        let maxed = level >= 5
        let price = trainingPrices[min(5, level + 1)]
        let name = maxed ? "trainingMax" : "train_\(item.rawValue)"
        let button = SKShapeNode(rectOf: CGSize(width: 350, height: 47), cornerRadius: 10)
        button.name = name
        button.position = CGPoint(x: -112, y: y)
        button.fillColor = maxed ? .darkGray : SKColor(red: 0.04, green: 0.19, blue: 0.13, alpha: 1)
        button.strokeColor = maxed ? .gray : .systemGreen
        panel.addChild(button)
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.numberOfLines = 2
        label.fontSize = 12
        label.verticalAlignmentMode = .center
        label.text = maxed ? "\(item.name) · 5级（已满）\n\(item.detail)" : "\(item.name) · \(level)级 → \(level + 1)级 · \(price)币\n\(item.detail)"
        button.addChild(label)
    }

    private func addTrainingPentagon(to panel: SKNode) {
        let center = CGPoint(x: 190, y: 8)
        let radius: CGFloat = 78
        let items = Training.allCases
        func point(index: Int, scale: CGFloat) -> CGPoint {
            let angle = -.pi / 2 + CGFloat(index) * .pi * 2 / CGFloat(items.count)
            return CGPoint(x: center.x + cos(angle) * radius * scale, y: center.y + sin(angle) * radius * scale)
        }
        for ring in [CGFloat(0.4), 0.7, 1.0] {
            let path = CGMutablePath()
            path.move(to: point(index: 0, scale: ring))
            for index in 1..<items.count { path.addLine(to: point(index: index, scale: ring)) }
            path.closeSubpath()
            let shape = SKShapeNode(path: path)
            shape.strokeColor = SKColor.systemGreen.withAlphaComponent(ring == 1 ? 0.8 : 0.28)
            shape.lineWidth = ring == 1 ? 2 : 1
            panel.addChild(shape)
        }
        for index in items.indices {
            let axis = CGMutablePath()
            axis.move(to: center)
            axis.addLine(to: point(index: index, scale: 1))
            let line = SKShapeNode(path: axis)
            line.strokeColor = SKColor.systemGreen.withAlphaComponent(0.28)
            line.lineWidth = 1
            panel.addChild(line)
        }
        let stats = CGMutablePath()
        for (index, item) in items.enumerated() {
            let scale = max(0.06, CGFloat(trainingLevels[item, default: 0]) / 5)
            let vertex = point(index: index, scale: scale)
            if index == 0 { stats.move(to: vertex) } else { stats.addLine(to: vertex) }
        }
        stats.closeSubpath()
        let fill = SKShapeNode(path: stats)
        fill.fillColor = SKColor.systemYellow.withAlphaComponent(0.22)
        fill.strokeColor = .systemYellow
        fill.lineWidth = 3
        panel.addChild(fill)
        for (index, item) in items.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "\(item.name)\(trainingLevels[item, default: 0])"
            label.fontSize = 10
            label.fontColor = .white
            label.position = point(index: index, scale: 1.22)
            label.verticalAlignmentMode = .center
            panel.addChild(label)
        }
    }

    private func buyTraining(_ item: Training) {
        let level = trainingLevels[item, default: 0]
        guard level < 5 else { return }
        let price = trainingPrices[level + 1]
        guard coins >= price else { showToast("申城币不足，寻找宝箱或重型丧尸", color: .systemRed); return }
        coins -= price
        trainingLevels[item] = level + 1
        if item == .resistance { health = min(maxHealth, health + 25) }
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
        switch gameMode {
        case .task: note.text = isBossLevel ? "当前进度：第二章最终 Boss 关" : (isWaterChapter ? "当前进度：第二章水战第 \(currentLevel + 1)/4 关" : "当前进度：第一章第 \(currentLevel + 1)/7 关 · 单波任务")
        case .survival: note.text = "当前进度：生存模式第 \(survivalWave)/20 波"
        case .melee: note.text = "当前进度：刀战模式第 \(survivalWave)/20 波"
        case .defense: note.text = "当前进度：堡垒 \(defenseFort)/3 · 第 \(defenseWave)/5 波"
        case .mech: note.text = "当前进度：机甲模式第 \(survivalWave)/20 波 · 维修冷却 \(Int(ceil(repairCooldownRemaining)))秒"
        }
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

    private func recordPlayerDamageForBlood(_ damage: Int) {
        damageTowardNextBloodStain += max(0, damage)
        while damageTowardNextBloodStain >= 10 {
            damageTowardNextBloodStain -= 10
            addPlayerGreenBloodStain()
        }
    }

    private func addPlayerGreenBloodStain(animated: Bool = true) {
        let layout: [(CGPoint, CGFloat)] = [
            (CGPoint(x: -12, y: 10), 7), (CGPoint(x: 10, y: 2), 5),
            (CGPoint(x: -8, y: -25), 6), (CGPoint(x: 13, y: -42), 8),
            (CGPoint(x: -21, y: -46), 5), (CGPoint(x: 28, y: -37), 6),
            (CGPoint(x: -10, y: -67), 7), (CGPoint(x: 9, y: -78), 5),
            (CGPoint(x: -13, y: -94), 6), (CGPoint(x: 12, y: -105), 7),
            (CGPoint(x: 22, y: -15), 4), (CGPoint(x: -26, y: -32), 4)
        ]
        let index = playerBloodStainCount
        let base = layout[index % layout.count]
        let layer = index / layout.count
        let offset = CGFloat(layer) * 2.2
        let position = CGPoint(
            x: base.0.x + (index.isMultiple(of: 2) ? offset : -offset),
            y: base.0.y + (index.isMultiple(of: 3) ? -offset : offset)
        )
        let bloodColor = SKColor(red: 0.18, green: 0.72, blue: 0.12, alpha: 0.92)
        let darkBlood = SKColor(red: 0.05, green: 0.34, blue: 0.04, alpha: 0.95)
        let drop = SKShapeNode(circleOfRadius: max(3, base.1 - CGFloat(layer) * 0.7))
        drop.name = "playerGreenBlood"
        drop.position = position
        drop.fillColor = index.isMultiple(of: 3) ? darkBlood : bloodColor
        drop.strokeColor = .clear
        drop.alpha = animated ? 0 : 1
        drop.zPosition = 8 + CGFloat(layer) * 0.01
        player.addChild(drop)
        let speck = SKShapeNode(circleOfRadius: max(1.5, base.1 * 0.34))
        speck.position = CGPoint(x: base.1 * 1.15, y: base.1 * 0.68)
        speck.fillColor = bloodColor
        speck.strokeColor = .clear
        drop.addChild(speck)
        if animated {
            drop.setScale(0.35)
            drop.run(.group([.fadeIn(withDuration: 0.12), .scale(to: 1, duration: 0.12)]))
        }
        playerBloodStainCount += 1
    }

    private func performPlayerDeath() {
        guard !gameEnded else { return }
        gameEnded = true
        health = 0
        stopControls()
        player.physicsBody = nil
        player.removeAllActions()
        missionLabel.text = "行动失败 · 幸存者倒下 · 点击设置重新开始"
        updateHUD()

        let bloodColor = SKColor(red: 0.18, green: 0.72, blue: 0.12, alpha: 0.92)
        let darkBlood = SKColor(red: 0.05, green: 0.34, blue: 0.04, alpha: 0.95)
        let pool = SKShapeNode(ellipseOf: CGSize(width: 138, height: 46))
        pool.name = "playerBloodPool"
        pool.position = CGPoint(x: player.position.x, y: max(74, player.position.y - 62))
        pool.fillColor = darkBlood.withAlphaComponent(0.68)
        pool.strokeColor = bloodColor.withAlphaComponent(0.75)
        pool.lineWidth = 2
        pool.zPosition = player.zPosition - 2
        pool.setScale(0.12)
        world.addChild(pool)
        pool.run(.scale(to: 1, duration: 0.65))

        while playerBloodStainCount < 18 { addPlayerGreenBloodStain() }

        for index in 0..<18 {
            let angle = CGFloat(index) * (.pi * 2 / 18) + CGFloat(index % 3) * 0.13
            let distance = CGFloat(38 + (index % 5) * 13)
            let droplet = SKShapeNode(circleOfRadius: CGFloat(2 + index % 4))
            droplet.position = CGPoint(x: player.position.x, y: player.position.y - 40)
            droplet.fillColor = index.isMultiple(of: 4) ? darkBlood : bloodColor
            droplet.strokeColor = .clear
            droplet.zPosition = player.zPosition + 3
            world.addChild(droplet)
            droplet.run(.sequence([
                .group([
                    .moveBy(x: cos(angle) * distance, y: sin(angle) * distance * 0.55, duration: 0.38),
                    .fadeAlpha(to: 0.70, duration: 0.38),
                    .scale(to: 0.55, duration: 0.38)
                ]),
                .wait(forDuration: 1.0),
                .fadeOut(withDuration: 0.8),
                .removeFromParent()
            ]))
        }

        player.childNode(withName: "playerArmLeft")?.run(.rotate(toAngle: -0.72, duration: 0.34, shortestUnitArc: true))
        player.childNode(withName: "playerArmRight")?.run(.rotate(toAngle: 0.86, duration: 0.34, shortestUnitArc: true))
        player.childNode(withName: "playerLegLeft")?.run(.rotate(toAngle: -0.32, duration: 0.38, shortestUnitArc: true))
        player.childNode(withName: "playerLegRight")?.run(.rotate(toAngle: 0.38, duration: 0.38, shortestUnitArc: true))
        player.run(.group([
            .rotate(toAngle: -.pi / 2, duration: 0.55, shortestUnitArc: true),
            .moveBy(x: 0, y: -28, duration: 0.55)
        ]))
        pulse(at: CGPoint(x: player.position.x, y: player.position.y - 36), color: bloodColor, radius: 58)
    }

    private func winGame() {
        guard !gameEnded else { return }
        gameEnded = true
        stopControls()
        world.children.filter { $0.name?.hasPrefix("enemy") == true }.forEach { $0.removeFromParent() }
        let clearReward = grantModeClearRewards()
        let panel = makePanel(name: "winPanel", size: CGSize(width: min(620, size.width - 60), height: 220), color: SKColor(red: 0.02, green: 0.12, blue: 0.14, alpha: 0.97), stroke: .cyan, z: 350)
        if gameMode == .task {
            panel.alpha = 0
            panel.setScale(0.88)
            playPurificationCompleteAnimation()
            panel.run(.sequence([.wait(forDuration: 1.35), .group([.fadeIn(withDuration: 0.45), .scale(to: 1, duration: 0.45)])]))
        }
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = gameMode == .mech ? "机甲突击成功" : (gameMode == .melee ? "刀战生存成功" : (gameMode == .survival ? "末日堡垒守卫成功" : (gameMode == .defense ? "三座堡垒全部守住" : (isWaterChapter ? "水上撤离成功" : "净化完成 · 上海获救"))))
        title.fontSize = 36
        title.fontColor = .cyan
        title.position.y = 52
        panel.addChild(title)
        let message = SKLabelNode(fontNamed: "AvenirNext-Regular")
        let victoryMessage = gameMode == .mech ? "机甲仅凭特殊武器突破了20波尸潮。" : (gameMode == .melee ? "你只凭近战武器挺过了20波尸潮。" : (gameMode == .survival ? "你挺过了20波尸潮，救援通道已经开启。" : (gameMode == .defense ? "黄黑警戒线未被突破，上海防线仍在。" : (isWaterChapter ? "解药已通过水路安全送出，上海获得最终救援。" : "感染者恢复成人类，幸存者小队守住了上海。"))))
        message.text = "\(victoryMessage)\n\(clearReward)"
        message.numberOfLines = 2
        message.fontSize = 17
        message.position.y = 8
        panel.addChild(message)
        let restart = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restart.name = gameMode == .task ? "purificationAnimating" : "restartGame"
        restart.text = "点击重新行动"
        restart.fontSize = 18
        restart.position.y = -55
        panel.addChild(restart)
        if gameMode == .task {
            restart.run(.sequence([.wait(forDuration: 1.75), .run { restart.name = "restartGame" }]))
        }
    }

    private func grantModeClearRewards() -> String {
        guard !reputationAwardedThisRun else { return "本次行动奖励已领取" }
        reputationAwardedThisRun = true
        let index = activeAccountIndex
        let fragments = accounts[index].weaponTechnicians * 2
        accounts[index].totalModeClears += 1
        if accounts[index].totalModeClears >= 25 { unlockCollectible("铂金钩爪", at: index, announce: false) }
        if gameMode == .defense {
            accounts[index].defenseModeClears += 1
            if accounts[index].defenseModeClears >= 5 { unlockCollectible("磐石防爆盾", at: index, announce: false) }
        }
        accounts[index].reputation += 10
        accounts[index].specialWeaponFragments += fragments
        saveAccounts()
        return fragments > 0 ? "声望 +10 · 技师制造碎片 +\(fragments)" : "声望 +10 · 可在大厅雇佣武器技师"
    }

    private func playPurificationCompleteAnimation() {
        let cinematic = SKNode()
        cinematic.name = "purificationCinematic"
        cinematic.position = CGPoint(x: size.width / 2, y: size.height / 2 - 8)
        cinematic.zPosition = 345
        addChild(cinematic)
        for index in 0..<5 {
            let survivor = SKShapeNode(circleOfRadius: 16)
            survivor.position = CGPoint(x: CGFloat(index - 2) * 58, y: CGFloat(abs(index - 2)) * -8)
            survivor.fillColor = .systemGreen
            survivor.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 0.1, alpha: 1)
            survivor.lineWidth = 4
            survivor.alpha = 0
            cinematic.addChild(survivor)
            let body = SKShapeNode(rectOf: CGSize(width: 26, height: 38), cornerRadius: 9)
            body.position.y = -34
            body.fillColor = .systemGreen
            body.strokeColor = .clear
            survivor.addChild(body)
            survivor.run(.sequence([
                .wait(forDuration: Double(index) * 0.10),
                .fadeIn(withDuration: 0.16),
                .group([.colorize(with: .systemCyan, colorBlendFactor: 0.78, duration: 0.65), .scale(to: 1.12, duration: 0.32)]),
                .scale(to: 1, duration: 0.22)
            ]))
        }
        let wave = SKShapeNode(circleOfRadius: 32)
        wave.strokeColor = .cyan
        wave.lineWidth = 6
        wave.fillColor = .clear
        wave.glowWidth = 8
        wave.alpha = 0
        cinematic.addChild(wave)
        wave.run(.sequence([.wait(forDuration: 0.35), .fadeIn(withDuration: 0.08), .group([.scale(to: 8.5, duration: 0.82), .fadeOut(withDuration: 0.82)])]))
        for index in 0..<18 {
            let spark = SKShapeNode(circleOfRadius: CGFloat(2 + index % 3))
            spark.fillColor = index.isMultiple(of: 2) ? .cyan : .systemGreen
            spark.strokeColor = .clear
            cinematic.addChild(spark)
            let angle = CGFloat(index) * .pi * 2 / 18
            spark.run(.sequence([.wait(forDuration: 0.42), .group([.moveBy(x: cos(angle) * 210, y: sin(angle) * 115, duration: 0.75), .fadeOut(withDuration: 0.75)]), .removeFromParent()]))
        }
        cinematic.run(.sequence([.wait(forDuration: 1.32), .fadeOut(withDuration: 0.35), .removeFromParent()]))
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = min(0.04, lastUpdate == 0 ? 0 : currentTime - lastUpdate)
        lastUpdate = currentTime
        guard gameStarted, !gameEnded, !shopOpen, !trainingOpen, !gamePaused else { return }
        if stimulantRemaining > 0 {
            stimulantRemaining = max(0, stimulantRemaining - delta)
            updateStimulantHUD()
        }
        if repairCooldownRemaining > 0 {
            repairCooldownRemaining = max(0, repairCooldownRemaining - delta)
            updateHUD()
        }
        if jetpackActive {
            jetpackBatteryRemaining = max(0, jetpackBatteryRemaining - delta)
            if jetpackBatteryRemaining <= 0 {
                deactivateJetpack()
            } else {
                updateJetpackHUD()
            }
        }
        if vehicleActive {
            vehicleFuelRemaining = max(0, vehicleFuelRemaining - delta)
            if vehicleFuelRemaining <= 0 {
                deactivateVehicle()
                showToast("载具柴油耗尽", color: .systemRed)
            } else {
                updateVehicleHUD()
                if currentTime - lastVehicleImpact > 0.55,
                   let enemy = world.children.first(where: { $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < 72 }) {
                    lastVehicleImpact = currentTime
                    hit(enemy, damage: 6)
                    pulse(at: enemy.position, color: .systemGreen, radius: 48)
                }
            }
        }
        if helicopterActive {
            helicopterFuelRemaining = max(0, helicopterFuelRemaining - delta)
            if helicopterFuelRemaining <= 0 {
                deactivateHelicopter()
                showToast("直升机航空燃料耗尽", color: .systemRed)
            } else {
                updateHelicopterHUD()
                if currentTime - lastHelicopterAttack > 0.60,
                   let enemy = world.children.filter({ $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < 230 }).min(by: { hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < hypot($1.position.x - player.position.x, $1.position.y - player.position.y) }) {
                    lastHelicopterAttack = currentTime
                    hit(enemy, damage: 3)
                    pulse(at: enemy.position, color: .systemCyan, radius: 32)
                }
            }
        }
        if tankActive {
            tankFuelRemaining = max(0, tankFuelRemaining - delta)
            if tankFuelRemaining <= 0 {
                deactivateTank()
                showToast("坦克柴油耗尽", color: .systemRed)
            } else {
                updateTankHUD()
                if currentTime - lastTankShot > 2.25,
                   let target = world.children.filter({ $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < 360 }).min(by: {
                       hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < hypot($1.position.x - player.position.x, $1.position.y - player.position.y)
                   }) {
                    lastTankShot = currentTime
                    fireTankHowitzer(at: target)
                }
            }
        }
        if hovercraftActive {
            hovercraftFuelRemaining = max(0, hovercraftFuelRemaining - delta)
            if hovercraftFuelRemaining <= 0 {
                deactivateHovercraft()
                showToast("气垫船柴油耗尽", color: .systemRed)
            } else {
                updateHovercraftHUD()
                if currentTime - lastHovercraftShot > 0.24,
                   let target = world.children.filter({ $0.name?.hasPrefix("enemy") == true && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < 330 }).min(by: {
                       hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < hypot($1.position.x - player.position.x, $1.position.y - player.position.y)
                   }) {
                    lastHovercraftShot = currentTime
                    fireHovercraftCannons(at: target)
                }
            }
        }
        let oldLaserPercent = Int(laserCharge * 100)
        let oldIonPercent = Int(ionCharge * 100)
        laserCharge = min(1, laserCharge + delta / 6)
        ionCharge = min(1, ionCharge + delta / 12)
        let oldPlasmaPercent = Int(plasmaBladeCharge * 100)
        let oldHelmetPercent = Int(powerHelmetCharge * 100)
        let oldArmorPercent = Int(powerArmorCharge * 100)
        plasmaBladeCharge = min(1, plasmaBladeCharge + delta / 15)
        if activeAccount.powerHelmetUnlocked { powerHelmetCharge = min(1, powerHelmetCharge + delta / 15) }
        if activeAccount.powerArmorUnlocked { powerArmorCharge = min(1, powerArmorCharge + delta / 20) }
        if weapon.isEnergyWeapon {
            let newPercent = Int((weapon == .laserEmitter ? laserCharge : ionCharge) * 100)
            if newPercent != (weapon == .laserEmitter ? oldLaserPercent : oldIonPercent) { updateHUD() }
        }
        if (weapon == .plasmaBlade && Int(plasmaBladeCharge * 100) != oldPlasmaPercent) || Int(powerHelmetCharge * 100) != oldHelmetPercent || Int(powerArmorCharge * 100) != oldArmorPercent {
            updateHUD()
            updateArmorGraphics()
        }
        playerPortrait?.zRotation = -player.zRotation
        let moving = abs(moveVector.dx) + abs(moveVector.dy) > 0.08
        let playerStride = moving ? CGFloat(sin(currentTime * 9)) * 0.34 : 0
        player.childNode(withName: "playerArmLeft")?.zRotation = playerStride
        player.childNode(withName: "playerArmRight")?.zRotation = -playerStride
        if !isKicking {
            player.childNode(withName: "playerLegLeft")?.zRotation = -playerStride * 0.72
            player.childNode(withName: "playerLegRight")?.zRotation = playerStride * 0.72
        }
        let explosiveLevel = trainingLevels[.explosive, default: 0]
        var nearbyEnemyCount = 0
        if explosiveLevel > 0 {
            for enemy in world.children where enemy.name?.hasPrefix("enemy") == true {
                if hypot(enemy.position.x - player.position.x, enemy.position.y - player.position.y) <= 155 {
                    nearbyEnemyCount += 1
                }
            }
        }
        let explosiveThreshold = max(3, 6 - explosiveLevel)
        let shouldActivateExplosive = explosiveLevel > 0 && nearbyEnemyCount >= explosiveThreshold
        if shouldActivateExplosive != explosiveActive {
            explosiveActive = shouldActivateExplosive
            trainingButton.strokeColor = explosiveActive ? .systemOrange : .systemGreen
            if explosiveActive {
                showToast("爆发力触发：移动速度提升 \(explosiveLevel * 20)%", color: .systemOrange)
            }
        }
        let baseMovementSpeed = 220 + CGFloat(trainingLevels[.speed, default: 0]) * 28
        let explosiveMultiplier = explosiveActive ? 1 + CGFloat(explosiveLevel) * 0.2 : 1
        let stimulantMultiplier: CGFloat = stimulantRemaining > 0 ? 1.5 : 1
        let jetpackMultiplier: CGFloat = jetpackActive ? 1.7 : 1
        let vehicleMultiplier: CGFloat = vehicleActive ? 1.8 : (helicopterActive ? 2.2 : (tankActive ? 1.25 : (hovercraftActive ? 1.9 : 1)))
        let movementSpeed = baseMovementSpeed * explosiveMultiplier * stimulantMultiplier * jetpackMultiplier * vehicleMultiplier
        player.position.x = max(35, min(size.width - 35, player.position.x + moveVector.dx * movementSpeed * delta))
        player.position.y = max(108, min(size.height * 0.61, player.position.y + moveVector.dy * movementSpeed * delta))
        for enemy in world.children where enemy.name?.hasPrefix("enemy") == true {
            guard triggerTrapIfNeeded(enemy, at: currentTime) else { continue }
            let dx = gameMode == .defense ? size.width * 0.20 - enemy.position.x : player.position.x - enemy.position.x
            let dy = gameMode == .defense ? 0 : player.position.y - enemy.position.y
            let distance = max(1, hypot(dx, dy))
            let base: CGFloat
            switch enemy.name {
            case "enemyBoss":
                let phase = enemy.userData?["phase"] as? Int ?? 1
                base = CGFloat(38 + phase * 24)
            case "enemyHeavy": base = 50
            case "enemyRunner": base = 132
            default: base = 74
            }
            let slowed = (enemy.userData?["slowedUntil"] as? TimeInterval ?? 0) > currentTime
            let levelSpeedBonus = isWaterChapter ? waterLevels[currentLevel].speedBonus : levels[currentLevel].speedBonus
            let waterMultiplier: CGFloat = enemy.name == "enemySwimmer" && enemy.position.y < 115 ? 0.72 : 1
            let speed = (base + levelSpeedBonus) * waterMultiplier * (slowed ? 0.28 : 1)
            enemy.position.x += dx / distance * speed * delta
            enemy.position.y += dy / distance * speed * delta
            if enemy.name == "enemyBoss" {
                let phase = enemy.userData?["phase"] as? Int ?? 1
                let shockDelay = max(1.7, 3.7 - Double(phase) * 0.55)
                if distance <= CGFloat(190 + phase * 18), currentTime - lastBossShock >= shockDelay {
                    lastBossShock = currentTime
                    performBossShock(from: enemy, phase: phase)
                }
                if enemy.userData?["summoning"] as? Bool == true {
                    let summonDelay: TimeInterval = phase >= 3 ? 4.0 : 6.0
                    let activeMinions = world.children.filter { $0.name == "enemyBossMinion" }.count
                    if currentTime - lastBossSummon >= summonDelay, activeMinions < 8 {
                        lastBossSummon = currentTime
                        summonBossMinions(around: enemy, count: phase >= 3 ? 3 : 2)
                    }
                }
            }
            if enemy.name == "enemyBoatRaider",
               enemy.userData?["boarded"] as? Bool != true,
               distance <= 112 {
                enemy.userData?["boarded"] = true
                if let boat = enemy.childNode(withName: "enemyAssaultBoat") {
                    let landingPoint = enemy.position
                    boat.run(.sequence([.group([.fadeOut(withDuration: 0.18), .scale(to: 0.72, duration: 0.18)]), .removeFromParent()]))
                    pulse(at: landingPoint, color: .systemCyan, radius: 52)
                }
                (enemy.childNode(withName: "waterEnemyBadge") as? SKLabelNode)?.text = "已登船"
                showToast("敌船抵达 · 船体撤离，登船者进入甲板", color: .systemOrange)
            }
            let strideRate: Double = enemy.name == "enemyBoss" ? 3.2 : (enemy.name == "enemyHeavy" ? 4.2 : (enemy.name == "enemyRunner" ? 10.5 : 5.4))
            let stagger = CGFloat(sin(currentTime * strideRate + Double(enemy.position.x) * 0.018))
            enemy.childNode(withName: "enemyArmLeft")?.zRotation = -0.38 + stagger * 0.18
            enemy.childNode(withName: "enemyArmRight")?.zRotation = 0.25 - stagger * 0.24
            enemy.childNode(withName: "enemyLegLeft")?.zRotation = stagger * 0.24
            enemy.childNode(withName: "enemyLegRight")?.zRotation = -stagger * 0.24
            if gameMode == .defense, enemy.position.x <= size.width * 0.20 + 8 {
                enemyReachedFortress(enemy)
                continue
            }
        }
        if isCurePhase { updateAllies(currentTime, delta: delta) }
        if gameMode == .defense { updateDefenseUnits(currentTime) }
        if let box = world.children.first(where: { $0.name == "airdrop" && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < 62 }) {
            openAirdrop(box)
        }
        if let chest = world.children.first(where: { $0.name?.hasPrefix("coinChest") == true && hypot($0.position.x - player.position.x, $0.position.y - player.position.y) < 66 }) { openCoinChest(chest) }
        handleHeldFire(at: currentTime)
    }

    private func performBossShock(from boss: SKNode, phase: Int) {
        let radius = CGFloat(190 + phase * 18)
        pulse(at: boss.position, color: phase >= 3 ? .systemPurple : .systemRed, radius: radius)
        let distance = hypot(player.position.x - boss.position.x, player.position.y - boss.position.y)
        guard distance <= radius else { return }
        let baseDamage = 10 + phase * 5
        let receivedDamage = max(1, Int(ceil(Double(baseDamage) * (1 - armorDamageReduction))))
        let actualDamage = min(max(0, health), receivedDamage)
        health -= receivedDamage
        recordPlayerDamageForBlood(actualDamage)
        let dx = player.position.x - boss.position.x
        let dy = player.position.y - boss.position.y
        let length = max(1, hypot(dx, dy))
        player.position.x = max(35, min(size.width - 35, player.position.x + dx / length * CGFloat(48 + phase * 10)))
        player.position.y = max(108, min(size.height * 0.61, player.position.y + dy / length * CGFloat(48 + phase * 10)))
        updateHUD()
        showToast("暴君震击 · 生命 -\(receivedDamage)", color: .systemRed)
        if health <= 0 { performPlayerDeath() }
    }

    private func enemyReachedFortress(_ enemy: SKNode) {
        let damage: Int
        switch enemy.name {
        case "enemyHeavy": damage = 22
        case "enemyRunner": damage = 12
        default: damage = 15
        }
        enemy.removeFromParent()
        fortHealth = max(0, fortHealth - damage)
        defenseResolved += 1
        pulse(at: CGPoint(x: size.width * 0.20, y: enemy.position.y), color: .systemRed, radius: 52)
        updateHUD()
        if fortHealth <= 0 {
            gameEnded = true
            stopControls()
            missionLabel.text = "堡垒失守 · 点击设置重新开始"
        } else {
            showToast("丧尸突破警戒线，堡垒 -\(damage)", color: .systemRed)
            checkLevelCompletion()
        }
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
                let baseDamage: Int
                switch enemy?.name {
                case "enemyBoss": baseDamage = 20
                case "enemyHeavy": baseDamage = 12
                case "enemyRunner": baseDamage = 7
                default: baseDamage = 8
                }
                let flightReduction = helicopterActive ? 0.5 : 1.0
                let receivedDamage = max(1, Int(ceil(Double(baseDamage) * (1 - armorDamageReduction) * flightReduction)))
                if activeAccount.powerHelmetUnlocked { powerHelmetCharge = max(0, powerHelmetCharge - 0.20) }
                if activeAccount.powerArmorUnlocked { powerArmorCharge = max(0, powerArmorCharge - 0.14) }
                let actualDamage = min(max(0, health), receivedDamage)
                health -= receivedDamage
                recordPlayerDamageForBlood(actualDamage)
                enemy?.position.x += 48
                updateHUD()
                if health <= 0 { performPlayerDeath() }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if openingCinematicActive {
            finishOpeningCinematic()
            return
        }
        for touch in touches {
            let point = touch.location(in: self)
            let hitNodes = nodes(at: point)
            let names = hitNodes.compactMap(\.name)
            if airstrikePlacementOpen {
                if names.contains("confirmAirstrike") { confirmAirstrikePlacement() }
                else if names.contains("cancelAirstrike") { cancelAirstrikePlacement() }
                else { updateAirstrikePlacement(point) }
                continue
            }
            if grenadePlacementOpen {
                if names.contains("confirmGrenade") { confirmGrenadePlacement() }
                else if names.contains("cancelGrenade") { cancelGrenadePlacement() }
                else if names.contains("toggleGrenadeContinuous") { toggleGrenadeContinuousMode() }
                else {
                    grenadePlacementTouch = touch
                    updateGrenadePlacement(point)
                }
                continue
            }
            if trapPlacementOpen {
                if names.contains("confirmTrap") { confirmTrapPlacement() }
                else if names.contains("cancelTrap") { cancelTrapPlacement() }
                else if names.contains("toggleTrapContinuous") { toggleTrapContinuousMode() }
                else {
                    trapPlacementTouch = touch
                    updateTrapPlacement(point)
                }
                continue
            }
            if names.contains("openActivities") { showActivities(); continue }
            if names.contains("openMissions") { showMissions(); continue }
            if names.contains("openCollection") { showCollection(); continue }
            if names.contains("closeMetaPanel") {
                let wasActivityOpen = childNode(withName: "activityPanel") != nil
                childNode(withName: "activityStoryPanel")?.removeFromParent()
                childNode(withName: "activityPanel")?.removeFromParent()
                childNode(withName: "missionPanel")?.removeFromParent()
                childNode(withName: "collectionPanel")?.removeFromParent()
                if wasActivityOpen { playBackgroundMusic("lobby_music.m4a", volume: 0.34) }
                continue
            }
            if names.contains("openActivityStory") { showActivityStory(); continue }
            if names.contains("closeActivityStory") {
                childNode(withName: "activityStoryPanel")?.removeFromParent()
                continue
            }
            if names.contains("claimDailyActivity") { claimDailyActivity(); continue }
            if let missionName = names.first(where: { $0.hasPrefix("claimMission_") }) {
                claimMission(String(missionName.dropFirst("claimMission_".count)))
                continue
            }
            if names.contains("activityClaimed") { showToast("今日活动补给已经领取", color: .systemOrange); continue }
            if names.contains("missionLocked") { showToast("任务目标尚未完成", color: .systemOrange); continue }
            if names.contains("accountManager") {
                showAccountManager()
                continue
            }
            if names.contains("openLobby") {
                showLobby()
                continue
            }
            if names.contains("hireTechnician") {
                hireTechnician()
                continue
            }
            if names.contains("craftJetpack") {
                craftJetpack()
                continue
            }
            if names.contains("craftJetpackBattery") {
                craftJetpackBattery()
                continue
            }
            if names.contains("craftLaserEmitter") {
                craftLaserEmitter()
                continue
            }
            if names.contains("craftIonCannon") {
                craftIonCannon()
                continue
            }
            if names.contains("craftPlasmaBlade") {
                craftSpecialEquipment(cost: 100, kind: "等离子大刀")
                continue
            }
            if names.contains("craftPowerHelmet") {
                craftSpecialEquipment(cost: 120, kind: "动力头盔")
                continue
            }
            if names.contains("craftPowerArmor") {
                craftSpecialEquipment(cost: 160, kind: "动力装甲")
                continue
            }
            if names.contains("craftVehicle") {
                craftVehicle()
                continue
            }
            if names.contains("craftHelicopter") {
                craftHelicopter()
                continue
            }
            if names.contains("craftTank") {
                craftTank()
                continue
            }
            if names.contains("craftHovercraft") {
                craftHovercraft()
                continue
            }
            if names.contains("specialWeaponOwned") {
                showToast("该特殊武器已经制造完成", color: .systemGreen)
                continue
            }
            if names.contains("technicianMax") {
                showToast("武器技师已达到10人上限", color: .systemOrange)
                continue
            }
            if names.contains("closeLobby") {
                childNode(withName: "lobbyPanel")?.removeFromParent()
                continue
            }
            if names.contains("createAccount") {
                createAccount()
                continue
            }
            if names.contains("switchAccount") {
                switchAccount()
                continue
            }
            if names.contains("renameAccount") {
                renameAccount()
                continue
            }
            if names.contains("deleteAccount") {
                deleteAccount()
                continue
            }
            if names.contains("closeAccount") {
                childNode(withName: "accountPanel")?.removeFromParent()
                continue
            }
            if names.contains("selectTaskMode") {
                torpedoButton.isHidden = true
                showModeStory(for: .task)
                continue
            }
            if names.contains("closeModeStory") {
                childNode(withName: "modeStoryPanel")?.removeFromParent()
                continue
            }
            if names.contains("continueStoryTask") {
                childNode(withName: "modeStoryPanel")?.removeFromParent()
                showTaskLevelSelection()
                continue
            }
            if names.contains("closeTaskLevelSelection") {
                childNode(withName: "taskLevelSelection")?.removeFromParent()
                continue
            }
            if let selection = names.first(where: { $0.hasPrefix("selectTaskLevel_") }) {
                let parts = selection.split(separator: "_")
                if parts.count == 3, let chapter = Int(parts[1]), let level = Int(parts[2]) {
                    selectTaskLevel(chapter: chapter, level: level)
                }
                continue
            }
            if names.contains("selectSurvivalMode") {
                showModeStory(for: .survival)
                continue
            }
            if names.contains("continueStorySurvival") {
                childNode(withName: "modeStoryPanel")?.removeFromParent()
                childNode(withName: "modeSelection")?.removeFromParent()
                showSurvivalIntro()
                continue
            }
            if names.contains("startSurvival") {
                childNode(withName: "survivalIntro")?.removeFromParent()
                gameStarted = true
                startBattleMusic()
                spawnWave()
                showToast("第 1/20 波尸潮来袭", color: .systemOrange)
                continue
            }
            if names.contains("selectMeleeMode") {
                showModeStory(for: .melee)
                continue
            }
            if names.contains("continueStoryMelee") {
                childNode(withName: "modeStoryPanel")?.removeFromParent()
                childNode(withName: "modeSelection")?.removeFromParent()
                showMeleeIntro()
                continue
            }
            if names.contains("selectMechMode") {
                showModeStory(for: .mech)
                continue
            }
            if names.contains("continueStoryMech") {
                childNode(withName: "modeStoryPanel")?.removeFromParent()
                childNode(withName: "modeSelection")?.removeFromParent()
                showMechIntro()
                continue
            }
            if names.contains("startMech") {
                childNode(withName: "mechIntro")?.removeFromParent()
                gameStarted = true
                startBattleMusic()
                spawnWave()
                showToast("机甲第 1/20 波尸潮来袭", color: .systemCyan)
                continue
            }
            if names.contains("startMelee") {
                childNode(withName: "meleeIntro")?.removeFromParent()
                gameStarted = true
                startBattleMusic()
                spawnWave()
                showToast("刀战第 1/20 波尸潮来袭", color: .systemRed)
                continue
            }
            if names.contains("selectDefenseMode") {
                showModeStory(for: .defense)
                continue
            }
            if names.contains("continueStoryDefense") {
                childNode(withName: "modeStoryPanel")?.removeFromParent()
                childNode(withName: "modeSelection")?.removeFromParent()
                showDefenseIntro()
                continue
            }
            if names.contains("startDefense") {
                childNode(withName: "defenseIntro")?.removeFromParent()
                gameStarted = true
                startBattleMusic()
                spawnWave()
                showToast("堡垒 1 · 第 1/5 波开始", color: .systemYellow)
                continue
            }
            if names.contains("lockedMode") {
                showToast("提升账户等级后解锁该模式", color: .systemOrange)
                continue
            }
            if names.contains("lockedMechMode") {
                showToast("在行动大厅制造喷气背包后解锁机甲模式", color: .systemOrange)
                continue
            }
            if names.contains("startCureMission") { startCureMission(); continue }
            if names.contains("startWaterChapter") { startWaterChapter(); continue }
            if names.contains("resumeGame") { resumeGame(); continue }
            if names.contains("restartGame") { restartGame(); continue }
            if names.contains("settings") { showSettings(); continue }
            if names.contains("repairMech") { repairMech(); continue }
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
                startBattleMusic()
                spawnWave()
                continue
            }
            if !gameStarted { continue }
            if let ammoName = names.first(where: { $0.hasPrefix("buyAmmo_") }), let raw = Int(ammoName.replacingOccurrences(of: "buyAmmo_", with: "")), let item = Weapon(rawValue: raw) {
                buyAmmo(for: item)
                continue
            }
            if let buyName = names.first(where: { $0.hasPrefix("buy_") }), let raw = Int(buyName.replacingOccurrences(of: "buy_", with: "")), let item = Weapon(rawValue: raw) {
                buyWeapon(item)
                continue
            }
            if names.contains("weaponLevelLocked") {
                showToast("提升账户等级后解锁该武器", color: .systemOrange)
                continue
            }
            if names.contains("tacticalLevelLocked") {
                showToast("该道具需要更高账户等级", color: .systemOrange)
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
            if names.contains("buyGrenade") { buyTacticalItem(grenade: true); continue }
            if names.contains("buyTrap") { buyTacticalItem(grenade: false); continue }
            if names.contains("buyAirstrike") { buyAirstrike(); continue }
            if names.contains("buyDiesel") { buyDiesel(); continue }
            if names.contains("buyAviationFuel") { buyAviationFuel(); continue }
            if names.contains("buyTorpedo") { buyTorpedo(); continue }
            if names.contains("buyMedical") { buyMedicalKit(); continue }
            if names.contains("buyStimulant") { buyStimulant(); continue }
            if names.contains("buyTurret") { buyDefenseUnit(turret: true); continue }
            if names.contains("buyDefenseSoldier") { buyDefenseUnit(turret: false); continue }
            if shopOpen { continue }
            if names.contains("grenade") {
                beginGrenadePlacement()
            } else if names.contains("airstrike") {
                beginAirstrikePlacement()
            } else if names.contains("torpedo") {
                launchTorpedo()
            } else if names.contains("vehicle") {
                toggleVehicle()
            } else if names.contains("helicopter") {
                toggleHelicopter()
            } else if names.contains("tank") {
                toggleTank()
            } else if names.contains("hovercraft") {
                toggleHovercraft()
            } else if names.contains("medical") {
                useMedicalKit()
            } else if names.contains("stimulant") {
                useStimulant()
            } else if names.contains("jetpack") {
                toggleJetpack()
            } else if names.contains("trap") {
                beginTrapPlacement()
            } else if names.contains("kick") {
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
                firePressStartedAt = lastUpdate
                plasmaUltimateTriggered = false
                fire(now: lastUpdate)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if airstrikePlacementOpen { updateAirstrikePlacement(touch.location(in: self)) }
            else if touch === grenadePlacementTouch { updateGrenadePlacement(touch.location(in: self)) }
            else if touch === trapPlacementTouch { updateTrapPlacement(touch.location(in: self)) }
            else if touch === joystickTouch { updateJoystick(touch.location(in: self)) }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === joystickTouch { joystickTouch = nil; moveVector = .zero; joystickKnob.position = joystickBase.position }
            if touch === fireTouch {
                fireTouch = nil
                firePressStartedAt = 0
                plasmaUltimateTriggered = false
            }
            if touch === trapPlacementTouch { trapPlacementTouch = nil }
            if touch === grenadePlacementTouch { grenadePlacementTouch = nil }
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
