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


class GameScene: Scene {
    let ground = Prop(name: "large-plane")
    let car = Prop(name: "racing-car")
    let train = Prop(name: "train")
    let skeleton = Character(name: "skeleton")
    var inCar = false
    let orthoCamera = OrthographicCamera()
    
    override func setupScene() {        
        ground.tiling = 32
        add(node: ground)
        
        train.rotation = [0, radians(fromDegrees: 180), 0]
        train.position = [2.2, 0, 1]
        add(node: train)
        
        car.rotation = [0, radians(fromDegrees: 180), 0]
        car.position = [-0.8, 0, 0.5]
        add(node: car)
        
        skeleton.position = [1.2, 0, 0]
        add(node: skeleton)
        skeleton.runAnimation(name: "Armature_walk")
        skeleton.currentAnimation?.speed = 3.0
        skeleton.pauseAnimation()
        
        orthoCamera.position = [0, 2, 0]
        orthoCamera.rotation.x = .pi / 2
        cameras.append(orthoCamera)
        
        let tpCamera = ThirdPersonCamera(focus: skeleton)
        cameras.append(tpCamera)
        
        let normalCamera = Camera()
        cameras.append(normalCamera)
        
        currentCameraIndex = 1
    }
    
    override func updateScene(deltaTime: Float) {
        skeleton.resumeAnimation()
    }
    
    override func sceneSizeWillChange(to size: CGSize) {
        super.sceneSizeWillChange(to: size)
        let cameraSize: Float = 10
        let ratio = Float(sceneSize.width / sceneSize.height)
        let rect = Rectangle(left: -cameraSize * ratio,
                             right: cameraSize * ratio,
                             top: cameraSize, bottom: -cameraSize)
        orthoCamera.rect = rect
    }
}
