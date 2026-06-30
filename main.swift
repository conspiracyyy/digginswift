import UIKit
import SceneKit

class Ore {
    let node: SCNNode
    let position: SCNVector3
    var isCollected = false
    
    init(position: SCNVector3, type: String) {
        self.position = position
        self.node = SCNNode()
        
        let geometry = SCNSphere(radius: 0.2)
        geometry.segmentCount = 8
        
        switch type {
        case "gold":
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.84, blue: 0, alpha: 1)
        case "silver":
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        case "copper":
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.72, green: 0.45, blue: 0.2, alpha: 1)
        default:
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.31, green: 0.78, blue: 0.47, alpha: 1)
        }
        
        geometry.firstMaterial?.specular.contents = UIColor.white
        node.geometry = geometry
        node.position = position
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 3)
        let repeatAction = SCNAction.repeatForever(rotation)
        node.runAction(repeatAction)
    }
}

class PlayerCharacter {
    let node: SCNNode
    var isWalking = false
    var hasSpade = false
    
    init() {
        node = SCNNode()
        node.position = SCNVector3(0, 2, 0)
        createCharacter()
    }
    
    func createCharacter() {
        let headGeometry = SCNSphere(radius: 0.25)
        headGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let head = SCNNode(geometry: headGeometry)
        head.position = SCNVector3(0, 0.5, 0)
        node.addChildNode(head)
        
        let eyeGeometry = SCNSphere(radius: 0.06)
        eyeGeometry.firstMaterial?.diffuse.contents = UIColor.black
        let leftEye = SCNNode(geometry: eyeGeometry)
        leftEye.position = SCNVector3(-0.1, 0.65, 0.2)
        node.addChildNode(leftEye)
        
        let rightEye = SCNNode(geometry: eyeGeometry)
        rightEye.position = SCNVector3(0.1, 0.65, 0.2)
        node.addChildNode(rightEye)
        
        let bodyGeometry = SCNBox(width: 0.3, height: 0.5, length: 0.2, chamferRadius: 0.05)
        bodyGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let body = SCNNode(geometry: bodyGeometry)
        body.position = SCNVector3(0, 0.15, 0)
        node.addChildNode(body)
        
        let armGeometry = SCNBox(width: 0.12, height: 0.4, length: 0.12, chamferRadius: 0.03)
        armGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let leftArm = SCNNode(geometry: armGeometry)
        leftArm.position = SCNVector3(-0.25, 0.2, 0)
        leftArm.name = "leftArm"
        node.addChildNode(leftArm)
        
        let rightArm = SCNNode(geometry: armGeometry)
        rightArm.position = SCNVector3(0.25, 0.2, 0)
        rightArm.name = "rightArm"
        node.addChildNode(rightArm)
        
        let legGeometry = SCNBox(width: 0.12, height: 0.35, length: 0.12, chamferRadius: 0.03)
        legGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let leftLeg = SCNNode(geometry: legGeometry)
        leftLeg.position = SCNVector3(-0.1, -0.35, 0)
        leftLeg.name = "leftLeg"
        node.addChildNode(leftLeg)
        
        let rightLeg = SCNNode(geometry: legGeometry)
        rightLeg.position = SCNVector3(0.1, -0.35, 0)
        rightLeg.name = "rightLeg"
        node.addChildNode(rightLeg)
        
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
        
        let handleGeometry = SCNCylinder(radius: 0.02, height: 0.5)
        handleGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.2, blue: 0.0, alpha: 1)
        let handle = SCNNode(geometry: handleGeometry)
        handle.position = SCNVector3(0, 0.1, 0)
        handle.name = "spadeHandle"
        spadeHolder?.addChildNode(handle)
        
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

class Joystick: UIView {
    let outerCircle = UIView()
    let innerCircle = UIView()
    var isActive = false
    var valueChanged: ((CGFloat, CGFloat) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        
        outerCircle.layer.borderColor = UIColor.white.cgColor
        outerCircle.layer.borderWidth = 2
        outerCircle.layer.cornerRadius = 40
        outerCircle.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        addSubview(outerCircle)
        
        innerCircle.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        innerCircle.layer.cornerRadius = 20
        innerCircle.frame = CGRect(x: 30, y: 30, width: 40, height: 40)
        addSubview(innerCircle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            isActive = true
            handleTouch(touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            handleTouch(touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isActive = false
        innerCircle.frame = CGRect(x: 30, y: 30, width: 40, height: 40)
        valueChanged?(0, 0)
    }
    
    func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self)
        let centerX = outerCircle.frame.midX
        let centerY = outerCircle.frame.midY
        
        let dx = location.x - centerX
        let dy = location.y - centerY
        let distance = sqrt(dx * dx + dy * dy)
        let maxDistance: CGFloat = 40
        
        let finalX = distance > maxDistance ? (dx / distance) * maxDistance : dx
        let finalY = distance > maxDistance ? (dy / distance) * maxDistance : dy
        
        innerCircle.frame = CGRect(x: centerX + finalX - 20, y: centerY + finalY - 20, width: 40, height: 40)
        
        let normalizedX = finalX / 40
        let normalizedY = finalY / 40
        valueChanged?(normalizedX, normalizedY)
    }
}

class MiningGameViewController: UIViewController, SCNSceneRendererDelegate {
    var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var player: PlayerCharacter!
    var ores: [Ore] = []
    var oreCountLabel: UILabel!
    var spadeStatusLabel: UILabel!
    var joystick: Joystick!
    var currentMoveX: CGFloat = 0
    var currentMoveZ: CGFloat = 0
    var totalOres = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        setupScene()
        setupUI()
    }
    
    func setupScene() {
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.8))
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
            
            let types = ["gold", "silver", "copper", "emerald"]
            let randomType = types.randomElement() ?? "gold"
            
            let ore = Ore(position: position, type: randomType)
            ores.append(ore)
            scene.rootNode.addChildNode(ore.node)
        }
    }
    
    func setupUI() {
        let controlPanel = UIView(frame: CGRect(x: 0, y: view.bounds.height * 0.8, width: view.bounds.width, height: view.bounds.height * 0.2))
        controlPanel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.9)
        view.addSubview(controlPanel)
        
        oreCountLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 150, height: 40))
        oreCountLabel.text = "Ores: 0"
        oreCountLabel.textColor = UIColor.white
        oreCountLabel.font = UIFont.boldSystemFont(ofSize: 18)
        controlPanel.addSubview(oreCountLabel)
        
        spadeStatusLabel = UILabel(frame: CGRect(x: 10, y: 50, width: 150, height: 30))
        spadeStatusLabel.text = "Spade: ❌"
        spadeStatusLabel.textColor = UIColor.red
        spadeStatusLabel.font = UIFont.systemFont(ofSize: 16)
        controlPanel.addSubview(spadeStatusLabel)
        
        joystick = Joystick(frame: CGRect(x: 20, y: 10, width: 80, height: 80))
        joystick.valueChanged = { [weak self] x, y in
            self?.currentMoveX = x
            self?.currentMoveZ = y
            if x != 0 || y != 0 {
                self?.player.playWalkAnimation()
            } else {
                self?.player.stopWalkAnimation()
            }
        }
        controlPanel.addSubview(joystick)
        
        let jumpButton = UIButton(type: .system)
        jumpButton.frame = CGRect(x: view.bounds.width - 100, y: 20, width: 90, height: 50)
        jumpButton.setTitle("JUMP", for: .normal)
        jumpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        jumpButton.backgroundColor = UIColor.blue
        jumpButton.setTitleColor(UIColor.white, for: .normal)
        jumpButton.layer.cornerRadius = 8
        jumpButton.addTarget(self, action: #selector(jumpPressed), for: .touchUpInside)
        controlPanel.addSubview(jumpButton)
        
        let equipButton = UIButton(type: .system)
        equipButton.frame = CGRect(x: view.bounds.width - 100, y: 70, width: 90, height: 50)
        equipButton.setTitle("EQUIP", for: .normal)
        equipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        equipButton.backgroundColor = UIColor.orange
        equipButton.setTitleColor(UIColor.white, for: .normal)
        equipButton.layer.cornerRadius = 8
        equipButton.addTarget(self, action: #selector(toggleSpade), for: .touchUpInside)
        controlPanel.addSubview(equipButton)
        
        let tpButton = UIButton(type: .system)
        tpButton.frame = CGRect(x: view.bounds.width - 200, y: 20, width: 90, height: 50)
        tpButton.setTitle("TP TOP", for: .normal)
        tpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        tpButton.backgroundColor = UIColor.green
        tpButton.setTitleColor(UIColor.white, for: .normal)
        tpButton.layer.cornerRadius = 8
        tpButton.addTarget(self, action: #selector(teleportToTop), for: .touchUpInside)
        controlPanel.addSubview(tpButton)
        
        let digButton = UIButton(type: .system)
        digButton.frame = CGRect(x: view.bounds.width - 200, y: 70, width: 90, height: 50)
        digButton.setTitle("DIG", for: .normal)
        digButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        digButton.backgroundColor = UIColor.purple
        digButton.setTitleColor(UIColor.white, for: .normal)
        digButton.layer.cornerRadius = 8
        digButton.addTarget(self, action: #selector(digPressed), for: .touchUpInside)
        controlPanel.addSubview(digButton)
    }
    
    @objc func jumpPressed() {
        player.playJumpAnimation()
    }
    
    @objc func toggleSpade() {
        if player.hasSpade {
            player.unequipSpade()
            spadeStatusLabel.text = "Spade: ❌"
            spadeStatusLabel.textColor = UIColor.red
        } else {
            player.equipSpade()
            spadeStatusLabel.text = "Spade: ✅"
            spadeStatusLabel.textColor = UIColor.green
        }
    }
    
    @objc func teleportToTop() {
        player.node.position = SCNVector3(0, 2, 0)
        updateCameraPosition()
    }
    
    @objc func digPressed() {
        guard player.hasSpade else { return }
        
        let location = CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 0.4)
        let hitResults = sceneView.hitTest(location, options: [:])
        
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
    
    func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: sceneView)
        gesture.setTranslation(.zero, in: sceneView)
        
        let angleX = Float(translation.y) * 0.005
        let angleY = Float(translation.x) * 0.005
        
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
        
        totalOres += 1
        oreCountLabel.text = "Ores: \(totalOres)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let x = Float.random(in: -20...20)
            let y = Float.random(in: -7...0)
            let z = Float.random(in: -20...20)
            let newPosition = SCNVector3(x, y, z)
            
            let types = ["gold", "silver", "copper", "emerald"]
            let randomType = types.randomElement() ?? "gold"
            
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
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        updatePlayerMovement()
        updateCameraPosition()
    }
    
    func updatePlayerMovement() {
        let speed: Float = 0.1
        let moveDistance = SCNVector3(Float(currentMoveX) * speed, 0, Float(currentMoveZ) * speed)
        
        if moveDistance.x != 0 || moveDistance.z != 0 {
            player.node.position = SCNVector3(
                player.node.position.x + moveDistance.x,
                player.node.position.y,
                player.node.position.z + moveDistance.z
            )
        }
        
        let mapSize: Float = 25
        player.node.position.x = max(-mapSize, min(mapSize, player.node.position.x))
        player.node.position.z = max(-mapSize, min(mapSize, player.node.position.z))
        
        if player.node.position.y < -6 {
            player.node.position.y = -6
        }
    }
}

var app: MiningGameViewController?

func launchGame() {
    app = MiningGameViewController()
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = app
    window.makeKeyAndVisible()
}

launchGame()
