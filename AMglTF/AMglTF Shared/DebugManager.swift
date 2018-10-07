import Metal
import CoreGraphics


/**
Debug Manager for Debug mode
*/
class DebugManager: Manager {
    var name: String
    
    var test: Float = 0.0
    
    init?() {
        self.name = "Debug Manager"
    }
    
    func drawableSizeWillChange(size: CGSize) {
        
    }
    
    func update() {
        test = test + 0.01
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
    }
}
