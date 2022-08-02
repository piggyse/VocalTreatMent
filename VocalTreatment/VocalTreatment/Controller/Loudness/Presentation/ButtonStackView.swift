//
//  ButtonStackView.swift
//  VocalTreatment
//
//  Created by 박진섭 on 2022/08/02.
//

import UIKit

final class ButtonStackView: UIStackView {
        
    private var isPlay: Bool = false
    
    private var startButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "play.fill")
        config.imagePlacement = .trailing
        config.baseForegroundColor = .systemRed
        
        let button = UIButton()
        button.configuration = config
        return button
    }()
    
    private var replayButton: UIButton = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.axis = .horizontal
        self.spacing = 16.0
        self.distribution = .equalCentering
        
        [startButton, replayButton].forEach {
            self.addArrangedSubview($0)
        }
        
        addButtonAction()
    }
    
    @available (*, unavailable) required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    
}
