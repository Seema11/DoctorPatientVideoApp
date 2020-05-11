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
import SVProgressHUD

enum CallViewControllerState : Int {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

struct CallStateConstant {
    static let disconnected = "Disconnected"
    static let connecting = "Connecting..."
    static let connected = "Connected"
    static let disconnecting = "Disconnecting..."
}

struct CallConstant {
    static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let unknownUserLabel = "Unknown user"
    static let sharingViewControllerIdentifier = "SharingViewController"
    static let refreshTimeInterval: TimeInterval = 1.0
    
    static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call. Please, reduce the quality of the video settings", comment: "")
    static let sessionDidClose = NSLocalizedString("Session did close due to time out", comment: "")
}
enum CameraType {
    case front
    case back
}
var camera = CameraType.back


class VideoCallVC: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var textViewEdit: UITextView!
    @IBOutlet weak var labelVideoPause: UILabel!
    @IBOutlet weak var constarintLayoutHeightTextView: NSLayoutConstraint!
    @IBOutlet weak var constarintLayoutHeightButtonsView: NSLayoutConstraint!
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
//    var session = AVCaptureSession()
    
    var videoPause : Bool = false
    
    //MARK: - Properties
    weak var usersDataSource: UsersDataSource?
    
    //MARK: - Internal Properties
    private var timeDuration: TimeInterval = 0.0
    
    private var callTimer: Timer?
    private var beepTimer: Timer?
    
    //Camera
    var session: QBRTCSession?
    var callUUID: UUID?
    private var cameraCapture: QBRTCCameraCapture?
    
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
    
    lazy private var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()
    
    private lazy var statsItem = UIBarButtonItem(title: "Stats",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(updateStatsView))
    
    
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
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.cancelCall(title: UsersAlertConstant.checkInternet)
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        
        if cameraCapture?.hasStarted == false {
            cameraCapture?.startSession(nil)
        }
        session?.localMediaStream.videoTrack.videoCapture = cameraCapture
        reloadContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        state = CallViewControllerState.disconnecting
        
        let ok : UIAlertAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            self.closeCall()
        }
        let cancel : UIAlertAction = UIAlertAction.init(title: "CACEL", style: .cancel, handler: nil)
        GeneralUtility.showAlert(withTitle: CallConstant.memoryWarning, message: "", actions: [ok,cancel], defaultButtonAction: nil)
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
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapButtonCamera(_ sender: Any) {
    }
    
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }

        return nil
    }
    
    @IBAction func didTapButtonVideoPause(_ sender: Any) {
        if (videoPause){
             self.labelVideoPause.isHidden = true
            videoPause = false
             self.previewLayer.connection?.isEnabled = true
        } else {
            self.labelVideoPause.isHidden = false
            videoPause = true
            self.previewLayer.connection?.isEnabled = false
        }
        
    }
    @IBAction func didTapButtonAudioMute(_ sender: Any) {
        
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
    
    func reloadContent() {
           videoViews.values.forEach{ $0.removeFromSuperview() }
       }
     func configureGUI() {
         // when conferenceType is nil, it means that user connected to the session as a listener
         if let conferenceType = session?.conferenceType {
             switch conferenceType {
             case .video: break
                
             case .audio:
                 if UIDevice.current.userInterfaceIdiom == .phone {
                     QBRTCAudioSession.instance().currentAudioDevice = .receiver
                     dynamicButton.pressed = false
                 }
             @unknown default:
                print("default")
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
         
         // stats view
         statsView.frame = view.bounds
         statsView.autoresizingMask = mask
         statsView.isHidden = true
         statsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateStatsState)))
         view.addSubview(statsView)
         
         // add button to enable stats view
         state = .connecting
     }
    // MARK: - Actions
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
          let userInfo = ["acceptCall": "userInfo"]
          session?.acceptCall(userInfo)
      }
      
      private func closeCall() {
          
          CallKitManager.instance.endCall(with: callUUID)
          cameraCapture?.stopSession(nil)
          
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
        QBRTCClient.instance().remove(self as! QBRTCClientDelegate)
          QBRTCAudioSession.instance().removeDelegate(self)
          
          title = "End - \(string(withTimeDuration: timeDuration))"
      }
    @objc func updateStatsView() {
           shouldGetStats = !shouldGetStats
           statsView.isHidden = !statsView.isHidden
       }
       
       @objc func updateStatsState() {
           updateStatsView()
       }
       
       //MARK: - Internal Methods
       private func zoomUser(userID: UInt) {
           statsUserID = userID
           reloadContent()
           navigationItem.rightBarButtonItem = statsItem
       }
       
       private func unzoomUser() {
           statsUserID = nil
           reloadContent()
           navigationItem.rightBarButtonItem = nil
       }
       
       private func userView(userID: UInt) -> UIView? {
           
           let profile = Profile()
           
           if profile.isFull == true, profile.ID == userID,
               session?.conferenceType != .audio {
               
               if cameraCapture?.hasStarted == false {
                   cameraCapture?.startSession(nil)
                   session?.localMediaStream.videoTrack.videoCapture = cameraCapture
               }
               //Local preview
               if let result = videoViews[userID] as? LocalVideoView {
                   return result
               } else if let previewLayer = cameraCapture?.previewLayer {
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
                   remoteVideoView.setVideoTrack(remoteVideoTraсk)
                   
                   return remoteVideoView
               }
           }
           return nil
       }

}
extension VideoCallVC: LocalVideoViewDelegate {
    // MARK: LocalVideoViewDelegate
    func localVideoView(_ localVideoView: LocalVideoView, pressedSwitchButton sender: UIButton?) {
        guard let cameraCapture = self.cameraCapture else {
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
        statsView.updateStats(result)
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        if session != self.session {
            return
        }
        // remove user from the collection
        if statsUserID == userID.uintValue {
            unzoomUser()
        }
        
        guard let index = users.index(where: { $0.userID == userID.uintValue }) else {
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
        
        if let index = users.index(where: { $0.userID == userID.uintValue }) {
            let user = users[index]
            user.connectionState = state
            let userIndexPath = self.userIndexPath(userID:userID.uintValue)
          
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
        reloadContent()
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
extension VideoCallVC {
    
    func cancelCall(title : String) {
        let ok : UIAlertAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
                  self.closeCall()
              }
              let cancel : UIAlertAction = UIAlertAction.init(title: "CACEL", style: .cancel, handler: nil)
              GeneralUtility.showAlert(withTitle: title, message: "", actions: [ok,cancel], defaultButtonAction: nil)
    }
    
}
extension VideoCallVC {
    // MARK: - Timers actions
     @objc func playCallingSound(_ sender: Any?) {
         SoundProvider.playSound(type: .calling)
     }
     
     @objc func refreshCallTime(_ sender: Timer?) {
         timeDuration += CallConstant.refreshTimeInterval
         title = "Call time - \(string(withTimeDuration: timeDuration))"
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
    private func userIndexPath(userID: UInt) -> IndexPath {
          guard let index = users.index(where: { $0.userID == userID }), index != NSNotFound else {
              return IndexPath(row: 0, section: 0)
          }
          return IndexPath(row: index, section: 0)
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
}
