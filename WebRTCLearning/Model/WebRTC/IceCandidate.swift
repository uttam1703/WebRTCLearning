//
//  IceCandidate.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 21/10/24.
//

import Foundation
import WebRTC

struct IceCandidate: Codable {
    var sdp: String
    var sdpMLineIndex: Int32
    var sdpMid: String?
    
    init(from iceCandidate: RTCIceCandidate) {
        self.sdp = iceCandidate.sdp
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdpMid = iceCandidate.sdpMid
    }
    
    var rtcIceCandidate: RTCIceCandidate {
        RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }
}
