//
//  VideoCallVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import AVFoundation


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
    var session = AVCaptureSession()
    
    var videoPause : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAVCapture()
        self.setUpView()
    }
    
    func setUpView()  {
        self.constarintLayoutHeightTextView.constant = 0
        self.constarintLayoutHeightButtonsView.constant = 44
        self.labelVideoPause.isHidden = true
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
        
        if let session : AVCaptureSession = session {
            //Remove existing input
            
            guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
                return
            }

            //Indicate that some changes will be made to the session
            session.beginConfiguration()
            session.removeInput(currentCameraInput)

            //Get new input
            var newCamera: AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if (input.device.position == .back) {
                    newCamera = cameraWithPosition(position: .front)
                } else {
                    newCamera = cameraWithPosition(position: .back)
                }
            }

            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let err1 as NSError {
                err = err1
                newVideoInput = nil
            }

            if newVideoInput == nil || err != nil {
                print("Error creating capture device input: \(err?.localizedDescription)")
            } else {
                session.addInput(newVideoInput)
            }

            //Commit all the configuration changes at once
            self.session.commitConfiguration()
        }
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


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension VideoCallVC:  AVCaptureVideoDataOutputSampleBufferDelegate{
     func setupAVCapture(){
        session.sessionPreset = AVCaptureSession.Preset.high
        guard let device = AVCaptureDevice
        .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                 for: .video,
                 position: AVCaptureDevice.Position.front) else {
                            return
        }
        captureDevice = device
        beginSession()
    }

    func beginSession(){
        var deviceInput: AVCaptureDeviceInput!

        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cant get deviceInput")
                return
            }

            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }

            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames=true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)

            if session.canAddOutput(self.videoDataOutput){
                session.addOutput(self.videoDataOutput)
            }

            videoDataOutput.connection(with: .video)?.isEnabled = true

            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect

            let rootLayer :CALayer = self.previewView.layer
            rootLayer.masksToBounds=true
            previewLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(self.previewLayer)
            session.startRunning()
        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
    }

    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
    }

}
