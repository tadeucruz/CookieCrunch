import SpriteKit

@objc(CCView)
class CCView: SKView {
    
    var userInteractionEnabled: Bool = true
    
    override func hitTest(aPoint: NSPoint) -> NSView? {
        if userInteractionEnabled {
            return super.hitTest(aPoint)
        }
        return nil
    }
}