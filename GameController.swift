import SpriteKit
import AVFoundation

class GameController: NSObject {
    
    let view: SKView
    
    // The scene draws the tiles and cookie sprites, and handles swipes.
    let scene: GameScene
    
    // 1 - levels, movesLeft, score
    var level: Level!
    var movesLeft = 0
    var score = 0
    
    // 2 - labels, buttons and gesture recognizer
    let targetLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 22, color: SKColor.whiteColor(), shadowColor: SKColor.blackColor())
    let movesLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 22, color: SKColor.whiteColor(), shadowColor: SKColor.blackColor())
    let scoreLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 22,  color: SKColor.whiteColor(), shadowColor: SKColor.blackColor())
    
    var shuffleButton: ButtonNode!
    var gameOverPanel: SKSpriteNode!
    
    var tapOrClickGestureRecognizer: CCTapOrClickGestureRecognizer!
    
    // 3 - backgroundMusic player
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("Sounds/Mining by Moonlight", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
    }()
    
    init(skView: SKView) {
        view = skView
        scene = GameScene(size: skView.bounds.size)
        
        super.init()
        
        // 4 - create and configure the scene
        // Create and configure the scene.
        scene.scaleMode = .AspectFill
        
        // Load the level.
        level = Level(filename: "Levels/Level_1")
        scene.level = level
        scene.addTiles()
        scene.swipeHandler = handleSwipe

        
        // 5 - create the Sprite Kit UI components
        // Present the scene.
        skView.presentScene(scene)
        
        // Load and start background music.
        backgroundMusic.play()
        
        let nameLabelY = scene.size.height / 2 - 30
        let infoLabelY = nameLabelY - 34
        
        let targetNameLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 16, color: SKColor.whiteColor(), shadowColor: SKColor.blackColor())
        targetNameLabel.text = "Target:"
        targetNameLabel.position = CGPoint(x: -scene.size.width / 3, y: nameLabelY)
        scene.addChild(targetNameLabel)
        
        let movesNameLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 16, color: SKColor.whiteColor(), shadowColor: SKColor.blackColor())
        movesNameLabel.text = "Moves:"
        movesNameLabel.position = CGPoint(x: 0, y: nameLabelY)
        scene.addChild(movesNameLabel)
        
        let scoreNameLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 16, color: SKColor.whiteColor(), shadowColor: SKColor.blackColor())
        scoreNameLabel.text = "Score:"
        scoreNameLabel.position = CGPoint(x: scene.size.width / 3, y: nameLabelY)
        scene.addChild(scoreNameLabel)
        
        targetLabel.position = CGPoint(x: -scene.size.width / 3, y: infoLabelY)
        scene.addChild(targetLabel)
        movesLabel.position = CGPoint(x: 0, y: infoLabelY)
        scene.addChild(movesLabel)
        scoreLabel.position = CGPoint(x: scene.size.width / 3, y: infoLabelY)
        scene.addChild(scoreLabel)
        
        shuffleButton = ButtonNode(texture: SKTexture(imageNamed: "Button"))
        shuffleButton.position = CGPoint(x: 0, y:  -scene.size.height / 2 + shuffleButton.size.height)
        
        let nameLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 20, color: SKColor.whiteColor(), shadowColor: SKColor.blackColor())
        nameLabel.text = "Shuffle"
        nameLabel.verticalAlignmentMode = .Center
        
        shuffleButton.addChild(nameLabel)
        scene.addChild(shuffleButton)
        shuffleButton.hidden = true
        shuffleButton.action = { (button) in
            self.shuffle()
            
            // Pressing the shuffle button costs a move.
            self.decrementMoves()
        }

        // 6 - begin the game
        beginGame()
    }
    
    // 7 - beginGame(), shuffle(), handleSwipe(), handleMatches(), beginNextTurn(), updateLabels(), decrementMoves(), showGameOver(), hideGameOver()
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        
        level.resetComboMultiplier()
        
        scene.animateBeginGame() {
            self.shuffleButton.hidden = false
        }
        
        shuffle()
    }
    
    func shuffle() {
        // Delete the old cookie sprites, but not the tiles.
        scene.removeAllCookieSprites()
        
        // Fill up the level with new cookies, and create sprites for them.
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
    
    // This is the swipe handler. MyScene invokes this function whenever it
    // detects that the player performs a swipe.
    func handleSwipe(swap: Swap) {
        // While cookies are being matched and new cookies fall down to fill up
        // the holes, we don't want the player to tap on anything.
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    // This is the main loop that removes any matching cookies and fills up the
    // holes with new cookies. While this happens, the user cannot interact with
    // the app.
    func handleMatches() {
        // Detect if there are any matches left.
        let chains = level.removeMatches()
        
        // If there are no more matches, then the player gets to move again.
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        // First, remove any matches...
        scene.animateMatchedCookies(chains) {
            
            // Add the new scores to the total.
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            
            // ...then shift down any cookies that have a hole below them...
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                
                // ...and finally, add new cookies at the top.
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns) {
                    
                    // Keep repeating this cycle until there are no more matches.
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
        decrementMoves()
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func decrementMoves() {
        --movesLeft
        updateLabels()
        
        if score >= level.targetScore {
            gameOverPanel = SKSpriteNode(imageNamed: "LevelComplete")
            showGameOver()
        } else if movesLeft == 0 {
            gameOverPanel = SKSpriteNode(imageNamed: "GameOver")
            showGameOver()
        }
    }
    
    func showGameOver() {
        scene.addChild(gameOverPanel!)
        scene.userInteractionEnabled = false
        shuffleButton.hidden = true
        
        scene.animateGameOver() {
            self.tapOrClickGestureRecognizer = CCTapOrClickGestureRecognizer(target: self, action: "hideGameOver")
            self.view.addGestureRecognizer(self.tapOrClickGestureRecognizer)
        }
    }
    
    func hideGameOver() {
        
        view.removeGestureRecognizer(tapOrClickGestureRecognizer)
        tapOrClickGestureRecognizer = nil
        
        
        gameOverPanel.removeFromParent()
        gameOverPanel = nil
        
        gameOverPanel.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
    }
}