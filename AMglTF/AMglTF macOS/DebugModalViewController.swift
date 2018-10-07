import Cocoa

/**
 Debug Modal ViewController
 */
class DebugModalViewController: NSViewController {

    @objc dynamic var strTest: String = "hey! A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    
    @IBAction func dismissWordCountWindow(_ sender: NSButton) {
        let application = NSApplication.shared
        application.stopModal()
    }
}
