import PlaygroundSupport
import SceneKit
import UIKit

// MARK: - Game Manager
class MiningGameManager {
    static let shared = MiningGameManager()
    var oreCount = 0
    var hasSpade = false
    var playerPosition = SCNVector3(0, 2, 0)
}

// MARK: - Ore Object
class Ore: NSObject {
    let node: SCNNode
    let position: SCNVector3
    var isCollected = false
    
    init(position: SCNVector3, type: OreType) {
        self.position = position
        self.node = SCNNode()
        super.init()
        
        let geometry = SCNSphere(radius: 0.2)
        geometry.segmentCount = 8
        
        switch type {
        case .gold:
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.84, blue: 0, alpha: 1)
        case .silver:
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        case .copper:
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.72, green: 0.45, blue: 0.2, alpha: 1)
        case .emerald:
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.31, green: 0.78, blue: 0.47, alpha: 1)
        }
        
        geometry.firstMaterial?.specular.contents = UIColor.white
        node.geometry = geometry
        node.position = position
        
        // Add slight rotation animation
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 3)
        let repeatAction = SCNAction.repeatForever(rotation)
        node.runAction(repeatAction)
    }
}

enum OreType {
    case gold, silver, copper, emerald
}

// MARK: - Player Character
class PlayerCharacter {
    let node: SCNNode
    var isWalking = false
    var hasSpade = false
    let idleAnimationDuration = 1.0
    var currentAnimation: SCNAction?
    
    init() {
        node = SCNNode()
        node.position = SCNVector3(0, 2, 0)
        createCharacter()
    }
    
    func createCharacter() {
        // Head
        let headGeometry = SCNSphere(radius: 0.25)
        headGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let head = SCNNode(geometry: headGeometry)
        head.position = SCNVector3(0, 0.5, 0)
        node.addChildNode(head)
        
        // Eyes
        let eyeGeometry = SCNSphere(radius: 0.06)
        eyeGeometry.firstMaterial?.diffuse.contents = UIColor.black
        let leftEye = SCNNode(geometry: eyeGeometry)
        leftEye.position = SCNVector3(-0.1, 0.65, 0.2)
        node.addChildNode(leftEye)
        
        let rightEye = SCNNode(geometry: eyeGeometry)
        rightEye.position = SCNVector3(0.1, 0.65, 0.2)
        node.addChildNode(rightEye)
        
        // Body
        let bodyGeometry = SCNBox(width: 0.3, height: 0.5, length: 0.2, chamferRadius: 0.05)
        bodyGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let body = SCNNode(geometry: bodyGeometry)
        body.position = SCNVector3(0, 0.15, 0)
        node.addChildNode(body)
        
        // Left Arm
        let armGeometry = SCNBox(width: 0.12, height: 0.4, length: 0.12, chamferRadius: 0.03)
        armGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let leftArm = SCNNode(geometry: armGeometry)
        leftArm.position = SCNVector3(-0.25, 0.2, 0)
        leftArm.name = "leftArm"
        node.addChildNode(leftArm)
        
        // Right Arm
        let rightArm = SCNNode(geometry: armGeometry)
        rightArm.position = SCNVector3(0.25, 0.2, 0)
        rightArm.name = "rightArm"
        node.addChildNode(rightArm)
        
        // Left Leg
        let legGeometry = SCNBox(width: 0.12, height: 0.35, length: 0.12, chamferRadius: 0.03)
        legGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let leftLeg = SCNNode(geometry: legGeometry)
        leftLeg.position = SCNVector3(-0.1, -0.35, 0)
        leftLeg.name = "leftLeg"
        node.addChildNode(leftLeg)
        
        // Right Leg
        let rightLeg = SCNNode(geometry: legGeometry)
        rightLeg.position = SCNVector3(0.1, -0.35, 0)
        rightLeg.name = "rightLeg"
        node.addChildNode(rightLeg)
        
        // Spade holder node
        let spadeHolder = SCNNode()
        spadeHolder.position = SCNVector3(0.3, 0.1, 0)
        spadeHolder.name = "spadeHolder"
        node.addChildNode(spadeHolder)
    }
    
    func playWalkAnimation() {
        if !isWalking {
            isWalking = true
            let leftArm = node.childNode(withName: "leftArm", recursively: true)
            let rightArm = node.childNode(withName: "rightArm", recursively: true)
            let leftLeg = node.childNode(withName: "leftLeg", recursively: true)
            let rightLeg = node.childNode(withName: "rightLeg", recursively: true)
            
            // Goofy walking animation
            let armSwing1 = SCNAction.rotateBy(x: CGFloat.pi / 6, y: 0, z: 0, duration: 0.3)
            let armSwing2 = SCNAction.rotateBy(x: -CGFloat.pi / 3, y: 0, z: 0, duration: 0.3)
            let armSequence = SCNAction.sequence([armSwing1, armSwing2])
            let armRepeat = SCNAction.repeatForever(armSequence)
            
            let legSwing1 = SCNAction.rotateBy(x: -CGFloat.pi / 6, y: 0, z: 0, duration: 0.3)
            let legSwing2 = SCNAction.rotateBy(x: CGFloat.pi / 3, y: 0, z: 0, duration: 0.3)
            let legSequence = SCNAction.sequence([legSwing1, legSwing2])
            let legRepeat = SCNAction.repeatForever(legSequence)
            
            leftArm?.runAction(armRepeat)
            rightArm?.runAction(SCNAction.sequence([armSwing2, armSwing1, armSwing2, armSwing1]))
            leftLeg?.runAction(legRepeat)
            rightLeg?.runAction(SCNAction.sequence([legSwing2, legSwing1, legSwing2, legSwing1]))
        }
    }
    
    func stopWalkAnimation() {
        if isWalking {
            isWalking = false
            node.enumerateChildNodes { child, _ in
                if child.name == "leftArm" || child.name == "rightArm" || 
                   child.name == "leftLeg" || child.name == "rightLeg" {
                    child.removeAllActions()
                    child.rotation = SCNVector4(0, 0, 0, 0)
                }
            }
        }
    }
    
    func playJumpAnimation() {
        let jumpUp = SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 0.2)
        let jumpDown = SCNAction.moveBy(x: 0, y: -0.3, z: 0, duration: 0.2)
        let jumpSequence = SCNAction.sequence([jumpUp, jumpDown])
        node.runAction(jumpSequence)
    }
    
    func playDigAnimation() {
        guard hasSpade else { return }
        
        let spadeHolder = node.childNode(withName: "spadeHolder", recursively: true)
        let rotateDown = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi / 3, duration: 0.2)
        let rotateUp = SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat.pi / 3, duration: 0.2)
        let digSequence = SCNAction.sequence([rotateDown, rotateUp])
        spadeHolder?.runAction(digSequence)
    }
    
    func equipSpade() {
        guard !hasSpade else { return }
        hasSpade = true
        
        let spadeHolder = node.childNode(withName: "spadeHolder", recursively: true)
        
        // Create spade handle
        let handleGeometry = SCNCylinder(radius: 0.02, height: 0.5)
        handleGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.2, blue: 0.0, alpha: 1)
        let handle = SCNNode(geometry: handleGeometry)
        handle.position = SCNVector3(0, 0.1, 0)
        handle.name = "spadeHandle"
        spadeHolder?.addChildNode(handle)
        
        // Create spade blade
        let bladeGeometry = SCNBox(width: 0.25, height: 0.15, length: 0.05, chamferRadius: 0.01)
        bladeGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        let blade = SCNNode(geometry: bladeGeometry)
        blade.position = SCNVector3(0, 0.35, 0)
        blade.name = "spadeBlade"
        spadeHolder?.addChildNode(blade)
    }
    
    func unequipSpade() {
        guard hasSpade else { return }
        hasSpade = false
        
        let spadeHolder = node.childNode(withName: "spadeHolder", recursively: true)
        spadeHolder?.enumerateChildNodes { child, _ in
            if child.name == "spadeHandle" || child.name == "spadeBlade" {
                child.removeFromParentNode()
            }
        }
    }
}

// MARK: - Main Game Scene
class MiningGameViewController: UIViewController, SCNSceneRendererDelegate {
    var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var player: PlayerCharacter!
    var ores: [Ore] = []
    var oreCountLabel: UILabel!
    var controlsLabel: UILabel!
    var spadeStatusLabel: UILabel!
    var moveDirection = SCNVector3(0, 0, 0)
    var keysPressed = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupUI()
        setupGameLoop()
    }
    
    func setupScene() {
        sceneView = SCNView(frame: view.bounds)
        sceneView.scene = SCNScene()
        scene = sceneView.scene
        sceneView.delegate = self
        sceneView.backgroundColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1)
        view.addSubview(sceneView)
        
        setupLighting()
        setupCamera()
        
        player = PlayerCharacter()
        scene.rootNode.addChildNode(player.node)
        
        createMap()
        generateOres()
        setupGestures()
    }
    
    func setupLighting() {
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 600
        ambientLight.color = UIColor.white
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.intensity = 1000
        sunLight.color = UIColor.white
        let sunNode = SCNNode()
        sunNode.light = sunLight
        sunNode.position = SCNVector3(10, 20, 10)
        scene.rootNode.addChildNode(sunNode)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 3, 5)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func createMap() {
        let mapSize: CGFloat = 50
        let layerHeight: CGFloat = 1.5
        let colors: [UIColor] = [
            UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1),
            UIColor(red: 0.5, green: 0.35, blue: 0.15, alpha: 1),
            UIColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 1),
            UIColor(red: 0.3, green: 0.25, blue: 0.1, alpha: 1),
            UIColor(red: 0.25, green: 0.2, blue: 0.08, alpha: 1)
        ]
        
        for i in 0..<5 {
            let layer = SCNBox(width: mapSize, height: layerHeight, length: mapSize, chamferRadius: 0)
            layer.firstMaterial?.diffuse.contents = colors[i]
            layer.firstMaterial?.specular.contents = UIColor.gray
            
            let layerNode = SCNNode(geometry: layer)
            layerNode.position = SCNVector3(0, CGFloat(-i) * layerHeight, 0)
            layerNode.name = "layer_\(i)"
            scene.rootNode.addChildNode(layerNode)
        }
        
        let bedrock = SCNBox(width: mapSize, height: 1, length: mapSize, chamferRadius: 0)
        bedrock.firstMaterial?.diffuse.contents = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        let bedrockNode = SCNNode(geometry: bedrock)
        bedrockNode.position = SCNVector3(0, -8, 0)
        scene.rootNode.addChildNode(bedrockNode)
    }
    
    func generateOres() {
        let oreCount = 100
        let mapRadius: Float = 20
        let maxDepth: Float = -7
        
        for _ in 0..<oreCount {
            let x = Float.random(in: -mapRadius...mapRadius)
            let y = Float.random(in: maxDepth...0)
            let z = Float.random(in: -mapRadius...mapRadius)
            let position = SCNVector3(x, y, z)
            
            let types: [OreType] = [.gold, .silver, .copper, .emerald]
            let randomType = types.randomElement() ?? .gold
            
            let ore = Ore(position: position, type: randomType)
            ores.append(ore)
            scene.rootNode.addChildNode(ore.node)
        }
    }
    
    func setupUI() {
        // Ore counter
        oreCountLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 300, height: 50))
        oreCountLabel.text = "Ores Collected: 0"
        oreCountLabel.textColor = UIColor.black
        oreCountLabel.font = UIFont.boldSystemFont(ofSize: 24)
        oreCountLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        oreCountLabel.layer.cornerRadius = 10
        oreCountLabel.clipsToBounds = true
        oreCountLabel.textAlignment = .center
        view.addSubview(oreCountLabel)
        
        // Spade status
        spadeStatusLabel = UILabel(frame: CGRect(x: 20, y: 100, width: 300, height: 50))
        spadeStatusLabel.text = "Spade: NOT EQUIPPED"
        spadeStatusLabel.textColor = UIColor.red
        spadeStatusLabel.font = UIFont.boldSystemFont(ofSize: 18)
        spadeStatusLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        spadeStatusLabel.layer.cornerRadius = 10
        spadeStatusLabel.clipsToBounds = true
        spadeStatusLabel.textAlignment = .center
        view.addSubview(spadeStatusLabel)
        
        // Controls
        controlsLabel = UILabel(frame: CGRect(x: 20, y: view.bounds.height - 220, width: view.bounds.width - 40, height: 200))
        controlsLabel.numberOfLines = 0
        controlsLabel.text = """
        CONTROLS:
        W/A/S/D - Move | SPACE - Jump
        E - Equip/Unequip Spade | Click on Ore - Dig
        T - Teleport to Top | Drag - Rotate Camera
        """
        controlsLabel.textColor = UIColor.black
        controlsLabel.font = UIFont.systemFont(ofSize: 14)
        controlsLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        controlsLabel.layer.cornerRadius = 10
        controlsLabel.clipsToBounds = true
        controlsLabel.textAlignment = .left
        view.addSubview(controlsLabel)
        
        // Teleport button
        let teleportButton = UIButton(type: .system)
        teleportButton.frame = CGRect(x: view.bounds.width - 140, y: 40, width: 120, height: 50)
        teleportButton.setTitle("↑ TP TO TOP", for: .normal)
        teleportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        teleportButton.backgroundColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 0.9)
        teleportButton.setTitleColor(UIColor.white, for: .normal)
        teleportButton.layer.cornerRadius = 10
        teleportButton.addTarget(self, action: #selector(teleportToTop), for: .touchUpInside)
        view.addSubview(teleportButton)
        
        // Equip/Unequip button
        let equipButton = UIButton(type: .system)
        equipButton.frame = CGRect(x: view.bounds.width - 140, y: 100, width: 120, height: 50)
        equipButton.setTitle("EQUIP SPADE", for: .normal)
        equipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        equipButton.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 0.9)
        equipButton.setTitleColor(UIColor.white, for: .normal)
        equipButton.layer.cornerRadius = 10
        equipButton.addTarget(self, action: #selector(toggleSpade), for: .touchUpInside)
        view.addSubview(equipButton)
    }
    
    @objc func teleportToTop() {
        player.node.position = SCNVector3(0, 2, 0)
        MiningGameManager.shared.playerPosition = player.node.position
        updateCameraPosition()
    }
    
    @objc func toggleSpade() {
        if player.hasSpade {
            player.unequipSpade()
            spadeStatusLabel.text = "Spade: NOT EQUIPPED"
            spadeStatusLabel.textColor = UIColor.red
        } else {
            player.equipSpade()
            spadeStatusLabel.text = "Spade: EQUIPPED"
            spadeStatusLabel.textColor = UIColor.green
        }
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: [:])
        
        if !player.hasSpade { return }
        
        for result in hitResults {
            for (index, ore) in ores.enumerated() {
                if result.node == ore.node && !ore.isCollected {
                    collectOre(at: index)
                    player.playDigAnimation()
                    break
                }
            }
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: sceneView)
        gesture.setTranslation(.zero, in: sceneView)
        
        let angleX = Float(translation.y) * 0.01
        let angleY = Float(translation.x) * 0.01
        
        let currentPos = cameraNode.position
        let distance: Float = 5
        
        cameraNode.position = SCNVector3(
            distance * sin(angleY),
            currentPos.y - angleX,
            distance * cos(angleY)
        )
        cameraNode.look(at: SCNVector3(player.node.position.x, player.node.position.y + 0.3, player.node.position.z), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
    }
    
    func collectOre(at index: Int) {
        let ore = ores[index]
        ore.isCollected = true
        ore.node.removeFromParentNode()
        
        MiningGameManager.shared.oreCount += 1
        oreCountLabel.text = "Ores Collected: \(MiningGameManager.shared.oreCount)"
        
        // Regenerate ore at random location
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let x = Float.random(in: -20...20)
            let y = Float.random(in: -7...0)
            let z = Float.random(in: -20...20)
            let newPosition = SCNVector3(x, y, z)
            
            let types: [OreType] = [.gold, .silver, .copper, .emerald]
            let randomType = types.randomElement() ?? .gold
            
            let newOre = Ore(position: newPosition, type: randomType)
            self.ores[index] = newOre
            self.scene.rootNode.addChildNode(newOre.node)
        }
    }
    
    func updateCameraPosition() {
        let playerPos = player.node.position
        cameraNode.position = SCNVector3(playerPos.x, playerPos.y + 2, playerPos.z + 5)
        cameraNode.look(at: SCNVector3(playerPos.x, playerPos.y + 0.3, playerPos.z), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
    }
    
    func setupGameLoop() {
        // Empty - using renderer delegate
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        updatePlayerMovement()
        updateCameraPosition()
    }
    
    func updatePlayerMovement() {
        // Simulated keyboard input from keysPressed set
        var moveVector = SCNVector3(0, 0, 0)
        
        if keysPressed.contains("w") { moveVector.z -= 0.1 }
        if keysPressed.contains("a") { moveVector.x -= 0.1 }
        if keysPressed.contains("s") { moveVector.z += 0.1 }
        if keysPressed.contains("d") { moveVector.x += 0.1 }
        
        if moveVector.x != 0 || moveVector.z != 0 {
            player.node.position = SCNVector3(
                player.node.position.x + moveVector.x,
                player.node.position.y,
                player.node.position.z + moveVector.z
            )
            if !player.isWalking {
                player.playWalkAnimation()
            }
        } else {
            player.stopWalkAnimation()
        }
        
        // Clamp to map bounds
        let mapSize: Float = 25
        player.node.position.x = max(-mapSize, min(mapSize, player.node.position.x))
        player.node.position.z = max(-mapSize, min(mapSize, player.node.position.z))
        
        // Clamp vertical position
        if player.node.position.y < -6 {
            player.node.position.y = -6
        }
        
        MiningGameManager.shared.playerPosition = player.node.position
    }
    
    // Override pressesBegan and pressesEnded for keyboard input
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressEvent?) {
        for press in presses {
            if let key = press.key {
                switch key.characters.lowercased() {
                case "w", "a", "s", "d":
                    keysPressed.insert(key.characters.lowercased())
                case " ":
                    player.playJumpAnimation()
                case "e":
                    toggleSpade()
                case "t":
                    teleportToTop()
                default:
                    break
                }
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressEvent?) {
        for press in presses {
            if let key = press.key {
                keysPressed.remove(key.characters.lowercased())
            }
        }
    }
}

// MARK: - Main Entry Point
let controller = MiningGameViewController()
PlaygroundPage.current.liveView = controller
