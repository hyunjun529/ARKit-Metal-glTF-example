import Foundation
import CoreGraphics

/**
 IN PROGRESS
 */
class GameScene: Scene {
    let ground = Prop(name: "large-plane")
    let worldOrientation = Prop(name: "axis")
    let car = Prop(name: "racing-car")
    let train = Prop(name: "train")
    let skeleton = Character(name: "skeleton")
    let riggedSimple = Character(name: "RiggedSimple")
    var inCar = false
    
    override func setupScene() {        
        ground.tiling = 4
        ground.scale = float3(0.1, 0.1, 0.1)
        add(node: ground)
        
        worldOrientation.position = float3(0)
        add(node: worldOrientation)
        
        train.rotation = [0, radians(fromDegrees: 270), 0]
        train.position = [2.2, 0, -1.5]
        add(node: train)
        
        car.rotation = [0, radians(fromDegrees: 0), 0]
        car.scale = float3(0.8, 0.8, 0.8)
        car.position = [-1.8, 0, -1.5]
        add(node: car)
        
        riggedSimple.position = [2.2, 0.5, 2]
        riggedSimple.rotation = [radians(fromDegrees: 270), 0, radians(fromDegrees: 90)]
        riggedSimple.scale = float3(0.1, 0.1, 0.1)
        add(node: riggedSimple)
        riggedSimple.runAnimation(name: "sample")
        riggedSimple.currentAnimation?.speed = 3.0
        riggedSimple.pauseAnimation()
        
        skeleton.position = [-1.2, 0, 1.5]
        add(node: skeleton)
        skeleton.runAnimation(name: "Armature_walk")
        skeleton.currentAnimation?.speed = 3.0
        skeleton.pauseAnimation()
        
        
        let normalCamera = Camera()
        normalCamera.position = [0, 7.2, 11.5]
        normalCamera.rotation = [-6.0, -3.14, 0]
        cameras.append(normalCamera)
        
        currentCameraIndex = 1
    }
    
    override func updateScene(deltaTime: Float) {
        skeleton.resumeAnimation()
        riggedSimple.resumeAnimation()
    }
    
    override func sceneSizeWillChange(to size: CGSize) {
        super.sceneSizeWillChange(to: size)
    }
}
