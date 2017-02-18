
import UIKit
import AVFoundation


class ViewController: UIViewController,AVAudioPlayerDelegate {
    
    let visualizerAnimationDuration = 0.01

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var visualizerTimer:Timer! = Timer()
    var lowPassResults1:Double! = 0.0
    var lowPassResult:Double! = 0.0
    var audioPlayer:AVAudioPlayer!
    
    var audioVisualizer: ATAudioVisualizer!
    @IBOutlet weak var visualizerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initObservers()
        self.initAudioPlayer()
        self.initAudioVisualizer()

    }
    
    func initObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    }
    
    func initAudioPlayer() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Boys Edit Final", ofType: "mp3")!)
        let error: NSError?
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch let error {
            print(error)
        }
        audioPlayer.isMeteringEnabled = true
        self.audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
    }
    
    
    func initAudioVisualizer() {
        var frame = visualizerView.frame
        frame.origin.x = 0
        frame.origin.y = 0
        let visualizerColor = UIColor(red: 255.0 / 255.0, green: 84.0 / 255.0, blue: 116.0 / 255.0, alpha: 1.0)
        self.audioVisualizer = ATAudioVisualizer(barsNumber: 11, frame: frame, andColor: visualizerColor)
        visualizerView.addSubview(audioVisualizer)
    }
    
    func didEnterBackground()
    {
        self.stopAudioVisualizer()
    }
    
    func didEnterForeground()
    {
        if self.playPauseButton.isSelected
        {
            self.startAudioVisualizer()
        }
    }
    
    func startAudioVisualizer() {
        
        if visualizerTimer != nil
        {
            visualizerTimer.invalidate()
            visualizerTimer = nil
            
        }
        visualizerTimer = Timer.scheduledTimer(timeInterval: visualizerAnimationDuration, target: self, selector: #selector(visualizerTimerChanged), userInfo: nil, repeats: true)
        
    }
    
    func stopAudioVisualizer()
    {
        if visualizerTimer != nil
        {
            visualizerTimer.invalidate()
            visualizerTimer = nil
            
        }
        audioVisualizer.stop()

    }
    
    func visualizerTimerChanged(_ timer:CADisplayLink)
    {
        audioPlayer.updateMeters()
        let ALPHA: Double = 1.05
        let averagePower: Double =  Double(audioPlayer.averagePower(forChannel: 0))
        let averagePowerForChannel: Double = pow(10, (0.05 * averagePower))
        lowPassResult = ALPHA * averagePowerForChannel + (1.0 - ALPHA) * lowPassResult
        let averagePowerForChannel1: Double = pow(10, (0.05 * Double(audioPlayer.averagePower(forChannel: 1))))
        lowPassResults1 = ALPHA * averagePowerForChannel1 + (1.0 - ALPHA) * lowPassResults1
        audioVisualizer.animate(withChannel0Level: self._normalizedPowerLevelFromDecibels(audioPlayer.averagePower(forChannel: 0)), andChannel1Level: self._normalizedPowerLevelFromDecibels(audioPlayer.averagePower(forChannel: 1)))
        self.updateLabels()

    }
    
    
    func updateLabels() {
        self.currentTimeLabel.text! = self.convertSeconds(Float(audioPlayer.currentTime))
        self.remainingTimeLabel.text! = self.convertSeconds(Float(audioPlayer.duration) - Float(audioPlayer.currentTime))
    }
    
    
    func convertSeconds(_ secs: Float) -> String {
        var currentSecs = secs
        if currentSecs < 0.1 {
            currentSecs = 0
        }
        var totalSeconds = Int(secs)
        if currentSecs > 0.45 {
            totalSeconds += 1
        }
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func _normalizedPowerLevelFromDecibels(_ decibels: Float) -> Float {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        return powf((powf(10.0, 0.05 * decibels) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playPauseButtonPressed(_ sender: AnyObject) {
        if playPauseButton.isSelected {
            audioPlayer.pause()
            playPauseButton.setImage(UIImage(named: "play_")!, for: UIControlState())
            playPauseButton.setImage(UIImage(named: "play")!, for: .highlighted)
            playPauseButton.isSelected = false
            self.stopAudioVisualizer()
        }
        else {
            audioPlayer.play()
            playPauseButton.setImage(UIImage(named: "pause_")!, for: UIControlState())
            playPauseButton.setImage(UIImage(named: "pause")!, for: .highlighted)
            playPauseButton.isSelected = true
            self.startAudioVisualizer()
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
        playPauseButton.setImage(UIImage(named: "play_")!, for: UIControlState())
        playPauseButton.setImage(UIImage(named: "play")!, for: .highlighted)
        playPauseButton.isSelected = false
        self.currentTimeLabel.text! = "00:00"
        self.remainingTimeLabel.text! = self.convertSeconds(Float(audioPlayer.duration))
        self.stopAudioVisualizer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur")
        playPauseButton.setImage(UIImage(named: "play_")!, for: UIControlState())
        playPauseButton.setImage(UIImage(named: "play")!, for: .highlighted)
        playPauseButton.isSelected = false
        self.currentTimeLabel.text! = "00:00"
        self.remainingTimeLabel.text! = "00:00"
        self.stopAudioVisualizer()
    }
}

