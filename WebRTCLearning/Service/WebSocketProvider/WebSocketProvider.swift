//
//  WebSocketProvider.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 21/10/24.
//

import Foundation


protocol WebSocketProvider: AnyObject {
    var delegate: WebSocketProviderDelegate? { get set }
    func connect()
    func send(_ data: Data)
}

protocol WebSocketProviderDelegate: AnyObject {
    func didSocketStatus(chnage status: WLStatusType)
    func didSocketReceiveData(_ data: Data)
}
