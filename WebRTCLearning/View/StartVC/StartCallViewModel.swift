//
//  StartCallViewModel.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 29/04/25.
//

import Foundation

protocol StartCallViewModelDelegate: AnyObject {
    func socketStatus(change status: WLStatusType)
    func localConnectionStatus(change status: WLStatusType)
    func remoteConnectionStatus(change status: WLStatusType)
}

final class StartCallViewModel {
    private let socketClient: WebSocketProvider
    let webRTCClient: WebRTCClient
    
    weak var delegate: StartCallViewModelDelegate?
    private var remoteCandidatesCount: Int = 0
    private var localCandidatesCount: Int = 0
    var networkStatus: WLStatusType = .connecting
    var localStatus: WLStatusType = .connecting
    var remoteStatus: WLStatusType = .connecting
    
    init(socketClient: WebSocketProvider, webRTCClient: WebRTCClient) {
        self.socketClient = socketClient
        self.webRTCClient = webRTCClient
    }
    
    func startConnection() {
        socketClient.delegate = self
        webRTCClient.delegate = self
        socketClient.connect()
    }
    
    // MARK: – Public API
    func sendLocalSDP(callType: CallType) {
        Task {[weak self] in
            guard let self else { return }
            do {
                let data: Data = try await webRTCClient.setLocalSDP(for: callType)
                delegate?.localConnectionStatus(change: .connected)
                localStatus = .connected
                socketClient.send(data)
            } catch {
                print("webRTC - \(#function) Error: \(error.localizedDescription)")
            }
        }
    }
    
    
}

// MARK: – Private Helpers
fileprivate extension StartCallViewModel {
    func sendSocketMessage(_ message: Message) {
        do {
            let data = try JSONEncoder().encode(message)
            self.socketClient.send(data)
        } catch {
            print("\(#function) - Encode Error: \(error.localizedDescription)")
        }
        
    }
    
    func handleSocketData(_ data: Data) {
        do {
            let message: Message = try JSONDecoder().decode(Message.self, from: data)
            handleMessage(message)
        } catch {
            print("\(#function) - Decode Error: \(error.localizedDescription)")
        }
    }
    
    func handleMessage(_ message: Message) {
        Task {[weak self] in
            guard let self else { return }
            do {
                switch message {
                case .candidate(let iceCadidate):
                    try await self.setRemoteCandidate(iceCadidate)
                case .sdp(let sdp):
                    try await self.setRemoteSdp(sdp)
                }
            } catch {
                print("\(#function) - Handle Message Error: \(error.localizedDescription)")
            }
        }
    }
    
    func setRemoteSdp(_ sdp: SessionDescription) async throws {
        print("Done connection - start")
        try await self.webRTCClient.set(remoteSdp: sdp)
        await remoteConnectionSuccess()
        
    }
    
    func setRemoteCandidate(_ candidate: IceCandidate) async throws {
        try await self.webRTCClient.set(remoteCandidate: candidate)
    }
    
    @MainActor
    func remoteConnectionSuccess() {
        delegate?.remoteConnectionStatus(change: .connected)
        remoteStatus = .connected
        print("Done connection - success")
        
    }
}

// MARK: – WebSocketProviderDelegate
extension StartCallViewModel: WebSocketProviderDelegate {
    func didSocketStatus(chnage status: WLStatusType) {
        delegate?.socketStatus(change: status)
        networkStatus = status
    }
    
    func didSocketReceiveData(_ data: Data) {
        handleSocketData(data)
    }
    
    
}

// MARK: – WebRTCClientDelegate
extension StartCallViewModel: WebRTCClientDelegate {
    func didChangeConnectionState(_ state: WLStatusType) {
        print("WebRTC state changed: \(state.rawValue)")
    }
    
    func didDiscoverLocalCandidate(_ message: Message) {
        self.localCandidatesCount += 1
        sendSocketMessage(message)
    }
        
    
}
