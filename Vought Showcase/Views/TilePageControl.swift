//
//  TilePageControl.swift
//  Vought Showcase
//
//  Created by Prashant Kumar Soni on 15/09/24.
//

import Foundation
import UIKit

class TilePageControl: UIView {
    
    private var stackView: UIStackView = UIStackView()
    private var tiles: [UIView] = []
    private var numberOfPages: Int = 0
    private var currentPage: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(numberOfPages: Int, currentPage: Int) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
        updateTiles()
    }
    
    private func updateTiles() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tiles = []
        
        for _ in 0..<numberOfPages {
            let tile = UIView()
            tile.layer.cornerRadius = 4
            tile.translatesAutoresizingMaskIntoConstraints = false
            tile.heightAnchor.constraint(equalToConstant: 8).isActive = true
            tiles.append(tile)
            stackView.addArrangedSubview(tile)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        animateTiles()
    }
    
    private func animateTiles() {
        let duration: TimeInterval = 5.0
        
        for (index, tile) in tiles.enumerated() {
            if index < currentPage {
                tile.backgroundColor = UIColor.white
            } else if index == currentPage {
                tile.backgroundColor = UIColor.lightGray
                
                tile.layer.sublayers?.forEach { if $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
                
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0)
                gradientLayer.frame = tile.bounds
                gradientLayer.cornerRadius = tile.layer.cornerRadius
                gradientLayer.masksToBounds = true
                tile.layer.addSublayer(gradientLayer)
                
                gradientLayer.locations = [0, 0]
                
                let animation = CABasicAnimation(keyPath: "locations")
                animation.fromValue = [0, 0]
                animation.toValue = [1, 1]
                animation.duration = duration
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                gradientLayer.add(animation, forKey: "fillAnimation")
                
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    gradientLayer.locations = [1, 1]
                    gradientLayer.frame = tile.bounds
                }
                CATransaction.commit()
                
            } else {
                tile.backgroundColor = UIColor.lightGray
            }
        }
    }

    func setCurrentPage(_ page: Int) {
        guard page >= 0, page < numberOfPages else { return }
        currentPage = page
        updateTiles()
    }
}
