//
//  MainViewController.swift
//  VideoProgressBar
//
//  Created by Bimal@AppStation on 28/10/22.
//

import AVFoundation
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    var timer: Timer?
    var player: AVPlayer?
    var timeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(videoPlayerView)
        view.sendSubviewToBack(videoPlayerView)
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVideoPlayer()
        resetTimer()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        view.addGestureRecognizer(tapGesture)
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    @objc func hideControls() {
        playPauseButton.isHidden = true
        progressSlider.isHidden = true
        timeRemainingLabel.isHidden = true
    }
    
    @objc func toggleControls() {
        playPauseButton.isHidden = !playPauseButton.isHidden
        progressSlider.isHidden = !progressSlider.isHidden
        timeRemainingLabel.isHidden = !timeRemainingLabel.isHidden
        resetTimer()
    }
    
    func setupVideoPlayer() {
        player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Series", ofType: "mp4")!))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds;
        playerLayer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(playerLayer)
        
        videoPlayerView.addSubview(progressSlider)
//        view.sendSubviewToBack(videoPlayerView)
        videoPlayerView.addSubview(timeRemainingLabel)
        videoPlayerView.addSubview(viewPlay)
        player?.play()
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            self.updateVideoPlayerState()
        })
    }
    
    func updateVideoPlayerState() {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        progressSlider.value = Float(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            progressSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))

            // Update time remaining label
            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds

            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }
            timeRemainingLabel.text = "\(minsStr):\(secsStr)"
        }
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }
        if !player.isPlaying {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            player.pause()
        }
    }
    
    @IBAction func playbackSliderValueChanged(_ sender:UISlider)
    {
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player?.seek(to: seekTime )
    }
    
}


extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}









//How To Make Netflix Video Player in Swift
