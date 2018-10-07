import Metal
import CoreGraphics


/**
Debug Manager for Debug mode
*/
class DebugManager: Manager {
    var name: String
    
    var tmp: Float
    
    var test: String
    
    var scene: Scene
    
    
    init?(scene: Scene) {
        self.name = "Debug Manager"
        
        self.tmp = 0.0
        
        self.test = ""
        
        self.scene = scene
    }
    
    func drawableSizeWillChange(size: CGSize) {
        
    }
    
    func update() {
        test = ""
        
        tmp += 0.01
        
        test += String(tmp) + "\n"
        
        test += "\n"
        test += "Camera Position\n"
        test += String(scene.camera.position.x) + "\n"
        test += String(scene.camera.position.y) + "\n"
        test += String(scene.camera.position.z) + "\n"
        
        test += "\n"
        test += "Camera Rotation\n"
        test += String(scene.camera.rotation.x) + "\n"
        test += String(scene.camera.rotation.y) + "\n"
        test += String(scene.camera.rotation.z) + "\n"
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
    }
}
