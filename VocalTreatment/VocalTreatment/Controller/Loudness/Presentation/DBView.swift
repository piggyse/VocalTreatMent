//
//  DBStackView.swift
//  VocalTreatment
//
//  Created by 박진섭 on 2022/08/02.
//

import UIKit

final class DBView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var dBStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        stackView.distribution = .fillProportionally
        
        [titleLabel, dBLabel, dfsLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private var dBLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private var dfsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "DFS"
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
    }
    
    @available (*, unavailable) required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDBValue(_ dB: Float) {
        self.dBLabel.text = String(format: "%.0f", dB)
    }
    
    private func addSubviews() {
        [titleLabel, dBStackView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(dBStackView.snp.leading).offset(-8)
        }
        
        dBStackView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
    
}
