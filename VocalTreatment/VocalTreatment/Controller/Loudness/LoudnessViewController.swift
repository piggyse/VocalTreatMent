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
    
    private var correction: Float = 72
    
    private let buttonStackView = ButtonStackView()
    
    private lazy var timerLabel = UILabel()
    
    private lazy var averageDBStackView: DBView = {
        let stackView = DBView()
        stackView.titleLabel.text = "평균"
        return stackView
    }()
    
    private lazy var peakDBStackView: DBView = {
        let stackView = DBView()
        stackView.titleLabel.text = "최고"
        return stackView
    }()
    
//    private lazy var averageDBLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 24, weight: .bold)
//        label.textColor = .label
//        return label
//    }()
//
//    private lazy var peakDBLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 24, weight: .bold)
//        label.textColor = .label
//        return label
//    }()
    
    private lazy var dBAnimationView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var regulatorSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(changeDefaultDB), for: .valueChanged)
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
        averageDBStackView.titleLabel.text = "권한을 설정해주세요."
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
        // Creates an audio file and prepares the system for recording.
        recorder.prepareToRecord()
        
        // A Boolean value that indicates whether you’ve enabled the recorder to generate audio-level metering data.
        recorder.isMeteringEnabled = true
        
        // Start record
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
        
        let reverage = recorder.averagePower(forChannel: 0) + correction
        let peak = recorder.peakPower(forChannel: 0) + correction
        
        averageDBStackView.setDBValue(reverage)
        peakDBStackView.setDBValue(peak)

//        startViewAnimation(dB: reverage)
    }
    
    
    private func setSlider() {
        self.regulatorSlider.value = self.correction
    }
    
    // 측정 기준 dB 변경 Slider
    @objc private func changeDefaultDB() {
//        self.baseDB = self.regulatorSlider.value
    }
    
    // 측정 기준 dB 최초 설정
    private func setDefaultDB() {
//        recorder.updateMeters()
//        let level = recorder.averagePower(forChannel: 0)
    }
    
    // Animation 시작
    private func startViewAnimation(dB: Float) {
//        let ratio = CGFloat(baseDB / dB)
//
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 1.0) {
//                let scale = CGAffineTransform(scaleX: ratio, y: ratio)
//                self.dBAnimationView.transform = scale
//            }
//        }
    }
    
    private func configUI() {
        addViews()
        setLayouts()
    }
    
    private func addViews() {
        
        [averageDBStackView, peakDBStackView, dBAnimationView, regulatorSlider, regualaorTitleLabel, buttonStackView].forEach {
            self.view.addSubview($0)
        }
    }
    
    private func setLayouts() {
        let screenSize = UIScreen.main.bounds.size
        dBAnimationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.greaterThanOrEqualTo(100)
        }
        
        averageDBStackView.snp.makeConstraints {
            $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.width.equalTo(100)
        }
        
        peakDBStackView.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.top.equalTo(averageDBStackView.snp.bottom).offset(16.0)
            $0.width.equalTo(100)
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
