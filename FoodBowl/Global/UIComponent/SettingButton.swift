//
//  SettingButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/24.
//

import UIKit

final class SettingButton: UIButton {
    // MARK: - init

    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 30, height: 30)))
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle

    private func configureUI() {
        setImage(
            ImageLiteral.btnSetting.resize(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        tintColor = .mainText
    }
}
