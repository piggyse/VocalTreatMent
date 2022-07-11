//
//  ViewController.swift
//  VocalTreatment
//
//  Created by 박진섭 on 2022/07/04.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private let loudnessButton: UIButton = {
        let button = UIButton()
        button.setTitle("목소리 크기 조절", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    private let phonationTimeButton: UIButton = {
        let button = UIButton()
        button.setTitle("연장 발성", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    private let wordMemorizationButton: UIButton = {
        let button = UIButton()
        button.setTitle("단어 기억하기", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        configUI()
    }

    private func configUI() {
        addViews()
        setLayouts()
        setAction()
    }
    
    private func addViews() {
        [loudnessButton, phonationTimeButton, wordMemorizationButton].forEach {
            self.stackView.addArrangedSubview($0)
        }
        
        self.view.addSubview(stackView)
    }
    
    private func setLayouts() {
        let screenSize = UIScreen.main.bounds.size
        
        stackView.snp.makeConstraints {
            $0.width.equalTo(screenSize.width * 0.8)
            $0.height.equalTo(screenSize.height * 0.5)
            $0.center.equalToSuperview()
        }
    }
    
    func setAction() {
        loudnessButton.addAction(UIAction { [weak self]_  in
            self?.navigationController?.pushViewController(LoudnessViewController(),
                                                          animated: true)},
                                                          for: .touchUpInside)
            
        phonationTimeButton.addAction(UIAction { [weak self]_  in
            self?.navigationController?.pushViewController(PhonationTimeViewController(),
                                                          animated: true)},
                                                          for: .touchUpInside)
        wordMemorizationButton.addAction(UIAction { [weak self]_  in
            self?.navigationController?.pushViewController(WordMemorizationViewController(),
                                                          animated: true)},
                                                          for: .touchUpInside)
    }
    
}

