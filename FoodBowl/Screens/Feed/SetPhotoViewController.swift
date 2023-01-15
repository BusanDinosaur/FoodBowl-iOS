//
//  SetPhotoViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

import SnapKit
import Then
import YPImagePicker

final class SetPhotoViewController: BaseViewController {
    private enum Size {
        static let cellWidth: CGFloat = (UIScreen.main.bounds.size.width - 48) / 3
        static let cellHeight: CGFloat = cellWidth
        static let collectionInset = UIEdgeInsets(top: 0,
                                                  left: 20,
                                                  bottom: 20,
                                                  right: 20)
    }

    // MARK: - property

    private let guideLabel = UILabel().then {
        $0.text = "음식 사진을 등록해주세요."
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .medium)
    }

    private lazy var galleryButton = GalleryButton().then {
        let action = UIAction { [weak self] _ in
            self?.photoAddButtonDidTap()
        }
        $0.addAction(action, for: .touchUpInside)
    }

    private let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.sectionInset = Size.collectionInset
        $0.itemSize = CGSize(width: Size.cellWidth, height: Size.cellHeight)
        $0.minimumLineSpacing = 4
        $0.minimumInteritemSpacing = 4
    }

    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.showsVerticalScrollIndicator = false
        $0.register(FeedThumnailCollectionViewCell.self, forCellWithReuseIdentifier: FeedThumnailCollectionViewCell.className)
    }

    // MARK: - life cycle

    override func render() {
        view.addSubviews(guideLabel, galleryButton, listCollectionView)

        guideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        galleryButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        listCollectionView.snp.makeConstraints {
            $0.top.equalTo(guideLabel.safeAreaLayoutGuide.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func photoAddButtonDidTap() {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 10 // 최대 선택 가능한 사진 개수 제한
        config.library.mediaType = .photo // 미디어타입(사진, 사진/동영상, 동영상)
        config.startOnScreen = YPPickerScreen.library
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "FoodBowl"

        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        let barButtonAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline, weight: .regular)]
        UINavigationBar.appearance().titleTextAttributes = titleAttributes // Title fonts
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: .normal) // Bar Button fonts
        config.wordings.libraryTitle = "갤러리"
        config.wordings.cameraTitle = "카메라"
        config.wordings.next = "다음"
        config.wordings.cancel = "취소"
        config.colors.tintColor = .mainPink

        let picker = YPImagePicker(configuration: config)

        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }

    private func cappedSize(for size: CGSize, cappedAt: CGFloat) -> CGSize {
        var cappedWidth: CGFloat = 0
        var cappedHeight: CGFloat = 0
        if size.width > size.height {
            // Landscape
            let heightRatio = size.height / size.width
            cappedWidth = min(size.width, cappedAt)
            cappedHeight = cappedWidth * heightRatio
        } else if size.height > size.width {
            // Portrait
            let widthRatio = size.width / size.height
            cappedHeight = min(size.height, cappedAt)
            cappedWidth = cappedHeight * widthRatio
        } else {
            // Squared
            cappedWidth = min(size.width, cappedAt)
            cappedHeight = min(size.height, cappedAt)
        }
        return CGSize(width: cappedWidth, height: cappedHeight)
    }
}

extension SetPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedThumnailCollectionViewCell.className, for: indexPath) as? FeedThumnailCollectionViewCell else {
            return UICollectionViewCell()
        }

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {}
}

extension YPPhotoFiltersVC {
    func makeBarButtonItem<T: UIView>(with view: T) -> UIBarButtonItem {
        return UIBarButtonItem(customView: view)
    }

    func removeBarButtonItemOffset(with button: UIButton, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> UIView {
        let offsetView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        offsetView.bounds = offsetView.bounds.offsetBy(dx: offsetX, dy: offsetY)
        offsetView.addSubview(button)
        return offsetView
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let controllersCount = navigationController?.viewControllers.count, controllersCount > 1 {
            lazy var backButton = BackButton().then {
                let buttonAction = UIAction { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                $0.addAction(buttonAction, for: .touchUpInside)
            }

            let leftOffsetBackButton = removeBarButtonItemOffset(with: backButton, offsetX: 10)
            let backButtonView = makeBarButtonItem(with: leftOffsetBackButton)

            navigationItem.leftBarButtonItem = backButtonView
            title = "필터 선택"
        }
    }
}
