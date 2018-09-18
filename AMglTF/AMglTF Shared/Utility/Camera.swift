import Foundation
import MetalKit

/**
 this is Camera for virtual stage

 set position, rotation and scale then stored properties return View & Projection Matrix
 */
class Camera: Node {
    
    var fovDegrees: Float = 50
    var fovRadians: Float {
        return radians(fromDegrees: fovDegrees)
    }
    var aspect: Float = 1
    var near: Float = 0.01
    var far: Float = 100
    
    var projectionMatrix: float4x4 {
        return float4x4(projectionFov: fovRadians,
                        near: near,
                        far: far,
                        aspect: aspect)
    }
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position).inverse
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * scaleMatrix * rotateMatrix
    }
}


extension Renderer {
    func zoomUsing(delta: CGFloat, sensitivity: Float) {
        camera.position.z += Float(delta) * sensitivity
    }
    
    func rotateUsing(translation: float2) {
        let sensitivity: Float = 0.01
        camera.rotation.x += Float(translation.y) * sensitivity
        camera.rotation.y -= Float(translation.x) * sensitivity
    }
}
