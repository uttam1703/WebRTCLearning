//
//  NativeWebSocket.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 21/10/24.
//

import Foundation

class NativeWebSocket: NSObject, WebSocketProvider {
    
    weak var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    
    private lazy var urlSession: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    func connect() {
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        readMessage()
    }
    
    func send(_ data: Data) {
        guard let socket else { return }
        socket.send(.data(data)) { error in
            guard let error else { return }
            print("Socke Error: send error - \(error.localizedDescription)")
            
        }
    }
    
    private func readMessage() {
        guard let socket else { return }
        socket.receive {[weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(.data(let data)):
                self.delegate?.didSocketReceiveData(data)
                self.readMessage()
            case .success:
                print("Socket Error: readMessage error")
                self.readMessage()
            case .failure(let error):
                print("Socket Error: failure - \(error.localizedDescription)")
                self.disconnect()
            }
        }
    }
    
    private func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.delegate?.didSocketStatus(chnage: .disconnected)
    }
}

extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.didSocketStatus(chnage: .connected)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.delegate?.didSocketStatus(chnage: .disconnected)
    }
}
