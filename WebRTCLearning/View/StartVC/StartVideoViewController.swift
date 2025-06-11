//
//  StartVideoViewController.swift
//  WebRTCLearning
//
//  Created by uttamkumar bala on 26/04/25.
//

import UIKit

class StartVideoViewController: UIViewController {

    let vm: StartCallViewModel
    
    init(vm: StartCallViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let createCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create Call", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "video.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()
    
    private let joinCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Join Call", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "plus.app"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()
    
    private let startVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start Video", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "video.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()
    
    private let signalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Network - Connecting 🟠"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.text = "WebRTC Demo"
        return label
    }()
    
    private let localConnectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.text = "Local Connection - Start"
        return label
    }()
    
    private let remoteConnectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.text = "Remote Connection - Start"
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        vm.delegate = self
        vm.startConnection()
        
    }
    
    @objc private func didTapCreateCall(_ sender: UIButton) {
        vm.sendLocalSDP(callType: .offer)
    }
    
    @objc private func didTapJoinCall(_ sender: UIButton) {
        vm.sendLocalSDP(callType: .answer)
    }
    
    @objc private func didTapStartCall(_ sender: UIButton) {
        let vc = MainVCBuilder.buildCallVC(webRTCClient: vm.webRTCClient)
        vc.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(vc, animated: true)
    }

    
    private func setupViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 40),
            headerLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
        ])
        
        
        let mainVStack = UIStackView(arrangedSubviews: [signalLabel,localConnectionLabel, remoteConnectionLabel, createCallButton, joinCallButton, startVideoButton])
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        mainVStack.axis = .vertical
        mainVStack.spacing = 12
        mainVStack.alignment = .fill
        
        NSLayoutConstraint.activate([
            signalLabel.heightAnchor.constraint(equalToConstant: 48),
            localConnectionLabel.heightAnchor.constraint(equalToConstant: 48),
            remoteConnectionLabel.heightAnchor.constraint(equalToConstant: 48),
            joinCallButton.heightAnchor.constraint(equalToConstant: 48),
            createCallButton.heightAnchor.constraint(equalToConstant: 48),
            startVideoButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        view.addSubview(mainVStack)
        NSLayoutConstraint.activate([
            mainVStack.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            mainVStack.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            mainVStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 40),
            mainVStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -40)
        ])
        
        createCallButton.addTarget(self, action: #selector(didTapCreateCall(_:)), for: .touchUpInside)
        joinCallButton.addTarget(self, action: #selector(didTapJoinCall(_:)), for: .touchUpInside)
        startVideoButton.addTarget(self, action: #selector(didTapStartCall(_:)), for: .touchUpInside)
        
        //Start Setup
//        createCallButton.isHidden = false
//        joinCallButton.isHidden = true
        updateButtonUI()
        
        
    }
    
    private func updateButtonUI() {
        createCallButton.isHidden = vm.remoteStatus == .connected || vm.localStatus == .connected
        joinCallButton.isHidden = vm.remoteStatus != .connected || vm.localStatus == .connected
        startVideoButton.isHidden = vm.localStatus != .connected || vm.remoteStatus != .connected || vm.networkStatus != .connected
    }
    

}

extension StartVideoViewController: StartCallViewModelDelegate {
    func socketStatus(change status: WLStatusType) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            signalLabel.text = "Network - \(status.rawValue)"
            updateButtonUI()
        }
    }
    
    func localConnectionStatus(change status: WLStatusType) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            localConnectionLabel.text = "Local - \(status.rawValue)"
            updateButtonUI()
        }
    }
    
    func remoteConnectionStatus(change status: WLStatusType) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            remoteConnectionLabel.text = "Remote - \(status.rawValue)"
            updateButtonUI()
        }
    }
    
    
}


