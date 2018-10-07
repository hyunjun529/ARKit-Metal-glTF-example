import Cocoa

/**
 Debug ViewController
 */
class DebugViewController: NSViewController {

    @IBOutlet weak var chkAutoUpdate: NSButton!
    
    @objc dynamic var strTest: String = ""

    var timer = Timer()
    var tickInterval: Double = 1/30
    
    var debugManger: DebugManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: self.tickInterval, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if chkAutoUpdate.state == NSControl.StateValue.on {
            strTest = String(self.debugManger.test)
        }
    }
    
    func setDebugManager(manager: DebugManager) {
        self.debugManger = manager
        
        strTest = String(self.debugManger.test)
    }
    
    @IBAction func btnUpdate(_ sender: NSButtonCell) {
        strTest = String(self.debugManger.test)
    }
}
