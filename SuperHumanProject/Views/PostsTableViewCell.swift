//
//  PostsTableViewCell.swift
//  SuperHumanProject
//
//  Created by Vaibhav on 10/09/24.
//

import UIKit

class PostsTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    
    private let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "location")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let interactionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let likeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ShareLabel: UILabel = {
        let label = UILabel()
        label.text = "Share"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(locationIcon)
        contentView.addSubview(locationLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(postImage)
        contentView.addSubview(interactionStackView)
        interactionStackView.addArrangedSubview(likeLabel)
        interactionStackView.addArrangedSubview(commentLabel)
        interactionStackView.addArrangedSubview(ShareLabel)
        
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1.0
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            locationIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            locationIcon.widthAnchor.constraint(equalToConstant: 40),
            locationIcon.heightAnchor.constraint(equalToConstant: 40),
            
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 5),
            locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            dateLabel.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            postImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImage.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            postImage.heightAnchor.constraint(equalToConstant: 250),
            
            interactionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interactionStackView.topAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 10),
            interactionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            interactionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with data: [String: Any]) {
        locationLabel.text = data["cityName"] as? String ?? "Unknown Location"
        dateLabel.text = data["feedDate"] as? String ?? "Unknown Date"
        descriptionLabel.text = data["description"] as? String ?? "No description available"
        
        if let imageUrlString = data["story_img"] as? String,
           let imageUrl = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.postImage.image = image
                    }
                }
            }.resume()
        }
        
        likeLabel.text = "Like(\(data["totalLikes"] as? Int ?? 0))"
        commentLabel.text = "Comments(\(data["totalComments"] as? Int ?? 0))"
    }
}
