//
//  BaseCollectionViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - func

    func setupLayout() {
        // Override Layout
    }

    func configureUI() {
        // View Configuration
    }
}
