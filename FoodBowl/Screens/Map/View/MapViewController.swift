//
//  MapViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/10.
//

import CoreLocation
import MapKit
import UIKit

import SnapKit
import Then

class MapViewController: UIViewController {
    // 임시 마커 데이터
    private var marks: [Marker]?

    // MARK: - property
    private lazy var mapView = MKMapView().then {
        $0.delegate = self
        $0.mapType = MKMapType.standard
        $0.showsUserLocation = true
        $0.setUserTrackingMode(.follow, animated: true)
        $0.isZoomEnabled = true
        $0.showsCompass = false
        $0.register(
            MapItemAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        $0.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
    }

    private lazy var mapHeaderView = MapHeaderView().then {
        let findAction = UIAction { [weak self] _ in
            let findStoreViewController = FindViewController()
            let navigationController = UINavigationController(rootViewController: findStoreViewController)
            navigationController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self?.present(navigationController, animated: true)
            }
        }
        let plusAction = UIAction { [weak self] _ in
            let addFeedViewController = AddFeedViewController()
            let navigationController = UINavigationController(rootViewController: addFeedViewController)
            navigationController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self?.present(navigationController, animated: true)
            }
        }
        $0.searchBarButton.addAction(findAction, for: .touchUpInside)
        $0.plusButton.addAction(plusAction, for: .touchUpInside)
    }

    private lazy var gpsButton = UIButton().then {
        $0.backgroundColor = .mainBackground
        $0.tintColor = .mainText
        $0.makeBorderLayer(color: .grey002)
        $0.setImage(ImageLiteral.btnGps.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let action = UIAction { [weak self] _ in
            self?.findMyLocation()
        }
        $0.addAction(action, for: .touchUpInside)
    }

    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationBar()
        findMyLocation()
        setMarkers()
    }

    func setupLayout() {
        view.addSubviews(mapView, mapHeaderView, gpsButton)

        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        if #available(iOS 13.0, *) {
            guard let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first else { return }
            let topPadding = window.safeAreaInsets.top
            let height = topPadding + 120
            mapHeaderView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(height)
            }
        } else {
            mapHeaderView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(120)
            }
        }

        gpsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.height.width.equalTo(50)
        }
    }

    func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }

    private func findMyLocation() {
        guard let currentLoc = LocationManager.shared.manager.location else { return }

        mapView.setRegion(
            MKCoordinateRegion(
                center: currentLoc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            animated: true
        )
    }

    // 임시 데이터
    private func setMarkers() {
        guard let currentLoc = LocationManager.shared.manager.location else { return }

        marks = [
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(
                    latitude: currentLoc.coordinate.latitude + 0.001,
                    longitude: currentLoc.coordinate.longitude + 0.001
                ),
                glyphImage: ImageLiteral.korean,
                handler: { [weak self] in
                    let storeFeedViewController = StoreFeedViewController()
                    storeFeedViewController.title = "틈새라면"
                    self?.navigationController?.pushViewController(storeFeedViewController, animated: true)
                }
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(
                    latitude: currentLoc.coordinate.latitude + 0.001,
                    longitude: currentLoc.coordinate.longitude + 0.002
                ),
                glyphImage: ImageLiteral.salad,
                handler: { [weak self] in
                    let storeFeedViewController = StoreFeedViewController()
                    storeFeedViewController.title = "틈새라면"
                    self?.navigationController?.pushViewController(storeFeedViewController, animated: true)
                }
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(
                    latitude: currentLoc.coordinate.latitude + 0.001,
                    longitude: currentLoc.coordinate.longitude + 0.003
                ),
                glyphImage: ImageLiteral.chinese,
                handler: { [weak self] in
                    let storeFeedViewController = StoreFeedViewController()
                    storeFeedViewController.title = "틈새라면"
                    self?.navigationController?.pushViewController(storeFeedViewController, animated: true)
                }
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(
                    latitude: currentLoc.coordinate.latitude + 0.001,
                    longitude: currentLoc.coordinate.longitude + 0.004
                ),
                glyphImage: ImageLiteral.japanese,
                handler: { [weak self] in
                    let storeFeedViewController = StoreFeedViewController()
                    storeFeedViewController.title = "틈새라면"
                    self?.navigationController?.pushViewController(storeFeedViewController, animated: true)
                }
            )
        ]

        marks?.forEach { mark in
            mapView.addAnnotation(mark)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view is ClusterAnnotationView else { return }

        let currentSpan = mapView.region.span
        let zoomSpan = MKCoordinateSpan(
            latitudeDelta: currentSpan.latitudeDelta / 3.0,
            longitudeDelta: currentSpan.longitudeDelta / 3.0
        )
        let zoomCoordinate = view.annotation?.coordinate ?? mapView.region.center
        let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
        mapView.setRegion(zoomed, animated: true)
    }
}
