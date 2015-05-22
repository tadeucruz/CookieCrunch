import SpriteKit

class ButtonNode: SKSpriteNode {
    
    // 1 - action to be invoked when the button is tapped/clicked on
    var action: ((ButtonNode) -> Void)?
    
    // 2
    var isSelected: Bool = false {
        didSet {
            alpha = isSelected ? 0.8 : 1
        }
    }
    
    // MARK: - Initialisers
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // 3
    init(texture: SKTexture) {
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        userInteractionEnabled = true
    }
    
    // MARK: - Cross-platform user interaction handling
    
    // 4
    override func userInteractionBegan(event: CCUIEvent) {
        isSelected = true
    }
    
    // 5
    override func userInteractionContinued(event: CCUIEvent) {
        let location = event.locationInNode(parent)
        
        if CGRectContainsPoint(frame, location) {
            isSelected = true
        } else {
            isSelected = false
        }
    }
    
    // 6
    override func userInteractionEnded(event: CCUIEvent) {
        isSelected = false
        
        let location = event.locationInNode(parent)
        
        if CGRectContainsPoint(frame, location) {
            // 7
            action?(self)
        }
    }
}