//
//  config.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 20/10/24.
//


import Foundation

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    static private let defaultIceServers = ["stun:stun.l.google.com:19302",
                                         "stun:stun1.l.google.com:19302",
                                         "stun:stun2.l.google.com:19302",
                                         "stun:stun3.l.google.com:19302",
                                         "stun:stun4.l.google.com:19302"]
    static private let defaultSignalingServerUrl = URL(string: "ws://192.168.80.171:8080")!
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
    
    
}


