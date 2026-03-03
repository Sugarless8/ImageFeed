//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Пахомов on 31.01.2026.
//
import UIKit

final class ProfileViewController: UIViewController {
    // MARK:  UI Elements
    private let userPhotoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .photo))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35 // half of 70
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 23, weight: .bold)
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello world!"
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage.exit.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupLayout()
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func didTapExitButton() {
        // Example behavior: remove profile views from superview
        userPhotoView.removeFromSuperview()
        nameLabel.removeFromSuperview()
        descriptionLabel.removeFromSuperview()
        loginNameLabel.removeFromSuperview()
        exitButton.removeFromSuperview()
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(userPhotoView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            userPhotoView.widthAnchor.constraint(equalToConstant: 70),
            userPhotoView.heightAnchor.constraint(equalToConstant: 70),
            userPhotoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userPhotoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),

            nameLabel.topAnchor.constraint(equalTo: userPhotoView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: userPhotoView.leadingAnchor),

            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: userPhotoView.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: userPhotoView.leadingAnchor),

            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: userPhotoView.centerYAnchor)
        ])
    }
}

