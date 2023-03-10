//
//  FilterResultViewController.swift
//  HuTi
//
//  Created by Nguyễn Thịnh on 07/03/2023.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class FilterResultViewController: BaseViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addressCollectionView: UICollectionView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var mapButton: UIButton!
    @IBOutlet private weak var filterResultTableView: UITableView!
    @IBOutlet private weak var mapView: MKMapView!
    
    var viewModel = FilterResultViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - SetupUI.
extension FilterResultViewController {
    private func setupUI() {
        viewModel.initData()
        mapView.isHidden = true
        
        isHiddenNavigationBar = true
        titleLabel.text = viewModel.tabBarItemTitle
        setupCollectionView()
        setupTableView()
    }
    
    private func setupCollectionView() {
        addressCollectionView.register(AddressCollectionViewCell.nib, forCellWithReuseIdentifier: AddressCollectionViewCell.reusableIdentifier)
        
        viewModel.address.asObservable()
            .bind(to: addressCollectionView.rx.items(cellIdentifier: AddressCollectionViewCell.reusableIdentifier, cellType: AddressCollectionViewCell.self)) { (index, element, cell) in
                cell.config(content: element)
            }.disposed(by: viewModel.bag)
        
        addressCollectionView.rx.setDelegate(self).disposed(by: viewModel.bag)
    }
    
    private func setupTableView() {
        filterResultTableView.rowHeight = CommonConstants.tableRowHeight
        filterResultTableView.separatorStyle = .none
        
        filterResultTableView.register(FilterResultTableViewCell.nib, forCellReuseIdentifier: FilterResultTableViewCell.reusableIdentifier)
        
        viewModel.post.asObservable()
            .bind(to: filterResultTableView.rx.items(cellIdentifier: FilterResultTableViewCell.reusableIdentifier, cellType: FilterResultTableViewCell.self)) { (index, element, cell) in
                cell.config(element, isHiddenAuthorAndHeart: false)
            }.disposed(by: viewModel.bag)
        
        filterResultTableView.rx
            .modelSelected(Post.self)
            .subscribe { [weak self] element in
                guard let self = self else { return }
                print("table cell selected")
            }.disposed(by: viewModel.bag)
    }
}

// MARK: - IBAction.
extension FilterResultViewController {
    @IBAction func onClickedFilterBtn(_ sender: UIButton) {
        let vc = OTPViewController()
        navigateTo(vc)
    }
    
    @IBAction func onClickedMapBtn(_ sender: UIButton) {
        mapView.isHidden = !mapView.isHidden
        filterResultTableView.isHidden = !filterResultTableView.isHidden
        if !mapView.isHidden {
            mapButton.setImage(UIImage(named: ImageName.list), for: .normal)
        } else {
            mapButton.setImage(UIImage(systemName: ImageName.map), for: .normal)
        }
    }
}

// MARK: - Instance.
extension FilterResultViewController {
    class func instance(tabBarItemTitle: String) -> FilterResultViewController {
        let controller = FilterResultViewController(nibName: ClassNibName.FilterResultViewController, bundle: Bundle.main)
        controller.viewModel.tabBarItemTitle = tabBarItemTitle
        return controller
    }
}

// MARK: - Kích thước collectionView cell.
extension FilterResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = addressCollectionView.dequeueReusableCell(withReuseIdentifier: AddressCollectionViewCell.reusableIdentifier, for: indexPath) as! AddressCollectionViewCell
        let item = viewModel.address.value[indexPath.row]
        cell.config(content: item)
        let width = cell.contentLabel.intrinsicContentSize.width + 20
        return CGSize(width: width, height: 40)
    }
}
