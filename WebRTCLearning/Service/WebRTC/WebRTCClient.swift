//
//  WebRTCClient.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 21/10/24.
//

import Foundation
import WebRTC
//import AVFoundation

protocol WebRTCClientDelegate: AnyObject {
    func didDiscoverLocalCandidate(_ message: Message)
    func didChangeConnectionState(_ state: WLStatusType)
}


final class WebRTCClient: NSObject {

    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    private var peerConnection: RTCPeerConnection
    private let audioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "com.app.WebRTCClient.audio")
    private let mediaConsrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                  kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var videoCapture: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    private var offerAnswerConstraints: RTCMediaConstraints {
        RTCMediaConstraints(mandatoryConstraints: self.mediaConsrains, optionalConstraints: nil)
    }
    private let peerConnectionConstraints: RTCMediaConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
    
    
    override init() {
        fatalError("init(): initializer cannot be used")
    }
    
    required init(iceServer: [String]) {
       
        let configuration = RTCConfiguration()
        configuration.iceServers = [RTCIceServer(urlStrings: iceServer)]
        configuration.sdpSemantics = .unifiedPlan
        configuration.continualGatheringPolicy = .gatherContinually
        guard let peerConnection = WebRTCClient.factory.peerConnection(with: configuration, constraints: peerConnectionConstraints, delegate: nil) else {
            assert(false, "Failed to create peer connection")
        }
        
        self.peerConnection = peerConnection
        
        super.init()
        self.createMediaSender()
        self.configureAudiosession()
        self.peerConnection.delegate = self
    }
    
    
    //MARK: signaling
    func setLocalSDP(for type: CallType) async throws -> Data {
        let sdp: RTCSessionDescription = try await {
            switch type {
            case .offer: return try await peerConnection.offer(for: offerAnswerConstraints)
            case .answer: return try await peerConnection.answer(for: offerAnswerConstraints)
            }
        }()
        try await peerConnection.setLocalDescription(sdp)
        let message = Message.sdp(SessionDescription(from: sdp))
        return try JSONEncoder().encode(message)
    }
    
    
    func set(remoteSdp: SessionDescription) async throws {
        try await peerConnection.setRemoteDescription(remoteSdp.rtcSessionDescription)
    }
    
    func set(remoteCandidate: IceCandidate) async throws {
        try await peerConnection.add(remoteCandidate.rtcIceCandidate)
    }
    
    //MARK: Media
    func startCaptureLoaclVideo(render: RTCVideoRenderer) {
        guard let capture = self.videoCapture as? RTCCameraVideoCapturer else {
            return
        }
        guard let fontCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == .front }),
              let format = RTCCameraVideoCapturer.supportedFormats(for: fontCamera).sorted(by: {(f1, f2) -> Bool in
                  let w1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                  let w2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                  return w1 < w2
              }).last,
              let fps = format.videoSupportedFrameRateRanges.sorted(by: {$0.maxFrameRate < $1.maxFrameRate}).last  else {
            return
        }
        
        capture.startCapture(with: fontCamera, format: format, fps: Int(fps.maxFrameRate))
        self.localVideoTrack?.add(render)
              
    }
    
    func renderRemoteVideo(to render: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(render)
    }
    
    func sendData(_ data: Data) {
        print("Data send: ")
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
        
        
    }
}

fileprivate extension WebRTCClient {
    
    //media
    private func configureAudiosession() {
        self.audioSession.lockForConfiguration()
        do {
            try self.audioSession.setCategory(.playAndRecord)
            try self.audioSession.setMode(.voiceChat)
        } catch {
            print("Error: configureAudiosession failed")
        }
        self.audioSession.unlockForConfiguration()
    }
    
    private func createMediaSender() {
        let streamId = "stream"
        
        //audio
        let audioTrack = createAudioTrack()
        self.peerConnection.add(audioTrack, streamIds: [streamId])

        
        //video
        let videoTrack = createVideoTrack()
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers.first {
            $0.mediaType == .video
        }?.receiver.track as? RTCVideoTrack
        
        //data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
        
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConsrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConsrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
        
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        self.videoCapture = RTCCameraVideoCapturer(delegate: videoSource)
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            print("Error: could not create data channel")
            return nil
        }
        return dataChannel
    }
    
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("stateChanged : \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("remove stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("connection state change: \(newState)")
        self.delegate?.didChangeConnectionState(newState.statusType)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("gathering state change: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("generate cadinate")
        let message = Message.candidate(IceCandidate(from: candidate))
        delegate?.didDiscoverLocalCandidate(message)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("remove cadinate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("open data channnel")
        self.remoteDataChannel = dataChannel
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Negotitate with remote peer")
    }
    
    
}

// MARK: - Audio/video Control

extension WebRTCClient {
    
    
    func setVideoEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCVideoTrack.self, isEnabled: isEnabled)
    }
    
    func isAudioEnable(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
    
    func isSpeakerEnable(_ enable: Bool) {
        if enable {
            speakerOn()
        } else {
            speakerOff()
        }
    }
    
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.audioSession.lockForConfiguration()
            do {
                try self.audioSession.setCategory(AVAudioSession.Category.playAndRecord)
                try self.audioSession.overrideOutputAudioPort(.none)
            } catch let error {
                print("Error setting AVAudioSession category: \(error)")
            }
            self.audioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.audioSession.lockForConfiguration()
            do {
                try self.audioSession.setCategory(AVAudioSession.Category.playAndRecord)
                try self.audioSession.overrideOutputAudioPort(.speaker)
                try self.audioSession.setActive(true)
            } catch let error {
                print("Couldn't force audio to speaker: \(error)")
            }
            self.audioSession.unlockForConfiguration()
        }
    }
    
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
    
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        print("data channel state changed: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        print("Data received: \(String(decoding: buffer.data, as: UTF8.self))")
//        self.delegate?.didReceiveData(buffer.data)
    }
 
}

