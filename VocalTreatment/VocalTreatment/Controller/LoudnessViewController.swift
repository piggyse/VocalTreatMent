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

final class LoudnessViewController: UIViewController {
    
    private var defaultdB: Float = 0
    
    private lazy var dBLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "0 dB"
        return label
    }()
    
    private let dBAnimationView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var recorder: AVAudioRecorder = .init()
    private lazy var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        configUI()
        initRecord()
        setDefaultdB()
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
    
    private func denyRecording() {
        dBLabel.text = "권한을 설정해주세요."
    }
    
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
    
    @objc private func levelTimerCallback() {
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        dBLabel.text = String(format: "%.0f dBFS",  level)
        startViewAnimation(dB: level)
    }
    
    private func setDefaultdB() {
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        self.defaultdB = level
    }
    
    private func startViewAnimation(dB: Float) {
        let ratio = CGFloat(defaultdB / dB)
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
        [dBLabel, dBAnimationView].forEach {
            self.view.addSubview($0)
        }
    }
    
    private func setLayouts() {
        dBAnimationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(100)
        }
        
        dBLabel.snp.makeConstraints {
            $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
        }
    }
}
