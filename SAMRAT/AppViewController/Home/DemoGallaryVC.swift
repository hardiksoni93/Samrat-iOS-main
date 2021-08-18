//
//  DemoGallaryVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 12/05/21.
//

import UIKit
import FDWaveformView

class DemoGallaryVC: UIViewController, FDWaveformViewDelegate, AudioPlayerWaveFormDelegate {
    
    @IBOutlet var waveFormView: FDWaveformView!
    var audioPlayerManager:AudioPlayerManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        
        //MARK:- Waveform
        self.waveFormView.doesAllowScrubbing = true
        self.waveFormView.doesAllowStretch = true
        self.waveFormView.doesAllowScroll = true
        self.waveFormView.delegate = self
        self.waveFormView.progressColor = Colors.snomo
        self.waveFormView.wavesColor = UIColor.gray
        
        self.audioPlayerManager = AudioPlayerManager(self)
        
        if let getUrl = URL(string: "https://samrat.app/public/singer_audio/60828e39158121619168825.mp3") {
            self.downloadMp3File(getUrl)
//            self.loadAudio(fromiTunes: getUrl)
        }

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
                self.loadAudio(fromiTunes: destinationUrl)
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func loadAudio(fromiTunes url:URL) {
//        self.isFirstTime = false
        self.waveFormView.audioURL = url
        
        do {
            
            let getDuration  = try self.audioPlayerManager.loadAudio(at: url, audioVisualizationTimeInterval: 0.001)
            
//            self.audioPlayerManager.play(<#T##data: Data##Data#>, with: <#T##TimeInterval#>)
            JSN.log("getDuration ===>%@", getDuration)
//            self.totalTime = Double(getEndTime)
//            self.endTime.text = self.getTimeFormate(getEndTime)
//            self.song?.duration = String(format: "%.2f", Float(getEndTime))
            
        } catch let error {
            JSN.error("fail to load audion ==>%@", error)
        }
    }

    
    
    func audioDidUpdate(totalTime: TimeInterval, currentTime: TimeInterval) {
        JSN.log("totalTime ===>%@", totalTime)
        JSN.log("currentTime ===>%@", currentTime)
    }
    
    @IBAction func btnPlayPauseAction(_ sender: UIButton) {
        if self.audioPlayerManager.isRunning {
            do {
                try self.audioPlayerManager.pause()
            } catch _ {
                
            }
        }
        else {
            do {
                _ = try audioPlayerManager.resume()
            } catch let error {
                print("errro resume --> ",error.localizedDescription)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
