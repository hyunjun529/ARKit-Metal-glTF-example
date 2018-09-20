/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import CoreGraphics

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

class OrthographicCamera: Camera {
    var rect = Rectangle(left: 10, right: 10,
                         top: 10, bottom: 10)
    
    override init() {
        super.init()
    }
    
    init(rect: Rectangle, near: Float, far: Float) {
        super.init()
        self.rect = rect
        self.near = near
        self.far = far
    }
    
    override var projectionMatrix: float4x4 {
        return float4x4(orthographic: rect, near: near, far: far)
    }
}

class ThirdPersonCamera: Camera {
    var focus: Node
    var focusDistance: Float = 3
    var focusHeight: Float = 1.2
    
    init(focus: Node) {
        self.focus = focus
        super.init()
    }
    
    override var viewMatrix: float4x4 {
        position = focus.position - focusDistance * focus.forwardVector
        position.y = focusHeight
        rotation.y = focus.rotation.y
        return super.viewMatrix
    }
}



extension Renderer {
    func zoomUsing(delta: CGFloat, sensitivity: Float) {
        guard let scene = scene else { return }
        scene.camera.position.z += Float(delta) * sensitivity
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
        scene.camera.position.x += Float(translation.y) * sensitivity
        scene.camera.position.y -= Float(translation.x) * sensitivity
    }
}
