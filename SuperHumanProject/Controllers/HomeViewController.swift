//
//  ViewController.swift
//  SuperHumanProject
//
//  Created by Vaibhav on 10/09/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var posts: [[String: Any]] = []
    private var lastId: Int = 0
    private var isLoading = false
    
    let labelsData = [
        ("15", "Goodwill score"),
        ("0 Hours", "Volunteering"),
        ("14", "Do Good Rank"),
        ("0 kgCO2e", "Emissions Avoided")
    ]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isScrollEnabled = false
        return collection
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(PostsTableViewCell.self, forCellReuseIdentifier: PostsTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = true
        return table
    }()
    
    private let publicButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.title = "Public"
        config.attributedTitle = AttributedString("Public", attributes: AttributeContainer([.foregroundColor: UIColor.black]))
        config.image = UIImage(systemName: "xmark")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .medium)
        config.image = config.image?.withTintColor(.black, renderingMode: .alwaysOriginal)
        config.imagePadding = 5
        config.imagePlacement = .leading
        button.configuration = config
        button.layer.cornerRadius = 18
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray.withAlphaComponent(0.9)
        
        configureTopNavigationBar()
        setupViews()
        setupCollectionView()
        setupTableView()
        
        fetchPosts()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(collectionView)
        contentView.addSubview(publicButton)
        contentView.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            publicButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            publicButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: publicButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor).isActive = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureTopNavigationBar() {
        var superHumanLogo = UIImage(named: "super-human-logo")
        superHumanLogo = superHumanLogo?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: superHumanLogo, style: .done, target: self, action: nil)
        ]
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "tag.circle.fill"), style: .done, target: self, action: nil)
        ]
        navigationItem.rightBarButtonItem?.tintColor = .gray
        navigationItem.leftBarButtonItem?.tintColor = .gray
        
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    private func fetchPosts() {
        guard !isLoading else { return }
        isLoading = true
        loadingIndicator.startAnimating()
        
        NetworkManager.shared.getApiItems(lastId: lastId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            switch result {
            case .success(let json):
                if let data = json["data"] as? [String: Any],
                   let postsData = data["data"] as? [[String: Any]] {
                    if let lastPost = postsData.last,
                       let newLastId = lastPost["id"] as? Int {
                        self.lastId = newLastId
                    }
                    self.posts.append(contentsOf: postsData)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    print("Number of posts fetched: \(postsData.count)")
                } else {
                    print("Error: Unexpected data format")
                    self.showAlert(message: "Unexpected data format received from the server.")
                }
            case .failure(let error):
                print("Error fetching posts: \(error)")
                self.showAlert(message: "Failed to fetch posts: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostsTableViewCell.identifier, for: indexPath) as? PostsTableViewCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(with: post)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        
        if velocity.y > 0 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else if velocity.y < 0 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            fetchPosts()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labelsData.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let labelData = labelsData[indexPath.row]
        cell.cellValueLabel.text = labelData.0
        cell.cellLabel.text = labelData.1
        
        cell.backgroundColor = .lightGray.withAlphaComponent(0.4)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 50) / 2
        return CGSize(width: width, height: 80)
    }
}




