//
//  SignalingMessage.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 27/04/25.
//

import Foundation

enum SignalingMessageType: String, Codable {
    case offer
    case answer
    case iceCandidate
}

struct SignalingMessage: Codable {
    let type: SignalingMessageType
    let sdp: String?
    let candidate: String?
    let sdpMLineIndex: Int?
    let sdpMid: String?
}
