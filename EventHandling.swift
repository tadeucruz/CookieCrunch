import SpriteKit

// MARK: - cross-platform object type aliases

#if os(iOS)
    typealias CCUIEvent = UITouch
#else
    typealias CCUIEvent = NSEvent
#endif

extension SKNode {
    
    #if os(iOS)
    
    // MARK: - iOS Touch handling
    
    override public func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)  {
        userInteractionBegan(touches.first as! UITouch)
    }
    
    override public func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)  {
        userInteractionContinued(touches.first as! UITouch)
    }
    
    override public func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        userInteractionEnded(touches.first as! UITouch)
    }
    
    override public func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        userInteractionCancelled(touches.first as! UITouch)
    }
    
    #else
    
    // MARK: - OS X mouse event handling
    
    override public func mouseDown(event: NSEvent) {
        userInteractionBegan(event)
    }
    
    override public func mouseDragged(event: NSEvent) {
        userInteractionContinued(event)
    }
    
    override public func mouseUp(event: NSEvent) {
        userInteractionEnded(event)
    }
    
    #endif
    
    // MARK: - Cross-platform event handling
    
    func userInteractionBegan(event: CCUIEvent) {
    }
    
    func userInteractionContinued(event: CCUIEvent) {
    }
    
    func userInteractionEnded(event: CCUIEvent) {
    }
    
    func userInteractionCancelled(event: CCUIEvent) {
    }
    
}