import UIKit
import Metal
import MetalKit
import ARKit


// Our iOS specific view controller
class GameViewController: UIViewController, ARSessionDelegate {
    var mtkView: MTKView!
    var renderer: Renderer!
    
    var session: ARSession!
    var sessionManager: ARSessionManager!
    var sessionConfig: ARConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = self.view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }
        
        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black
        
        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }
        
        renderer = newRenderer
        
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        
        addGestureRecognizer(to: mtkView)
        
        mtkView.delegate = renderer
        
        
        // Set the view's delegate
        session = ARSession()
        session.delegate = self
        
        // Create a session configuration
        sessionConfig = ARWorldTrackingConfiguration()
        
        // Run the view's session
        session.run(sessionConfig)
        
        guard let newSessionManager = ARSessionManager(session: session, device: Renderer.device, scene: renderer.scene!) else {
            print("ARSessionManager cannot be initialized")
            return
        }
        
        sessionManager = newSessionManager
        
        
        // attach rednerer to AR
        renderer.attachManager(manager: sessionManager)
    }
    
    
    @IBAction func onoffAR(_ sender: UIButton) {
        print("on/off")
        if renderer.managers.count > 0 {
            renderer.managers.popLast()
            session.pause()
        }
        else {
            session.run(sessionConfig)
            renderer.attachManager(manager: sessionManager)
        }
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

/**
 for Input Event
 */
extension GameViewController {
    static var previousScale: CGFloat = 1
    
    func addGestureRecognizer(to view: UIView) {
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self,
                                             action: #selector(handlePinch(gesture:)))
        view.addGestureRecognizer(pinch)
        
        let tap = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = float2(Float(gesture.translation(in: gesture.view).x),
                                 Float(gesture.translation(in: gesture.view).y))
        
        if gesture.numberOfTouches == 2 {
            renderer?.translateUsing(translation: float3(-translation.x,
                                                         translation.y,
                                                         0),
                                     sensitivity: 0.02)
        }
        else {
            renderer?.rotateUsing(translation: float2(translation.x,
                                                      -translation.y),
                                  sensitivity: 0.01)
        }
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // Create anchor using the camera's current position
        if let currentFrame = session.currentFrame {

            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)

            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            session.add(anchor: anchor)
            
            print("TAP!", transform)
            
            print("rotation", renderer?.scene?.camera.rotation)
            print("position", renderer?.scene?.camera.position)
        }
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        renderer?.translateUsing(translation: float3(0,
                                                     0,
                                                     Float(gesture.scale - GameViewController.previousScale)),
                                 sensitivity: 5.0)
        
        GameViewController.previousScale = gesture.scale
        if gesture.state == .ended {
            GameViewController.previousScale = 1
        }
    }
}
