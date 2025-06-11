//
//  CallViewController.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 27/04/25.
//

import UIKit

class CallViewController: UIViewController {
    
    static let buttonHeight: CGFloat = 60
    private var isCameraEnabled = true
    private var isMicEnabled = false
    private var isSpeakerEnabled = false
   
    
    var videoClient: WebRTCClient
    init(videoClient: WebRTCClient) {
        self.videoClient = videoClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    private let localVideoView: WLVideoView  = {
        let view = WLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemRed
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let remoteVideoView: WLVideoView  = {
        let view = WLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.text = WLStatusType.connected.rawValue
        return label
    }()
    private let endCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "phone.down.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = (buttonHeight / 2)
        return button
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "video"), for: .normal)//video.slash
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = buttonHeight / 2
        return button
    }()
    
    private let microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "mic"), for: .normal)//mic.slash
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = buttonHeight / 2
        return button
    }()
    
    private let speakerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)//speaker.slash
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = buttonHeight / 2
        return button
    }()
    
//    private 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        videoClient.delegate = self
        videoClient.startCaptureLoaclVideo(render: localVideoView)
        videoClient.renderRemoteVideo(to: remoteVideoView)
        enableCamera(isCameraEnabled)
        enableSpeaker(isSpeakerEnabled)
        enableMicophone(isMicEnabled)
       
    }
    
   

    
    @objc private func didTapEndCall(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapCameraButton(_ sender: UIButton) {
        isCameraEnabled.toggle()
        enableCamera(isCameraEnabled)
       
    }
    
    @objc private func didTapMicrophone(_ sender: UIButton) {
        isMicEnabled.toggle()
        enableMicophone(isMicEnabled)
        
    }
    
    @objc private func didTapSpeaker(_ sender: UIButton) {
        isSpeakerEnabled.toggle()
        enableSpeaker(isSpeakerEnabled)
        
    }
    
    private func enableCamera(_ isEnabled: Bool) {
        let imageName = isEnabled ? "video" : "video.slash"
        cameraButton.setImage(UIImage(systemName: imageName), for: .normal)
        videoClient.setVideoEnabled(isEnabled)
    }
    
    private func enableMicophone(_ isEnabled: Bool) {
        let imageName = isEnabled ? "mic" : "mic.slash"
        microphoneButton.setImage(UIImage(systemName: imageName), for: .normal)
        videoClient.isAudioEnable(isEnabled)
    }
    
    private func enableSpeaker(_ isEnabled: Bool) {
        let imageName = isEnabled ? "speaker.wave.2" : "speaker.slash"
        speakerButton.setImage(UIImage(systemName: imageName), for: .normal)
        videoClient.isSpeakerEnable(isEnabled)
    }
    
    
    
    
    private func setupUI() {
        
        //remote view
       
        view.addSubview(remoteVideoView)
        
        NSLayoutConstraint.activate([
            // Remote Video View Constraints
            remoteVideoView.topAnchor.constraint(equalTo: view.topAnchor),
            remoteVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            remoteVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            remoteVideoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        endCallButton.addTarget(self, action: #selector(didTapEndCall(_:)), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(didTapCameraButton(_:)), for: .touchUpInside)
        microphoneButton.addTarget(self, action: #selector(didTapMicrophone(_:)), for: .touchUpInside)
        speakerButton.addTarget(self, action: #selector(didTapSpeaker(_:)), for: .touchUpInside)
        
        let guide = view.safeAreaLayoutGuide
        let buttonsHStack: UIStackView = UIStackView(arrangedSubviews: [endCallButton, microphoneButton, cameraButton, speakerButton])
        buttonsHStack.axis = .horizontal
        buttonsHStack.distribution = .equalSpacing
        buttonsHStack.alignment = .center
        buttonsHStack.spacing = 12
        buttonsHStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonsHStack)
        NSLayoutConstraint.activate([
            buttonsHStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            buttonsHStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            buttonsHStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -24)
        ])
        
        let buttonHeight: CGFloat = CallViewController.buttonHeight
        NSLayoutConstraint.activate([
            endCallButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            endCallButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            microphoneButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            microphoneButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            cameraButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            cameraButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            speakerButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            speakerButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
        
        view.addSubview(localVideoView)
        NSLayoutConstraint.activate([
            // Local Video View Constraints
            localVideoView.widthAnchor.constraint(equalToConstant: 120),
            localVideoView.heightAnchor.constraint(equalToConstant: 160),
            localVideoView.bottomAnchor.constraint(equalTo: buttonsHStack.topAnchor, constant: -20),
            localVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
     
        
    }

}

extension CallViewController: WebRTCClientDelegate {
    func didDiscoverLocalCandidate(_ message: Message) {
        return
    }
    
    func didChangeConnectionState(_ state: WLStatusType) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            self.headerLabel.text = state.rawValue
            if state == .disconnected {
                self.navigationController?.popViewController(animated: true)
            }
        }

    }
    
        
    
}
