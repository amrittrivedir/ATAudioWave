
import UIKit
import AVFoundation


class ViewController: UIViewController,AVAudioPlayerDelegate {
    
    let visualizerAnimationDuration = 0.01

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var visualizerTimer:NSTimer! = NSTimer()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)

    }
    
    func initAudioPlayer() {
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("Boys Edit Final", ofType: "mp3")!)
        var error: NSError?
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        }
        catch let error {
        }
        audioPlayer.meteringEnabled = true
        if error != nil {
            print("Error in audioPlayer: \(error!.localizedDescription)")
        }
        else {
            self.audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
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
        if self.playPauseButton.selected
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
        visualizerTimer = NSTimer.scheduledTimerWithTimeInterval(visualizerAnimationDuration, target: self, selector: #selector(visualizerTimerChanged), userInfo: nil, repeats: true)
        
    }
    
    func stopAudioVisualizer()
    {
        if visualizerTimer != nil
        {
            visualizerTimer.invalidate()
            visualizerTimer = nil
            
        }
        audioVisualizer.stopAudioVisualizer()

    }
    
    func visualizerTimerChanged(timer:CADisplayLink)
    {
        audioPlayer.updateMeters()
        let ALPHA: Double = 1.05
        let averagePower: Double =  Double(audioPlayer.averagePowerForChannel(0))
        let averagePowerForChannel: Double = pow(10, (0.05 * averagePower))
        lowPassResult = ALPHA * averagePowerForChannel + (1.0 - ALPHA) * lowPassResult
        let averagePowerForChannel1: Double = pow(10, (0.05 * Double(audioPlayer.averagePowerForChannel(1))))
        lowPassResults1 = ALPHA * averagePowerForChannel1 + (1.0 - ALPHA) * lowPassResults1
        audioVisualizer.animateAudioVisualizerWithChannel0Level(self._normalizedPowerLevelFromDecibels(audioPlayer.averagePowerForChannel(0)), andChannel1Level: self._normalizedPowerLevelFromDecibels(audioPlayer.averagePowerForChannel(1)))
        self.updateLabels()

    }
    
    
    func updateLabels() {
        self.currentTimeLabel.text! = self.convertSeconds(Float(audioPlayer.currentTime))
        self.remainingTimeLabel.text! = self.convertSeconds(Float(audioPlayer.duration) - Float(audioPlayer.currentTime))
    }
    
    
    func convertSeconds(secs: Float) -> String {
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

    func _normalizedPowerLevelFromDecibels(decibels: Float) -> Float {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        return powf((powf(10.0, 0.05 * decibels) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playPauseButtonPressed(sender: AnyObject) {
        if playPauseButton.selected {
            audioPlayer.pause()
            playPauseButton.setImage(UIImage(named: "play_")!, forState: .Normal)
            playPauseButton.setImage(UIImage(named: "play")!, forState: .Highlighted)
            playPauseButton.selected = false
            self.stopAudioVisualizer()
        }
        else {
            audioPlayer.play()
            playPauseButton.setImage(UIImage(named: "pause_")!, forState: .Normal)
            playPauseButton.setImage(UIImage(named: "pause")!, forState: .Highlighted)
            playPauseButton.selected = true
            self.startAudioVisualizer()
        }
    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
        playPauseButton.setImage(UIImage(named: "play_")!, forState: .Normal)
        playPauseButton.setImage(UIImage(named: "play")!, forState: .Highlighted)
        playPauseButton.selected = false
        self.currentTimeLabel.text! = "00:00"
        self.remainingTimeLabel.text! = self.convertSeconds(Float(audioPlayer.duration))
        self.stopAudioVisualizer()
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("audioPlayerDecodeErrorDidOccur")
        playPauseButton.setImage(UIImage(named: "play_")!, forState: .Normal)
        playPauseButton.setImage(UIImage(named: "play")!, forState: .Highlighted)
        playPauseButton.selected = false
        self.currentTimeLabel.text! = "00:00"
        self.remainingTimeLabel.text! = "00:00"
        self.stopAudioVisualizer()
    }
}

