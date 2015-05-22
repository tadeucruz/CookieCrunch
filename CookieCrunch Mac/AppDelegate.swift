import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: CCView!
    
    var gameController: GameController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        gameController = GameController(skView: skView)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}