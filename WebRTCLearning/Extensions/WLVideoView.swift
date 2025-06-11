//
//  WLVideoView.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 30/04/25.
//

import Foundation
import WebRTC

final class WLVideoView: RTCMTLVideoView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
