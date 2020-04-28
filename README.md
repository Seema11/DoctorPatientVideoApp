# Overview
The VideoChat code sample allows you to easily add video calling and audio calling features into your iOS app. Enable a video call function similar to FaceTime or Skype using this code sample as a basis.

It is based on WebRTC technology.

This code sample is written in *Swift* lang.
The same is also available in [Objective-C](https://github.com/QuickBlox/quickblox-ios-sdk/blob/master/sample-videochat-webrtc) lang.

# Credentials

Welcome to QuickBlox [Credentials](https://quickblox.com/developers/5_Minute_Guide), where you can get your credentials in just 5 minutes! All you need is to:

1. Register a free QuickBlox account and add your App there.
2. Update credentials in your [Application Code](https://quickblox.com/developers/5_Minute_Guide#Update_authentication_credentials).

# Main features
* 1-1 video calling
* Group video calling
* Screen sharing
* Mute/Unmute audio/video streams
* Display bitrate
* Switch video input device (camera) 
* [CallKit](https://developer.apple.com/documentation/callkit) supported
* WebRTC Stats reports
* H264,VP8,H264High video codecs supported
* Lots of different settings related to call quality 

Original sample description & setup guide - [Sample-webrtc-ios](https://quickblox.com/developers/Sample-webrtc-ios)

# CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1+ is required to build project with QuickBlox 2.17+ and Quickblox-WebRTC 2.7.3+.

To integrate QuickBlox and Quickblox-WebRTC into the **sample-videochat-webrtc-swift** run the following command:

```bash
$ pod install
```
Additional libraries used via [CocoaPods](https://cocoapods.org):

* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD.git/)
