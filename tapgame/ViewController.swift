
import UIKit

class ViewController: UIViewController {

    var score = 0
    var timeRemaining = 30
    var timer: Timer?
    var targetViews = [UIView]()
    var targetTypes = [String]() // "circle", "bomb", "freeze"
    var speed: CGFloat = 2.0
    var isFrozen = false
    var freezeTimeRemaining = 0
    
    let scoreLabel = UILabel()
    let timeLabel = UILabel()
    var gameActive = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupLabels()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateTargets), userInfo: nil, repeats: true)
    }

    private func setupBackground() {
        view.backgroundColor = .white
        
        let gridSize: CGFloat = 25.0
        let gridLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        for x in stride(from: 0, to: view.frame.width, by: gridSize) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: view.frame.height))
        }
        
        for y in stride(from: 0, to: view.frame.height, by: gridSize) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: view.frame.width, y: y))
        }
        
        gridLayer.path = path.cgPath
        gridLayer.strokeColor = UIColor.green.cgColor
        gridLayer.lineWidth = 0.5
        
        view.layer.addSublayer(gridLayer)
    }

    private func setupLabels() {
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = UIFont.systemFont(ofSize: 32)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        timeLabel.text = "Time: \(timeRemaining)"
        timeLabel.font = UIFont.systemFont(ofSize: 32)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20)
        ])
        
        generateInitialTargets()
    }
    
    private func generateInitialTargets() {
        for _ in 0..<10 { // Generate fewer initial targets
            let targetType = generateTargetType()
            targetTypes.append(targetType)
            addTarget(type: targetType)
        }
    }
    
    private func generateTargetType() -> String {
        let randomValue = Int.random(in: 1...100)
        if randomValue <= 90 {
            return "circle"
        } else if randomValue <= 95 {
            return "bomb"
        } else {
            return "freeze"
        }
    }

    private func addTarget(type: String) {
        let targetView = UIView()
        let size: CGFloat = 25
        
        switch type {
        case "circle":
            targetView.frame = CGRect(x: 0, y: 0, width: size, height: size)
            targetView.backgroundColor = .red
            targetView.layer.cornerRadius = size / 2
        case "bomb":
            targetView.frame = CGRect(x: 0, y: 0, width: size, height: size)
            targetView.backgroundColor = .clear
            drawDiamond(on: targetView, color: .black)
        case "freeze":
            targetView.frame = CGRect(x: 0, y: 0, width: size, height: size)
            targetView.backgroundColor = .clear
            drawSnowflake(on: targetView, color: .blue)
        default:
            targetView.frame = CGRect(x: 0, y: 0, width: size, height: size)
            targetView.backgroundColor = .gray
        }
        
        targetView.center = CGPoint(x: randomXPosition(), y: -size)


let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        targetView.addGestureRecognizer(tapGesture)
        
        targetViews.append(targetView)
        view.addSubview(targetView)
    }
    
    private func drawDiamond(on view: UIView, color: UIColor) {
        let size = view.bounds.size
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height / 2))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        view.layer.addSublayer(shapeLayer)
    }
    
    private func drawSnowflake(on view: UIView, color: UIColor) {
        let size = view.bounds.size
        let path = UIBezierPath()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Create a simple snowflake shape
        for i in 0..<6 {
            let angle = CGFloat(i) * (CGFloat.pi / 3.0)
            let dx = size.width / 2 * cos(angle)
            let dy = size.height / 2 * sin(angle)
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + dx, y: center.y + dy))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2.0
        view.layer.addSublayer(shapeLayer)
    }

    private func randomXPosition() -> CGFloat {
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        return CGFloat.random(in: safeAreaFrame.minX + 50...safeAreaFrame.maxX - 50)
    }
    
    private func randomYSpeed() -> CGFloat {
        return CGFloat.random(in: 1.0...5.0)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let targetView = sender.view else { return }
        
        if let index = targetViews.firstIndex(of: targetView) {
            switch targetTypes[index] {
            case "circle":
                score += 1
            case "bomb":
                score = max(0, score - 100)
            case "freeze":
                freezeTime()
            default:
                break
            }
            
            targetView.removeFromSuperview()
            targetViews.remove(at: index)
            targetTypes.remove(at: index)
        }
        
        scoreLabel.text = "Score: \(score)"
    }
    
    @objc private func updateGame() {
        if timeRemaining > 0 {
            if isFrozen {
                freezeTimeRemaining -= 1
                if freezeTimeRemaining <= 0 {
                    isFrozen = false
                }
            } else {
                timeRemaining -= 1
                timeLabel.text = "Time: \(timeRemaining)"
                speed += 0.1
                
                for _ in 0..<8 { // Generate 8 times more targets per update
                    let newType = generateTargetType()
                    targetTypes.append(newType)
                    addTarget(type: newType)
                }
            }
        } else if timeRemaining <= 0 {
            timer?.invalidate()
            showFinalScore()
        }
    }
    
    @objc private func updateTargets() {
        guard !isFrozen else { return }
        
        for (index, targetView) in targetViews.enumerated().reversed() {
            targetView.center.y += randomYSpeed()
            
            if targetView.frame.origin.y > view.frame.height {
                targetView.removeFromSuperview()
                targetViews.remove(at: index)
                targetTypes.remove(at: index)
            }
        }
    }
    
    private func freezeTime() {
        isFrozen = true
        freezeTimeRemaining = 5 // Freeze for 5 ticks (0.5 seconds per tick, so 2.5 seconds total)
    }

    private func showFinalScore() {

let alert = UIAlertController(title: "Game Over", message: "Your final score is \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.resetGame()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func resetGame() {
        score = 0
        timeRemaining = 30
        speed = 2.0
        isFrozen = false
        freezeTimeRemaining = 0

        
scoreLabel.text = "Score: \(score)"
        timeLabel.text = "Time: \(timeRemaining)"
        
        for targetView in targetViews {
            targetView.removeFromSuperview()
        }
        targetViews.removeAll()
        targetTypes.removeAll()
        
        generateInitialTargets()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
    }
}
