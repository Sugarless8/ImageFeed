//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Пахомов on 02.02.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.layoutIfNeeded()
        let imageSize = image.size
        let scrollViewSize = scrollView.bounds.size

        // Calculate the scaling factor that fits the image entirely in the scroll view
        let hScale = scrollViewSize.width / imageSize.width
        let vScale = scrollViewSize.height / imageSize.height
        let minScale = scrollView.minimumZoomScale
        let maxScale = scrollView.maximumZoomScale
        let optimalScale = min(maxScale, max(minScale, min(hScale, vScale)))

        // Set zoom scale and reset content offset
        scrollView.setZoomScale(optimalScale, animated: false)
        scrollView.layoutIfNeeded()

        // Resize the imageView to fit the scaled image
        let scaledImageWidth = imageSize.width * optimalScale
        let scaledImageHeight = imageSize.height * optimalScale
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: scaledImageWidth, height: scaledImageHeight))

        // Calculate insets to center the image if it's smaller than the scrollView
        let horizontalInset = max(0, (scrollViewSize.width - scaledImageWidth) / 2)
        let verticalInset = max(0, (scrollViewSize.height - scaledImageHeight) / 2)
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)

        // Enable bouncing always (even if image is smaller than scrollview)
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    
    
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

