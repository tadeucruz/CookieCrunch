import UIKit
import SpriteKit
import AVFoundation

typealias CCView = SKView

class GameViewController: UIViewController {
    
    var gameController: GameController!
           
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! CCView
        skView.multipleTouchEnabled = false
        
        gameController = GameController(skView: skView)
    }
    
}