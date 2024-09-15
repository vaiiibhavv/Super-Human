//
//  CustomCollectionViewCell.swift
//  SuperHumanProject
//
//  Created by Vaibhav on 11/09/24.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cellValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cellLabel)
        contentView.addSubview(cellValueLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            cellValueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            
            cellLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            cellLabel.topAnchor.constraint(equalTo: cellValueLabel.bottomAnchor, constant: 10)
        ])
    }
    
}
