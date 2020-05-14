//
//  VideoCallVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import AVFoundation
import Quickblox
import QuickbloxWebRTC


enum CameraType {
    case front
    case back
}

var camera = CameraType.back


class VideoCallVC: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var textViewEdit: UITextView!
    @IBOutlet weak var labelVideoPause: UILabel!
    @IBOutlet weak var opponentView: QBRTCRemoteVideoView!
    
    @IBOutlet weak var constarintLayoutHeightTextView: NSLayoutConstraint!
    @IBOutlet weak var constarintLayoutHeightButtonsView: NSLayoutConstraint!
    
    
    //MARK: - Internal Properties
    private var timeDuration: TimeInterval = 0.0
    
    private var callTimer: Timer?
    private var beepTimer: Timer?
    
    
     weak var usersDataSource: UsersDataSource?
    //Camera
   // var session: QBRTCSession?
    var callUUID: UUID?
    var videoPause : Bool = false
    
    //Camera
    var videoCapture: QBRTCCameraCapture?
    var session: QBRTCSession?
    
    //Containers
    private var users = [User]()
    private var videoViews = [UInt: UIView]()
    private var statsUserID: UInt?
    
    //Views
       lazy private var dynamicButton: CustomButton = {
           let dynamicButton = ButtonsFactory.dynamicEnable()
           return dynamicButton
       }()
       
       lazy private var audioEnabled: CustomButton = {
           let audioEnabled = ButtonsFactory.audioEnable()
           return audioEnabled
       }()
       
       private var localVideoView: LocalVideoView?
       
       
       
       //States
       private var shouldGetStats = false
       private var didStartPlayAndRecord = false
       private var muteVideo = false {
           didSet {
               session?.localMediaStream.videoTrack.isEnabled = !muteVideo
           }
       }
       
       private var state = CallViewControllerState.connected {
           didSet {
               switch state {
               case .disconnected:
                   title = CallStateConstant.disconnected
               case .connecting:
                   title = CallStateConstant.connecting
               case .connected:
                   title = CallStateConstant.connected
               case .disconnecting:
                   title = CallStateConstant.disconnecting
               }
           }
       }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
     //   QBRTCClient.instance().add(self as! QBRTCClientDelegate)
              
              let videoFormat = QBRTCVideoFormat()
              videoFormat.frameRate = 30
              videoFormat.pixelFormat = .format420f
              videoFormat.width = 640
              videoFormat.height = 480
              
              // QBRTCCameraCapture class used to capture frames using AVFoundation APIs
              self.videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
              
              // add video capture to session's local media stream
              self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
              
              self.videoCapture?.previewLayer.frame = self.previewView.bounds
              self.videoCapture?.startSession()
              
              self.previewView.layer.insertSublayer(self.videoCapture!.previewLayer, at: 0)
              
        
      //  self.setupAVCapture()
     //   self.setUpView()
    }
    
    func setUpView()  {
        self.constarintLayoutHeightTextView.constant = 0
        self.constarintLayoutHeightButtonsView.constant = 44
        self.labelVideoPause.isHidden = true
        
        QBRTCClient.instance().add(self as QBRTCClientDelegate)
        QBRTCAudioSession.instance().addDelegate(self)
              
        let profile = Profile()
        
        guard profile.isFull == true, let currentConferenceUser = Profile.currentUser() else {
                  return
              }
              
              let audioSession = QBRTCAudioSession.instance()
              if audioSession.isInitialized == false {
                  audioSession.initialize { configuration in
                      // adding blutetooth support
                      configuration.categoryOptions.insert(.allowBluetooth)
                      configuration.categoryOptions.insert(.allowBluetoothA2DP)
                      configuration.categoryOptions.insert(.duckOthers)
                      // adding airplay support
                      configuration.categoryOptions.insert(.allowAirPlay)
                      guard let session = self.session else { return }
                      if session.conferenceType == .video {
                          // setting mode to video chat to enable airplay audio and speaker only
                          configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                      }
                  }
              }
        configureGUI()
        
    }

    override var shouldAutorotate: Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
        UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
        UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func didTapButtonMinimize(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapButtonCall(_ sender: Any) {
        
        self.session?.hangUp(["hangup": "hang up"])
        //self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapButtonCamera(_ sender: Any) {
        
    }
    @IBAction func didTapButtonVideoPause(_ sender: Any) {
        if (self.muteVideo) {
            self.muteVideo = !muteVideo
            self.localVideoView?.isHidden = !muteVideo
                           }
        
    }
    @IBAction func didTapButtonAudioMute(_ sender: Any) {
        
        self.audioEnabled.pressed = !self.audioEnabled.pressed
        
//          let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
//        let device = previousDevice == .speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
//        QBRTCAudioSession.instance().currentAudioDevice = device
        
    }
    @IBAction func didTapButtonNotes(_ sender: Any) {
        self.constarintLayoutHeightTextView.constant = 187
        self.constarintLayoutHeightButtonsView.constant = 0
    }
    
    @IBAction func didTapButtonCheckBox(_ sender: Any) {
        self.constarintLayoutHeightTextView.constant = 0
        self.constarintLayoutHeightButtonsView.constant = 44
    }
    
    @IBAction func didTapButtonText(_ sender: Any) {
        
    }
    @IBAction func didTapButtonSmily(_ sender: Any) {
    }
}

extension VideoCallVC {

     //MARK - Setup
     func configureGUI() {
        
        self.navigationController?.navigationBar.isHidden = true
        
         // when conferenceType is nil, it means that user connected to the session as a listener
         if let conferenceType = session?.conferenceType {
             switch conferenceType {
             case .video:
                 break
             case .audio:
                 if UIDevice.current.userInterfaceIdiom == .phone {
                     QBRTCAudioSession.instance().currentAudioDevice = .receiver
                     dynamicButton.pressed = false
                 }
             }

             session?.localMediaStream.audioTrack.isEnabled = true;
             
             CallKitManager.instance.onMicrophoneMuteAction = { [weak self] in
                 guard let self = self else {return}
                 self.audioEnabled.pressed = !self.audioEnabled.pressed
             }
             
         }
                  
         let mask: UIView.AutoresizingMask = [.flexibleWidth,
                                              .flexibleHeight,
                                              .flexibleLeftMargin,
                                              .flexibleRightMargin,
                                              .flexibleTopMargin,
                                              .flexibleBottomMargin]
         
         // add button to enable stats view
         state = .connecting
     }
    func reloadAcceptCall() {
    
        let videoFormat = QBRTCVideoFormat()
     //   videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
       // videoFormat.width = 640
    //    videoFormat.height = 480
        
        // QBRTCCameraCapture class used to capture frames using AVFoundation APIs
        self.videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
        
        // add video capture to session's local media stream
        self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
        
    //    self.videoCapture?.previewLayer.frame = self.localVideo.bounds
        self.videoCapture?.startSession()
        
        self.previewView.layer.insertSublayer(self.videoCapture!.previewLayer, at: 0)
        
     //    let remoteVideoTrack = self.session?.remoteVideoTrack(withUserID: 108764506)
        
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.reloadAcceptCall()
        })
        
    }
    func startCall() {
           //Begin play calling sound
           beepTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(),
                                            target: self,
                                            selector: #selector(playCallingSound(_:)),
                                            userInfo: nil, repeats: true)
           playCallingSound(nil)
           //Start call
           let userInfo = ["name": "Test", "url": "http.quickblox.com", "param": "\"1,2,3,4\""]
           
           session?.startCall(userInfo)
       }
       
       func acceptCall() {
           SoundProvider.stopSound()
           //Accept call
          self.reloadAcceptCall()
           let userInfo = ["acceptCall": "userInfo"]
           session?.acceptCall(userInfo)
       }
       
       private func closeCall() {
           
           CallKitManager.instance.endCall(with: callUUID)
           videoCapture?.stopSession(nil)
           
           let audioSession = QBRTCAudioSession.instance()
           if audioSession.isInitialized == true,
               audioSession.audioSessionIsActivatedOutside(AVAudioSession.sharedInstance()) == false {
               debugPrint("[CallViewController] Deinitializing QBRTCAudioSession.")
               audioSession.deinitialize()
           }
           
           if let beepTimer = beepTimer {
               beepTimer.invalidate()
               self.beepTimer = nil
               SoundProvider.stopSound()
           }
           
           if let callTimer = callTimer {
               callTimer.invalidate()
               self.callTimer = nil
           }
           
           state = .disconnected
           QBRTCClient.instance().remove(self as QBRTCClientDelegate)
           QBRTCAudioSession.instance().removeDelegate(self)
           
         //  title = "End - \(string(withTimeDuration: timeDuration))"
       }
              
       
//       //MARK: - Internal Methods
//       private func zoomUser(userID: UInt) {
//           statsUserID = userID
//
//           navigationItem.rightBarButtonItem = statsItem
//       }
//
//       private func unzoomUser() {
//           statsUserID = nil
//           navigationItem.rightBarButtonItem = nil
//       }
    
    private func userView(userID: UInt) -> UIView? {
        
        let profile = Profile()
        
        if profile.isFull == true, profile.ID == userID,
            session?.conferenceType != .audio {
            
            if videoCapture?.hasStarted == false {
                videoCapture?.startSession(nil)
                session?.localMediaStream.videoTrack.videoCapture = videoCapture
            }
            //Local preview
            if let result = videoViews[userID] as? LocalVideoView {
                return result
            } else if let previewLayer = videoCapture?.previewLayer {
                let localVideoView = LocalVideoView(previewlayer: previewLayer)
                videoViews[userID] = localVideoView
                localVideoView.delegate = self
                self.localVideoView = localVideoView
                
                return localVideoView
            }
            
        } else if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: userID)) {
            
            if let result = videoViews[userID] as? QBRTCRemoteVideoView {
                result.setVideoTrack(remoteVideoTraсk)
                return result
            } else {
                //Opponents
                let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
                remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                videoViews[userID] = remoteVideoView
                 self.opponentView.setVideoTrack(remoteVideoTraсk)
              //  remoteVideoView.setVideoTrack(remoteVideoTraсk)
                self.previewView = remoteVideoView
                return remoteVideoView
            }
        }
        return nil
    }
     
     private func createConferenceUser(userID: UInt) -> User {
         guard let usersDataSource = self.usersDataSource,
             let user = usersDataSource.user(withID: userID) else {
                 let user = QBUUser()
                 user.id = userID
                 return User(user: user)
         }
         return User(user: user)
     }
     
     private func userIndexPath(userID: UInt) -> IndexPath {
         guard let index = users.index(where: { $0.userID == userID }), index != NSNotFound else {
             return IndexPath(row: 0, section: 0)
         }
         return IndexPath(row: index, section: 0)
     }
     
     func reloadContent() {
         videoViews.values.forEach{ $0.removeFromSuperview() }
     }
     
     // MARK: - Helpers
     private func cancelCallAlertWith(_ title: String) {
         let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
         let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
             self.closeCall()
         }
         alert.addAction(cancelAction)
         present(alert, animated: false) {
         }
     }
     
     // MARK: - Timers actions
     @objc func playCallingSound(_ sender: Any?) {
         SoundProvider.playSound(type: .calling)
     }
     
     @objc func refreshCallTime(_ sender: Timer?) {
         timeDuration += CallConstant.refreshTimeInterval
      //   title = "Call time - \(string(withTimeDuration: timeDuration))"
     }
     
     func string(withTimeDuration timeDuration: TimeInterval) -> String {
         let hours = Int(timeDuration / 3600)
         let minutes = Int(timeDuration / 60)
         let seconds = Int(timeDuration) % 60
         
         var timeStr = ""
         if hours > 0 {
             let minutes = Int((timeDuration - Double(3600 * hours)) / 60);
             timeStr = "\(hours):\(minutes):\(seconds)"
         } else {
             if (seconds < 10) {
                 timeStr = "\(minutes):0\(seconds)"
             } else {
                 timeStr = "\(minutes):\(seconds)"
             }
         }
         return timeStr
     }
}

extension VideoCallVC: LocalVideoViewDelegate {
    // MARK: LocalVideoViewDelegate
    func localVideoView(_ localVideoView: LocalVideoView, pressedSwitchButton sender: UIButton?) {
        guard let cameraCapture = self.videoCapture else {
            return
        }
        let newPosition: AVCaptureDevice.Position = cameraCapture.position == .back ? .front : .back
        guard cameraCapture.hasCamera(for: newPosition) == true else {
            return
        }
        let animation = CATransition()
        animation.duration = 0.75
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = CATransitionType(rawValue: "oglFlip")
        animation.subtype = cameraCapture.position == .back ? .fromLeft : .fromRight
        
        localVideoView.superview?.layer.add(animation, forKey: nil)
        cameraCapture.position = newPosition
    }
}

extension VideoCallVC: QBRTCAudioSessionDelegate {
    //MARK: QBRTCAudioSessionDelegate
    func audioSession(_ audioSession: QBRTCAudioSession, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        let isSpeaker = updatedAudioDevice == .speaker
        dynamicButton.pressed = isSpeaker
    }
}

// MARK: QBRTCClientDelegate
extension VideoCallVC: QBRTCClientDelegate {
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        guard session == self.session else {
            return
        }
        if session.opponentsIDs.count == 1, session.initiatorID == userID {
            closeCall()
        }
    }
    
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        guard let session = session as? QBRTCSession,
            session == self.session,
            let user = users.filter({ $0.userID == userID.uintValue }).first else {
                return
        }
        
        if user.connectionState == .connected,
            report.videoReceivedBitrateTracker.bitrate > 0.0 {
            user.bitrate = report.videoReceivedBitrateTracker.bitrate
            
            let userIndexPath = self.userIndexPath(userID: user.userID)
            
        }

        guard let selectedUserID = statsUserID,
            selectedUserID == userID.uintValue,
            shouldGetStats == true else {
                return
        }
        let result = report.statsString()
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        if session != self.session {
            return
        }

        guard let index = users.firstIndex(where: { $0.userID == userID.uintValue }) else {
            return
        }
        let user = users[index]
        if user.connectionState == .connected {
            return
        }
        
        user.bitrate = 0.0
        
        if let videoView = videoViews[userID.uintValue] as? QBRTCRemoteVideoView {
            videoView.removeFromSuperview()
            videoViews.removeValue(forKey: userID.uintValue)
            let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            videoViews[userID.uintValue] = remoteVideoView
        }
        reloadContent()
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        if session != self.session {
            return
        }
        
        if let index = users.firstIndex(where: { $0.userID == userID.uintValue }) {
            let user = users[index]
            user.connectionState = state
            let userIndexPath = self.userIndexPath(userID:userID.uintValue)
           
               // self.connectionState = user.connectionState
        } else {
            let user = createConferenceUser(userID: userID.uintValue)
            user.connectionState = state
            
            if user.connectionState == .connected {
                self.users.insert(user, at: 0)
                reloadContent()
            }
        }
    }
    
    /**
     *  Called in case when receive remote video track from opponent
     */
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        if session != self.session {
            return
        }
        self.previewView.isHidden = true
        self.opponentView.setVideoTrack(videoTrack)
       
        reloadContent()
        self.reloadAcceptCall()
    }
    
    /**
     *  Called in case when connection is established with opponent
     */
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        if session != self.session {
            return
        }

        if let beepTimer = beepTimer {
            beepTimer.invalidate()
            self.beepTimer = nil
            SoundProvider.stopSound()
        }
        
        if callTimer == nil {
            let profile = Profile()
            if profile.isFull == true,
                self.session?.initiatorID.uintValue == profile.ID {
                CallKitManager.instance.updateCall(with: callUUID, connectedAt: Date())
            }
            
            callTimer = Timer.scheduledTimer(timeInterval: CallConstant.refreshTimeInterval,
                                             target: self,
                                             selector: #selector(refreshCallTime(_:)),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            closeCall()
        }
    }
}
