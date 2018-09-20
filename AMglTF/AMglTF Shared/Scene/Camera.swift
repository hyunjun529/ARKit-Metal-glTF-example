import Foundation
import CoreGraphics

/**
 Camera
 
 - default structure with Node from [Metal by Tutorial](https://store.raywenderlich.com/products/metal-by-tutorials)

 - Camera Calculation and Implement from [LearnOpenGL](https://learnopengl.com/Getting-started/Camera)
 */
class Camera: Node {
    
    var fovDegrees: Float = 70
    var fovRadians: Float {
        return radians(fromDegrees: fovDegrees)
    }
    var aspect: Float = 1
    var near: Float = 0.001
    var far: Float = 100
    
    
    var projectionMatrix: float4x4 {
        return float4x4(projectionFov: fovRadians,
                        near: near,
                        far: far,
                        aspect: aspect)
    }
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
}


/// for Input Event in Controller
extension Renderer {
    func zoomUsing(delta: CGFloat, sensitivity: Float) {
        guard let scene = scene else { return }
        
        
        var current: float3 = scene.camera.position
        current += scene.camera.quaternion.axis * float3(0, 0, Float(delta) * sensitivity)
        scene.camera.position = current
    }
    
    func rotateUsing(translation: float2) {
        guard let scene = scene else { return }
        
        let sensitivity: Float = 0.01
        
        scene.camera.rotation.x += Float(translation.y) * sensitivity
        scene.camera.rotation.y -= Float(translation.x) * sensitivity
    }
    
    func translateUsing(translation: float2) {
        guard let scene = scene else { return }
        
        let sensitivity: Float = 0.01
        
        scene.camera.position.x += Float(translation.x) * sensitivity
        scene.camera.position.y -= Float(translation.y) * sensitivity
    }
}
