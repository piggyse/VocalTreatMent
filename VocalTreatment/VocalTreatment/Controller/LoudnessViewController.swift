//
//  PhonationRangeViewController.swift
//  VocalTreatment
//
//  Created by 박진섭 on 2022/07/11.
//

import UIKit
import SnapKit
import AVFoundation
import CoreAudio

// db / default

final class LoudnessViewController: UIViewController {
    
    private var defaultdB: Float = 0
    
    private var isPlay: Bool = false
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16.0
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private lazy var startButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "play.fill")
        config.imagePlacement = .trailing
        config.baseForegroundColor = .systemRed
        
        let button = UIButton()
        button.configuration = config
        return button
    }()
    
    private lazy var replayButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "다시 듣기"
        config.imagePlacement = .trailing
        config.image = UIImage(systemName: "arrow.clockwise.circle")
        config.baseForegroundColor = .secondaryLabel
        
        let button = UIButton()
        button.configuration = config
        button.isEnabled = false
        return button
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var dBLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "0 dB"
        return label
    }()
    
    private lazy var dBAnimationView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var regulatorSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.maximumValue = defaultdB + 50
        slider.minimumValue = defaultdB - 50
        slider.addTarget(self, action: #selector(changeDefaultdB), for: .valueChanged)
        return slider
    }()
    
    private lazy var regualaorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "민감도"
        label.font = .boldSystemFont(ofSize: 16.0)
        return label
    }()
    
    private lazy var recorder: AVAudioRecorder = .init()
    private lazy var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        configUI()
        initRecord()
        setDefaultdB()
        addButtonAction()
    }
    
    // Button Tap시 액션 정의
    private func addButtonAction() {
        let action = UIAction.init { [weak self] _ in
            guard let self = self else { return }
            if self.isPlay {
                self.isPlay = false
                self.startButton.configuration?.image = UIImage(systemName: "play.fill")
                self.startButton.configuration?.baseForegroundColor = .systemRed
                
                self.replayButton.configuration?.baseForegroundColor = .label
                self.replayButton.isEnabled = true
            } else {
                self.isPlay = true
                self.startButton.configuration?.image = UIImage(systemName: "stop.fill")
                self.startButton.configuration?.baseForegroundColor = .systemBlue
                
                self.replayButton.configuration?.baseForegroundColor = .secondaryLabel
                self.replayButton.isEnabled = false
            }
        }
        self.startButton.addAction(action, for: .touchUpInside)
    }
    
    // Record 초기 설정
    private func initRecord() {
        switch AVAudioSession.sharedInstance().recordPermission {
            // 앱을 최초에 실행한 상태 (애매할 때)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] isGranted in
                if isGranted {
                    DispatchQueue.main.sync {
                        self?.record()
                    }
                } else {
                    self?.denyRecording()
                }
            }
            // 권한이 거부 됐을때
        case .denied:
            denyRecording()
            // 권한이 허가됬을때
        case .granted:
            record()
        @unknown default:
            denyRecording()
        }
    }
    
    // 권한이 거부 되었을 때
    private func denyRecording() {
        dBLabel.text = "권한을 설정해주세요."
    }
    
    // record 시작
    private func record() {
        let audioSession = AVAudioSession.sharedInstance()
        
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            16000, // 44100.0(표준), 32kHz, 24, 16, 12
            AVNumberOfChannelsKey:      1, // 1: 모노 2: 스테레오(표준)
            AVEncoderBitRateKey:        9600, // 32k, 96, 128(표준), 160, 192, 256, 320
            AVLinearPCMBitDepthKey:     8, // 4, 8, 11, 12, 16(표준), 18,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        
        do {
            try audioSession.setCategory(.playAndRecord)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(levelTimerCallback),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    
    
    // 현재 dB Display
    @objc private func levelTimerCallback() {
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        dBLabel.text = String(format: "%.0f dBFS",  level)
        startViewAnimation(dB: level)
    }
    
    // 측정 기준 dB 변경 Slider
    @objc private func changeDefaultdB() {
        self.defaultdB = self.regulatorSlider.value
    }
    
    // 측정 기준 dB 최초 설정
    private func setDefaultdB() {
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        self.defaultdB = level
    }
    
    // Animation 시작
    private func startViewAnimation(dB: Float) {
        let ratio = CGFloat(dB / defaultdB)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0) {
                let scale = CGAffineTransform(scaleX: ratio, y: ratio)
                self.dBAnimationView.transform = scale
            }
        }
    }
    
    private func configUI() {
        addViews()
        setLayouts()
    }
    
    private func addViews() {
        [startButton, replayButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        [dBLabel, dBAnimationView, regulatorSlider, regualaorTitleLabel, buttonStackView].forEach {
            self.view.addSubview($0)
        }
    }
    
    private func setLayouts() {
        let screenSize = UIScreen.main.bounds.size
        dBAnimationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(100)
        }
        
        dBLabel.snp.makeConstraints {
            $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
        }
        
        regulatorSlider.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(64.0)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(screenSize.width / 3)
        }
        
        regualaorTitleLabel.snp.makeConstraints {
            $0.trailing.equalTo(regulatorSlider.snp.leading).offset(-16.0)
            $0.centerY.equalTo(regulatorSlider.snp.centerY)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(regulatorSlider.snp.top)
            $0.centerX.equalTo(regulatorSlider.snp.centerX)
        }
    }
}
