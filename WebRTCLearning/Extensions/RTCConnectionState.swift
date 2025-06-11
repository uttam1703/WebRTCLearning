//
//  RTCConnectionState.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 21/10/24.
//

import Foundation
import WebRTC

extension RTCIceConnectionState {
    var statusType: WLStatusType {
        switch self {
        case .new,
                .count,
                .checking:
            return .connecting

        case .connected,
                .completed:
            return .connected

        case .failed,
                .disconnected,
                .closed:
            return .disconnected

        default:
            return .connecting
        }
    }
}

extension RTCSignalingState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .stable:
            return "stable"
        case .haveLocalOffer:
            return "haveLocalOffer"
        case .haveRemoteOffer:
            return "haveRemoteOffer"
        case .haveLocalPrAnswer:
            return "haveLocalPrAnswer"
        case .haveRemotePrAnswer:
            return "haveRemotePrAnswer"
        case .closed:
            return "closed"
        @unknown default:
            return "Unknown \(self.rawValue)"
        }
    }
}

extension RTCIceGatheringState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .new:
            return "new"
        case .gathering:
            return "gathering"
        case .complete:
            return "complete"
        @unknown default:
            return "Unknown \(self.rawValue)"
        }
    }
}

extension RTCDataChannelState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .connecting:
            return "connecting"
        case .open:
            return "open"
        case .closing:
            return "closing"
        case .closed:
            return "closed"
        @unknown default:
            return "Unknown \(self.rawValue)"
        }
    }
}
