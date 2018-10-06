import Cocoa
import MetalKit


/**
 IN PROGRESS
 */
class MacGameViewController: NSViewController {
    var renderer: Renderer!
    var mtkView: MTKView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        addGestureRecognizer(to: mtkView)
        
        mtkView.delegate = renderer
    }
    
    @IBAction func MenuDebugField(_ sender: NSMenuItem) {
        print("asdf")
    }
}


extension MacGameViewController {
    func addGestureRecognizer(to view: NSView) {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
        
        let rot = NSRotationGestureRecognizer(target: self, action: #selector(handleRot(gesture:)))
        view.addGestureRecognizer(rot)
        
        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick(gesture:)))
        view.addGestureRecognizer(click)
        
        let pinch = NSMagnificationGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        view.addGestureRecognizer(pinch)
    }
    
    // dolly, truck
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let translation = float3(-Float(gesture.translation(in: gesture.view).x),
                                 -Float(gesture.translation(in: gesture.view).y),
                                 0)
        
        renderer?.translateUsing(translation: translation,
                                 sensitivity: 0.01)
        
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    // Rotation
    @objc func handleRot(gesture: NSRotationGestureRecognizer) {
    }
    
    // click
    @objc func handleClick(gesture: NSClickGestureRecognizer) {
    }
    
    // zoom
    @objc func handlePinch(gesture: NSMagnificationGestureRecognizer) {
        renderer?.translateUsing(translation: float3(0, 0, Float(gesture.magnification)),
                                 sensitivity: 0.5)
    }
    
    // pan, tilt
    override func scrollWheel(with event: NSEvent) {
        let translation = float2(Float(event.deltaX),
                                 Float(event.deltaY))
        
        renderer?.rotateUsing(translation: translation,
                              sensitivity: 0.01)
    }
}
