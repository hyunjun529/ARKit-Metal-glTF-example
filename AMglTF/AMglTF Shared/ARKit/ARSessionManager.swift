import Metal
import ARKit

class ARSessionManager: Manager {
    var name: String
    
    var session: ARSession?
    
    init?(session: ARSession) {
        self.name = "ARSession"
        
        self.session = session
    }
    
    func update() {
        print("RRRRR")
    }
}
