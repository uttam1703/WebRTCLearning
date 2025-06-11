//
//  MainVCBuilder.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 22/10/24.
//

import Foundation


struct MainVCBuilder {
    
    
    static func buildCallVC(webRTCClient: WebRTCClient) -> CallViewController {
        let callVC = CallViewController(videoClient: webRTCClient)
        return callVC
    }
    
    static func buildMainVC() -> StartVideoViewController {
        let vm = buildStartCallVM()
        let vc = StartVideoViewController(vm: vm)
        return vc
    }
    
    
    static func buildStartCallVM() -> StartCallViewModel {
        let socketClient = buildSokcetClient()
        let webRTCClient = buildWebRTCClient()
        let vm = StartCallViewModel(socketClient: socketClient, webRTCClient: webRTCClient)
        return vm
    }
    
    static func buildSokcetClient() -> NativeWebSocket {
        let webSoketProvider = NativeWebSocket(url: Config.default.signalingServerUrl)
        return webSoketProvider
    }
    
    static func buildWebRTCClient() -> WebRTCClient {
        return WebRTCClient(iceServer: Config.default.webRTCIceServers)
    }
}
