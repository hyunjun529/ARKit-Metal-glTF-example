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
    func rotateUsing(translation: float2, sensitivity: Float) {
        guard let scene = scene else { return }
        
//        let upVector = float3(0, 0, 1)
//        let rotationVec = float3(Float(translation.y) * sensitivity,
//                                 -Float(translation.x) * sensitivity,
//                                 0) // this yx-order is same cross(upNormal, rotation)
//        let cameraVec = scene.camera.rotation
//
//        let targetAxis = cross(upVector, cameraVec)
//        let targetRadian = dot(upVector, cameraVec)
//        let targetMat = matrix4x4_rotation(radians: targetRadian, axis: targetAxis)
//
//        let targetVec = targetMat * float4(rotationVec, 0)
//
//        scene.camera.rotation += targetVec.xyz
        
        let rotationVec = float3(Float(translation.y) * sensitivity,
                                 -Float(translation.x) * sensitivity,
                                 0) // this yx-order is same cross(upNormal, rotation)

        scene.camera.rotation += rotationVec
    }
    
    func translateUsing(translation: float3, sensitivity: Float) {
        guard let scene = scene else { return }
        
        var current: float4 = float4(scene.camera.position, 1)
        let translateVector: float4 = float4(Float(translation.x) * sensitivity,
                                             Float(translation.y) * sensitivity,
                                             Float(translation.z) * sensitivity,
                                             1)
        current += float4x4(rotation: scene.camera.rotation) * translateVector
        scene.camera.position = current.xyz
    }
}