
import UIKit
import AVFoundation
import KDCircularProgress
import MediaPlayer

var mediaItems = [MPMediaItem]()

var soundPlayer:AVAudioPlayer!

class ViewController: UIViewController, AVAudioPlayerDelegate {

    
    @IBOutlet weak var waveformView: SCSiriWaveformView!
    
    let player = MPMusicPlayerController.systemMusicPlayer()
    
    var flag = 0
    
    var playFlag = false
    
    var playItem = -1
    
    var timer = NSTimer()
    
    @IBOutlet weak var artwork: UIImageView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var progressView: KDCircularProgress!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var albumName: UILabel!
    
    @IBOutlet weak var play: UIButton!
    
    @IBAction func playPausePressed(sender: AnyObject) {
        
        if flag == 0{
            flag = 1
            play.setImage(UIImage(named: "pause"), forState: .Normal)
            avaudio()
            soundPlayer.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateAudioProgressView), userInfo: nil, repeats: true)
            soundPlayer.meteringEnabled = true
        }
        else{
            flag = 0
            timer.invalidate()
            play.setImage(UIImage(named: "play"), forState: .Normal)
            soundPlayer.pause()
        }
        
    }
    
    @IBAction func forwardPressed(sender: AnyObject) {
        player.skipToNextItem()
        avaudio()
        if flag == 1{
            soundPlayer.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateAudioProgressView), userInfo: nil, repeats: true)
        }
        updateAudioProgressView()
        soundPlayer.meteringEnabled = true
    }
    
    @IBAction func rewindPressed(sender: AnyObject) {
        player.skipToPreviousItem()
        avaudio()
        if flag == 1{
            soundPlayer.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateAudioProgressView), userInfo: nil, repeats: true)
        }
        updateAudioProgressView()
        soundPlayer.meteringEnabled = true
    }
    
    @IBAction func resetPressed(sender: AnyObject) {
        
        soundPlayer.pause()
        soundPlayer.currentTime = 0
        if flag == 1{
            soundPlayer.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateAudioProgressView), userInfo: nil, repeats: true)
        }
        else{
            progressView.angle = 0
        }
        
    }
    
    @IBAction func showList(sender: AnyObject) {
        performSegueWithIdentifier("showList", sender: self)
    }
    
    func avaudio(){
        songName.text = player.nowPlayingItem?.title!.uppercaseString
        albumName.text = player.nowPlayingItem?.albumTitle!.uppercaseString
        let current = player.nowPlayingItem
        let url = current?.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        let item = AVPlayerItem(URL: url)
        let info = item.asset.metadata 
        artwork.image = UIImage(named: "placeholder")
        for item in info {
                if item.commonKey  == "artwork" {
                    artwork.image = UIImage(data: item.value as! NSData)
                }
        }
        
        do{
            soundPlayer = try AVAudioPlayer(contentsOfURL: url)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        }catch let error as NSError{
            soundPlayer = nil
            songName.text = "\(error.localizedDescription)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progressThickness = 0.15
        progressView.trackThickness = 0.1
        progressView.progressColors = [UIColor(red: 240.0/255.0, green: 145/255.0, blue: 145/255.0, alpha: 1)]
        progressView.trackColor = UIColor(red: 239.0/255.0, green: 223/255.0, blue: 225/255.0, alpha: 1)
        
        waveformView.waveColor = UIColor(red: 240.0/255.0, green: 145/255.0, blue: 145/255.0, alpha: 1)
        waveformView.primaryWaveLineWidth = 100.0
        waveformView.numberOfWaves = 1
        bottomView.backgroundColor = UIColor(red: 240.0/255.0, green: 145/255.0, blue: 145/255.0, alpha: 1)
        
        mediaItems = MPMediaQuery.songsQuery().items!
        let mediaCollection = MPMediaItemCollection(items: mediaItems)
        player.setQueueWithItemCollection(mediaCollection)
        
        if playFlag == true{
            playFlag = false
            player.nowPlayingItem = mediaItems[playItem]
            avaudio()
            play.setImage(UIImage(named: "pause"), forState: .Normal)
            flag = 1
            soundPlayer.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateAudioProgressView), userInfo: nil, repeats: true)
            soundPlayer.meteringEnabled = true
        }
        else{
            avaudio()
        }
        artwork.layer.cornerRadius = 80
        artwork.layer.masksToBounds = false
        artwork.clipsToBounds = true
        
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateMeters))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)

    }
    
    func updateAudioProgressView(){
        let current = soundPlayer.currentTime/soundPlayer.duration * 360
        progressView.angle = Double(current)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func updateMeters() {
        soundPlayer.updateMeters()
        var i = soundPlayer.averagePowerForChannel(0)
        if i > -6{
            i = -6
        }
        let normalizedValue = pow(10, CGFloat(i)/20)
        waveformView.updateWithLevel(normalizedValue)
    }
    
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            if id == "goBack" {
                let unwindSegue = FirstUnwindSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                    
                })
                return unwindSegue
            }
        }
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
}

