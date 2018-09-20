import UIKit
import Metal
import MetalKit
import ARKit

//extension MTKView : RenderDestinationProvider {
//}
//
//class GameViewController: UIViewController, MTKViewDelegate, ARSessionDelegate {
//
//    var session: ARSession!
//    var renderer: ARKitRenderer!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set the view's delegate
//        session = ARSession()
//        session.delegate = self
//
//        // Set the view to use the default device
//        if let view = self.view as? MTKView {
//            view.device = MTLCreateSystemDefaultDevice()
//            view.backgroundColor = UIColor.clear
//            view.delegate = self
//
//            guard view.device != nil else {
//                print("Metal is not supported on this device")
//                return
//            }
//
//            // Configure the renderer to draw to the view
//            renderer = ARKitRenderer(session: session, metalDevice: view.device!, renderDestination: view)
//
//            renderer.drawRectResized(size: view.bounds.size)
//        }
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleTap(gestureRecognize:)))
//        view.addGestureRecognizer(tapGesture)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//
//        // Run the view's session
//        session.run(configuration)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        // Pause the view's session
//        session.pause()
//    }
//
//    @objc
//    func handleTap(gestureRecognize: UITapGestureRecognizer) {
//        // Create anchor using the camera's current position
//        if let currentFrame = session.currentFrame {
//
//            // Create a transform with a translation of 0.2 meters in front of the camera
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.2
//            let transform = simd_mul(currentFrame.camera.transform, translation)
//
//            // Add a new anchor to the session
//            let anchor = ARAnchor(transform: transform)
//            session.add(anchor: anchor)
//        }
//    }
//
//
//    // MARK: - MTKViewDelegate
//    // Called whenever view changes orientation or layout is changed
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        renderer.drawRectResized(size: size)
//    }
//
//    // Called whenever the view needs to render
//    func draw(in view: MTKView) {
//        renderer.update()
//    }
//
//
//    // MARK: - ARSessionDelegate
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//    }
//}

// Our iOS specific view controller
class GameViewController: UIViewController, ARSessionDelegate {
    
    var renderer: Renderer!
    var mtkView: MTKView!
    var session: ARSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        session = ARSession()
        session.delegate = self
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        session.run(configuration)
        
        
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
        if(gesture.numberOfTouches == 2)
        {
            let translation = float2(Float(gesture.translation(in: gesture.view).x),
                                     Float(gesture.translation(in: gesture.view).y))
            renderer?.translateUsing(translation: translation)
            gesture.setTranslation(.zero, in: gesture.view)
        }
        else
        {
            let translation = float2(Float(gesture.translation(in: gesture.view).x),
                                     Float(gesture.translation(in: gesture.view).y))
            renderer?.rotateUsing(translation: translation)
            gesture.setTranslation(.zero, in: gesture.view)
        }
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
        }
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let sensitivity: Float = 0.8
        renderer?.zoomUsing(delta: gesture.scale - GameViewController.previousScale,
                            sensitivity: sensitivity)
        GameViewController.previousScale = gesture.scale
        if gesture.state == .ended {
            GameViewController.previousScale = 1
        }
    }
}
