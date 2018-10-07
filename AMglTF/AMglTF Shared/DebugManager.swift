import Metal
import CoreGraphics


/**
Debug Manager for Debug mode
*/
class DebugManager: Manager {
    var name: String
    
    init?() {
        self.name = "Debug Manager"
    }
    
    func drawableSizeWillChange(size: CGSize) {
        
    }
    
    func update() {
        
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
    }
}
