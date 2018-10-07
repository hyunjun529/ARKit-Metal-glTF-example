import Cocoa

/**
 Debug ViewController
 */
class DebugViewController: NSViewController {

    @IBOutlet weak var chkAutoUpdate: NSButton!
    
    @objc dynamic var strTest: String = ""

    var timer = Timer()
    var tickInterval: Double = 1/30
    
    var debugManager: DebugManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: self.tickInterval, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if chkAutoUpdate.state == NSControl.StateValue.on {
            strTest = String(self.debugManager.test)
        }
    }
    
    func setDebugManager(manager: DebugManager) {
        self.debugManager = manager
        
        strTest = String(self.debugManager.test)
    }
    
    @IBAction func btnUpdate(_ sender: NSButtonCell) {
        strTest = String(self.debugManager.test)
    }
}
