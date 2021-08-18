import UIKit
import MiniPlayer
import AVFoundation
import Kingfisher

class MusiciansDetailsViewController: UIViewController {
    
    @IBOutlet var musicianImgView: UIImageView!
    @IBOutlet var lblSingerName: UILabel!
    @IBOutlet var lblSingerDesc: UILabel!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var timeSlider: UISlider!
    
    
    //MARK:- @IBOutlets
    @IBOutlet var btnBookNow: UIButton!{
        didSet{
            btnBookNow.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var viewGradient: UIView!{
        didSet{
            viewGradient.layer.cornerRadius = 30.0
            viewGradient.clipsToBounds = true
            //            viewGradient.applyGradient(colours: [UIColor.black,UIColor.clear])
        }
    }
    
    var selectedSingerDetails:singersData? = nil
    
    
    
    
    fileprivate var startRendering = Date()
    fileprivate var endRendering = Date()
    fileprivate var startLoading = Date()
    fileprivate var endLoading = Date()
    fileprivate var profileResult = ""
    
    var player = AVPlayer()
    // Formatting time for display
    let timeFormatter = NumberFormatter()
    
    var audioPlayer: AVAudioPlayer?     // holds an audio player instance. This is an optional!
    var audioTimer: Timer?            // holds a timer instance
    var isDraggingTimeSlider = false
    
    
    var isPlaying = false {             // keep track of when the player is playing
        didSet {                        // This is a computed property. Changing the value
            setButtonState()            // invokes the didSet block
            playPauseAudio()
        }
    }
    
    var objMultipleSinger : MultipleSingerVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = Localized("SINGER").uppercased() //"SINGER"
        if objMultipleSinger != nil {
            self.btnBookNow.setTitle(Localized("Select Singer").uppercased(), for: .normal)
        }
        else {
            self.btnBookNow.setTitle(Localized("bookNow").uppercased(), for: .normal)
        }
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.lblSingerName.text = self.selectedSingerDetails?.name ?? ""
        self.lblSingerDesc.text = self.selectedSingerDetails?.description ?? ""
        
        //        https://samrat.app/public/singer_audio/60828e39158121619168825.mp3
        //        self.miniPlayer.durationTimeInSec = 0
        //        self.miniPlayer.delegate = self
        DispatchQueue.main.async {
            do {
                if let getMp3Url = URL.init(string: self.selectedSingerDetails?.audio ?? "") {
                    //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                    //                    self.miniPlayer.soundTrack = playerItem
                    //                    self.player = AVPlayer(playerItem: playerItem)
                    
                    
                    //                    self.audioPlayer = try AVAudioPlayer.init(contentsOf: getMp3Url)
                    //                    self.audioPlayer?.prepareToPlay()
                    //                    self.makeTimer()
                    
                    
                    self.downloadMp3File(getMp3Url)
                    
                }
            } catch let error {
                JSN.log("url erroer ===>%@", error.localizedDescription)
                // couldn't load file :(
            }
        }
        
        let url = URL(string: self.selectedSingerDetails?.detail_image ?? "")
        self.musicianImgView.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
                
        
        // Do any additional setup after loading the view.
    }
    
    func downloadMp3File(_ url:URL?) {
        
        if let audioUrl = url {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            //            print(destinationUrl)
            JSN.log("destinationUrl ===>%@", destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                do {
                    if let getMp3Url = URL.init(string: self.selectedSingerDetails?.audio ?? "") {
                        //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                        //                    self.miniPlayer.soundTrack = playerItem
                        //                    self.player = AVPlayer(playerItem: playerItem)
                        self.audioPlayer = try AVAudioPlayer.init(contentsOf: destinationUrl)
                        self.audioPlayer?.prepareToPlay()
                        self.makeTimer()
                    }
                } catch let error {
                    JSN.log("ger error ===>%@", error.localizedDescription)
                }
                
                //                self.loadAudio(fromiTunes: destinationUrl)
                // if the file doesn't exist
            } else {
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        do {
                            if let getMp3Url = URL.init(string: self.selectedSingerDetails?.audio ?? "") {
                                //                    let playerItem:AVPlayerItem = AVPlayerItem(url: getMp3Url)
                                //                    self.miniPlayer.soundTrack = playerItem
                                //                    self.player = AVPlayer(playerItem: playerItem)
                                self.audioPlayer = try AVAudioPlayer.init(contentsOf: destinationUrl)
                                self.audioPlayer?.prepareToPlay()
                                self.makeTimer()
                            }
                        } catch let error {
                            JSN.log("ger error ===>%@", error.localizedDescription)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    
    func setButtonState() {
        // When the play button is tapped the text changes
        // TODO: Use the enum below for button and player states
        if isPlaying {
//            self.playBtn.isHighlighted = true
//            self.playBtn.setTitle("Pause", for: .normal)
        } else {
//            self.playBtn.isHighlighted = false
//            self.playBtn.setTitle("Play", for: .normal)
        }
    }
    
    func playPauseAudio() {
        // audioPlayer is optional use guard to check it before using it.
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        // Check is playing then play or pause
        if isPlaying {
            audioPlayer.play()
//            self.playBtn.isHighlighted = false
        } else {
//            self.playBtn.isHighlighted = true
            audioPlayer.pause()
        }
    }
    
    @IBAction func onTapBookingAction(_ sender: UIButton) {
        if SamratGlobal.loggedInUser()?.user == nil {
            let loginVc = LoginViewController.object()
            loginVc.isNeedtobackToScreen = true
            self.navigationController?.pushViewController(loginVc, animated: true)
            
        }else {
            if objMultipleSinger != nil {
                self.objMultipleSinger?.selectedSinger.append((selectedSingerDetails)!)
                self.view.endEditing(true)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                let arrayString = [
                    "To confirm the reservation, an amount of 50 KD must be paid, which will be returned in case of disagreement.",
                    "In case of cancelation , we must be notified at least 24 hours before the concert, and there will be a 5% deduction of the total amount.",
                    "An SMS message will be sent within 24 hours to confirm your order, with a link to pay the full amount."
                ]
                let attStr = add(stringList: arrayString, font: UIFont.systemFont(ofSize: 15))
                AlertView.instance.showAlert(title: alertTitle, message: attStr, alertType: .twoButton)
                AlertView.instance.alertViewDelegate = self
            }
        }
        
    }
    
    @IBAction func onTapPlayAction(_ sender: UIButton) {
        isPlaying = !isPlaying
        sender.isSelected = !self.playBtn.isSelected
//        self.playPauseAudio()
    }
    
    
    // Update time when dragging the slider
    @IBAction func timeSliderChanged(sender: UISlider) {
        // Working on this
        // TODO: Implement Time Slider
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = audioPlayer.duration * Double(sender.value)
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func makeTimer() {
        // This function sets up the timer.
        if audioTimer != nil {
            audioTimer!.invalidate()
        }
        
        // audioTimer = Timer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.onTimer(_:)), userInfo: nil, repeats: true)
        
        audioTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc func onTimer(timer: Timer) {
        // Check the audioPlayer, it's optinal remember. Get the current time and duration
        guard let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration else {
            return
        }
        
        // Calculate minutes, seconds, and percent completed
        let mins = currentTime / 60
        // let secs = currentTime % 60
        let secs = currentTime.truncatingRemainder(dividingBy: 60)
        let percentCompleted = currentTime / duration
        
        // Use the number formatter, it might return nil so guard
        //    guard let minsStr = timeFormatter.stringFromNumber(NSNumber(mins)), let secsStr = timeFormatter.stringFromNumber(NSNumber(secs)) else {
        //      return
        //    }
        
        guard let minsStr = timeFormatter.string(from: NSNumber(value: mins)), let secsStr = timeFormatter.string(from: NSNumber(value: secs)) else {
            return
        }
        
        
        // Everything is cool so update the timeLabel and progress bar
        //        timeLabel.text = "\(minsStr):\(secsStr)"
        //        progressBar.progress = Float(percentCompleted)
        // Check that we aren't dragging the time slider before updating it
        if !isDraggingTimeSlider {
            timeSlider.value = Float(percentCompleted)
        }
    }
    
}

extension MusiciansDetailsViewController : AlertViewDelegate {
    func okayButtonTapped() {
        let bookNowVc = BookNowWothCalendarVC()
        bookNowVc.selectedSinger = self.selectedSingerDetails
        self.navigationController?.pushViewController(bookNowVc, animated: true)
    }
    
    func cancleButtonTapped() {
        
    }
    
    
}

extension MusiciansDetailsViewController: MiniPlayerDelegate {
    func didPlay(player: MiniPlayer) {
        print("Playing...")
    }
    
    func didStop(player: MiniPlayer) {
        print("Stopped")
    }
    
    func didPause(player: MiniPlayer) {
        print("Pause")
    }
}

