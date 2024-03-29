//
//  FilterViewController.swift
//  HuTi
//
//  Created by Nguyễn Thịnh on 15/03/2023.
//

import UIKit
import RxSwift
import RxCocoa

protocol FilterViewControllerDelegate: AnyObject {
    func didTapApplyButton(listOptions: [(Int, String)], findPostParams: [String: Any]?, findProjectParams: [String: Any]?, selectedProvince: (index: Int, id: String), selectedDistrict: (index: Int, id: String))
    
    func didTapResetButton()
}

class FilterViewController: BaseViewController {

    @IBOutlet weak var acreageView: UIView!
    @IBOutlet weak var wardView: UIView!
    @IBOutlet weak var extraTitleLabel: UILabel!
    @IBOutlet weak var bedroomView: UIView!
    @IBOutlet weak var houseDirectionView: UIView!
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var wardTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var acreageTextField: UITextField!
    @IBOutlet weak var bedroomTextField: UITextField!
    @IBOutlet weak var houseDirectionTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    
    let typePicker = UIPickerView()
    let provincePicker = UIPickerView()
    let districtPicker = UIPickerView()
    let wardPicker = UIPickerView()
    let pricePicker = UIPickerView()
    let acreagePicker = UIPickerView()
    let bedroomPicker = UIPickerView()
    let houseDirectionPicker = UIPickerView()
    let statusPicker = UIPickerView()
    var viewModel = FilterViewModel()
    weak var delegate: FilterViewControllerDelegate?
    
    func configSelectedOptions(optionsList: [(key: Int, value: String)], selectedProvince: (index: Int, id: String), selectedDistrict: (index: Int, id: String)) {
        viewModel.optionsList = optionsList
        viewModel.selectedProvince = selectedProvince
        viewModel.selectedDistrict = selectedDistrict
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainTabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickerView()
    }
    
    private func setupUI() {
        if viewModel.tabBarItemTitle == TabBarItemTitle.project {
            typeTextField.placeholder = TextFieldPlaceHolder.typeProject
            wardView.isHidden = true
            acreageView.isHidden = true
            extraTitleLabel.isHidden = true
            bedroomView.isHidden = true
            houseDirectionView.isHidden = true
        } else {
            typeTextField.placeholder = TextFieldPlaceHolder.typeRealEstate
            statusView.isHidden = true
        }
        reloadPreviousOptions()
        isHiddenMainTabBar = true
        isTouchDismissKeyboardEnabled = true
        
        districtTextField.rx.controlEvent([.editingDidBegin])
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.provinceTextField.text != "" {
                    self.setupDistrictDataPicker()
                }
            }).disposed(by: viewModel.bag)
        
        wardTextField.rx.controlEvent([.editingDidBegin])
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.districtTextField.text != "" {
                    self.setupWardDataPicker()
                }
            }).disposed(by: viewModel.bag)
    }
    
    private func getAllProvince() {
        viewModel.getAllProvinces().subscribe { [weak self] provinces in
            guard let self = self else { return }
            self.viewModel.province.accept(self.viewModel.parseProvincesArray(provinces: provinces))
        } onError: { _ in
        } onCompleted: {
        } .disposed(by: viewModel.bag)
    }
    
    private func setupPickerView() {
        setupTypePickerView()
        setupProvincePickerView()
        setupDistrictPickerView()
        setupWardPickerView()
        setupPricePickerView()
        setupAcreagePickerView()
        setupBedroomPickerView()
        setupHouseDirectionPickerView()
        setupStatusPickerView()
    }
    
    @IBAction func onClickedResetBtn(_ sender: UIButton) {
        typeTextField.text = ""
        provinceTextField.text = ""
        districtTextField.text = ""
        wardTextField.text = ""
        priceTextField.text = ""
        acreageTextField.text = ""
        bedroomTextField.text = ""
        houseDirectionTextField.text = ""
        statusTextField.text = ""
        viewModel.optionsList = [(key: Int, value: String)]()
        delegate?.didTapResetButton()
    }
    
    @IBAction func onClickedBackBtn(_ sender: UIButton) {
        isHiddenMainTabBar = false
        backToPreviousView()
    }
    
    @IBAction func onClickedApplyBtn(_ sender: UIButton) {
        if getApplyOptions().count > 1 {
            if viewModel.tabBarItemTitle == TabBarItemTitle.project {
                prepareProjectParam()
                delegate?.didTapApplyButton(listOptions: self.getApplyOptions(), findPostParams: nil, findProjectParams: viewModel.searchProjectParams, selectedProvince: viewModel.selectedProvince, selectedDistrict: viewModel.selectedDistrict)
                self.isHiddenMainTabBar = false
                self.backToPreviousView()
            } else {
                preparePostParam()
                delegate?.didTapApplyButton(listOptions: self.getApplyOptions(), findPostParams: viewModel.searchPostParams, findProjectParams: nil, selectedProvince: viewModel.selectedProvince, selectedDistrict: viewModel.selectedDistrict)
                self.isHiddenMainTabBar = false
                self.backToPreviousView()
            }
        } else {
            showAlert(title: Alert.pleaseChooseTypeProvince)
        }
    }
    
    private func preparePostParam() { 
        if viewModel.tabBarItemTitle == TabBarItemTitle.sell {
            viewModel.searchPostParams.updateValue(true, forKey: "isSell")
        } else {
            viewModel.searchPostParams.updateValue(false, forKey: "isSell")
        }
        
        if let type = typeTextField.text,
           type != "",
           type != RealEstateType.all {
            viewModel.searchPostParams.updateValue(type, forKey: "realEstateType")
        }
        
        if let province = provinceTextField.text,
           province != "" {
            viewModel.searchPostParams.updateValue(province, forKey: "provinceName")
        }
        
        if let district = districtTextField.text,
           district != "" {
            viewModel.searchPostParams.updateValue(district, forKey: "districtName")
        }
        
        if let ward = wardTextField.text,
           ward != "" {
            viewModel.searchPostParams.updateValue(ward, forKey: "wardName")
        }
        
        if let price = priceTextField.text,
           price != PickerData.price[0],
           price != "" {
            viewModel.searchPostParams.updateValue(price, forKey: "priceRange")
        }
        
        if let acreage = acreageTextField.text,
           acreage != PickerData.acreage[0],
           acreage != "" {
            viewModel.searchPostParams.updateValue(acreage, forKey: "acreageRange")
        }
        
        if let bedroom = bedroomTextField.text,
           bedroom != "" {
            viewModel.searchPostParams.updateValue(bedroom, forKey: "bedroomRange")
        }
        
        if let houseDirection = houseDirectionTextField.text,
           houseDirection != "" {
            viewModel.searchPostParams.updateValue(houseDirection, forKey: "houseDirection")
        }
    }
    
    private func prepareProjectParam() {
        if let type = typeTextField.text,
           type != "",
           type != RealEstateType.project[0] {
            viewModel.searchProjectParams.updateValue(type, forKey: "projectType")
        }
        
        if let province = provinceTextField.text,
           province != "" {
            viewModel.searchProjectParams.updateValue(province, forKey: "provinceName")
        }
        
        if let district = districtTextField.text,
           district != "" {
            viewModel.searchProjectParams.updateValue(district, forKey: "districtName")
        }
        
        if let price = priceTextField.text,
           price != PickerData.price[0],
           price != "" {
            viewModel.searchProjectParams.updateValue(price, forKey: "priceRange")
        }
        
        if let status = statusTextField.text,
           status != "" {
            viewModel.searchProjectParams.updateValue(status, forKey: "status")
        }
    }
 }

extension FilterViewController {
    private func reloadPreviousOptions() {
        for (_, element) in viewModel.optionsList.enumerated() {
            switch element.key {
            case PickerTag.type:
                typeTextField.text = element.value
            case PickerTag.province:
                provinceTextField.text = element.value
            case PickerTag.district:
                districtTextField.text = element.value
            case PickerTag.ward:
                wardTextField.text = element.value
            case PickerTag.price:
                priceTextField.text = element.value
            case PickerTag.acreage:
                acreageTextField.text = element.value
            case PickerTag.bedroom:
                bedroomTextField.text = element.value
            case PickerTag.houseDirection:
                houseDirectionTextField.text = element.value
            case PickerTag.status:
                statusTextField.text = element.value
            default:
                return
            }
        }
    }
    
    private func setupTypePickerView() {
        typeTextField.inputView = typePicker
        typeTextField.tintColor = .clear
        typePicker.tag = PickerTag.type
        typeTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.type)
        switch viewModel.tabBarItemTitle {
        case TabBarItemTitle.sell:
            viewModel.type.accept(RealEstateType.sell)
        case TabBarItemTitle.forRent:
            viewModel.type.accept(RealEstateType.forRent)
        case TabBarItemTitle.project:
            viewModel.type.accept(RealEstateType.project)
        default:
            return
        }
        viewModel.type.subscribe(on: MainScheduler.instance)
            .bind(to: typePicker.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: viewModel.bag)

        typePicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedFilterType = row
        }.disposed(by: viewModel.bag)
    }
    
    private func setupProvincePickerView() {
        provinceTextField.inputView = provincePicker
        provinceTextField.tintColor = .clear
        provincePicker.tag = PickerTag.province
        provinceTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.province)

        getAllProvince()

        viewModel.province.subscribe(on: MainScheduler.instance)
            .bind(to: provincePicker.rx.itemTitles) { (row, element) in
                return element.name
            }.disposed(by: viewModel.bag)

        provincePicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedProvince.index = row
            self.viewModel.selectedProvince.id = self.viewModel.province.value[row].id
        }.disposed(by: viewModel.bag)
    }

    private func setupDistrictDataPicker() {
        wardTextField.text = ""
        
        viewModel.getDistrictsByProvinceId().subscribe { [weak self] districts in
            guard let self = self else { return }
            self.viewModel.district.accept(self.viewModel.parseDistrictsArray(districts: districts))
        } onError: { _ in
        } onCompleted: {
        }.disposed(by: viewModel.bag)
    }
    
    private func setupDistrictPickerView() {
        districtTextField.inputView = districtPicker
        districtTextField.tintColor = .clear
        districtPicker.tag = PickerTag.district
        districtTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.district)

        viewModel.district.subscribe(on: MainScheduler.instance)
            .bind(to: districtPicker.rx.itemTitles) { (row, element) in
                return element.name
            }.disposed(by: viewModel.bag)

        districtPicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedDistrict.index = row
            self.viewModel.selectedDistrict.id = self.viewModel.district.value[row].id
        }.disposed(by: viewModel.bag)
    }

    private func setupWardDataPicker() {
        viewModel.getWardsByDistrictId().subscribe { [weak self] wards in
            guard let self = self else { return }
            self.viewModel.ward.accept(self.viewModel.parseWardsArray(wards: wards))
        } onError: { _ in
        } onCompleted: {
        }.disposed(by: viewModel.bag)
    }
    
    private func setupWardPickerView() {
        wardTextField.inputView = wardPicker
        wardTextField.tintColor = .clear
        wardPicker.tag = PickerTag.ward
        wardTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.ward)
    
        viewModel.ward.subscribe(on: MainScheduler.instance)
            .bind(to: wardPicker.rx.itemTitles) { (row, element) in
                return element.name
            }.disposed(by: viewModel.bag)

        wardPicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedWard = row
        }.disposed(by: viewModel.bag)
    }

    private func setupPricePickerView() {
        priceTextField.inputView = pricePicker
        priceTextField.tintColor = .clear
        pricePicker.tag = PickerTag.price
        priceTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.price)

        if viewModel.tabBarItemTitle == TabBarItemTitle.project {
            viewModel.price.accept(PickerData.projectPrice)
        } else {
            viewModel.price.accept(PickerData.price)
        }

        viewModel.price.subscribe(on: MainScheduler.instance)
            .bind(to: pricePicker.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: viewModel.bag)

        pricePicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedPrice = row
        }.disposed(by: viewModel.bag)
    }

    private func setupAcreagePickerView() {
        acreageTextField.inputView = acreagePicker
        acreageTextField.tintColor = .clear
        acreageTextField.tag = PickerTag.acreage
        acreageTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.acreage)

        viewModel.acreage.accept(PickerData.acreage)

        viewModel.acreage.subscribe(on: MainScheduler.instance)
            .bind(to: acreagePicker.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: viewModel.bag)

        acreagePicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedAcreage = row
        }.disposed(by: viewModel.bag)
    }

    private func setupBedroomPickerView() {
        bedroomTextField.inputView = bedroomPicker
        bedroomTextField.tintColor = .clear
        bedroomPicker.tag = PickerTag.bedroom
        bedroomTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.bedroom)
        
        viewModel.bedroom.accept(PickerData.bedroom)

        viewModel.bedroom.subscribe(on: MainScheduler.instance)
            .bind(to: bedroomPicker.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: viewModel.bag)

        bedroomPicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedBedroom = row
        }.disposed(by: viewModel.bag)
    }

    private func setupHouseDirectionPickerView() {
        houseDirectionTextField.inputView = houseDirectionPicker
        houseDirectionTextField.tintColor = .clear
        houseDirectionPicker.tag = PickerTag.houseDirection
        houseDirectionTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.houseDirection)

        viewModel.houseDirection.accept(PickerData.direction)

        viewModel.houseDirection.subscribe(on: MainScheduler.instance)
            .bind(to: houseDirectionPicker.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: viewModel.bag)

        houseDirectionPicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedFilterHouseDirection = row
        }.disposed(by: viewModel.bag)
    }

    private func setupStatusPickerView() {
        statusTextField.inputView = statusPicker
        statusTextField.tintColor = .clear
        statusPicker.tag = PickerTag.status
        statusTextField.inputAccessoryView = setupPickerToolBar(pickerTag: PickerTag.status)

        viewModel.status.accept(PickerData.status)

        viewModel.status.subscribe(on: MainScheduler.instance)
            .bind(to: statusPicker.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: viewModel.bag)

        statusPicker.rx.itemSelected.bind { (row: Int, component: Int) in
            self.viewModel.selectedStatus = row
        }.disposed(by: viewModel.bag)
    }
    
    private func setupPickerToolBar(pickerTag: Int) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.backgroundColor = .clear
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: CommonConstants.done, style: .done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: CommonConstants.cancel, style: .plain, target: self, action: #selector(self.cancelPicker))
        
        cancelButton.tag = pickerTag
        doneButton.tag = pickerTag
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    @objc private func donePicker(sender: UIBarButtonItem) {
        switch sender.tag {
        case PickerTag.type:
            typeTextField.text = viewModel.pickItem(pickerTag: sender.tag)
        case PickerTag.province:
            provinceTextField.text = viewModel.pickItem(pickerTag: sender.tag)
            if provinceTextField.text != "" {
                districtTextField.text = ""
                setupDistrictDataPicker()
            }
        case PickerTag.district:
            districtTextField.text = viewModel.pickItem(pickerTag: sender.tag)
            if districtTextField.text != "" {
                wardTextField.text = ""
                setupWardDataPicker()
            }
        case PickerTag.ward:
            wardTextField.text = viewModel.pickItem(pickerTag: sender.tag)
        case PickerTag.price:
            priceTextField.text = viewModel.pickItem(pickerTag: sender.tag)
        case PickerTag.acreage:
            acreageTextField.text = viewModel.pickItem(pickerTag: sender.tag)
        case PickerTag.bedroom:
            bedroomTextField.text = viewModel.pickItem(pickerTag: sender.tag)
        case PickerTag.houseDirection:
            houseDirectionTextField.text = viewModel.pickItem(pickerTag: sender.tag)
        case PickerTag.status:
            statusTextField.text = viewModel.pickItem(pickerTag: sender.tag)
        default:
            return
        }
        view.endEditing(true)
    }
    
    @objc private func cancelPicker() {
        view.window?.endEditing(true)
    }
}

extension FilterViewController {
    private func getApplyOptions() -> [(Int, String)] {
        guard let type = typeTextField.text,
              let city = provinceTextField.text,
              type != "",
              city != ""
        else { return [(Int, String)]() }
        var listOptions: [(Int, String)] = [(PickerTag.type, type), (PickerTag.province, city)]
        if let district = districtTextField.text, district != "" {
            listOptions += [(PickerTag.district, district)]
        }
        if let ward = wardTextField.text, ward != "" {
            listOptions += [(PickerTag.ward, ward)]
        }
        if let price = priceTextField.text, price != "" {
            listOptions += [(PickerTag.price, price)]
        }
        if let acreage = acreageTextField.text, acreage != "" {
            listOptions += [(PickerTag.acreage, acreage)]
        }
        if let bedroom = bedroomTextField.text, bedroom != "" {
            listOptions += [(PickerTag.bedroom, bedroom)]
        }
        if let houseDirection = houseDirectionTextField.text, houseDirection != "" {
            listOptions += [(PickerTag.houseDirection, houseDirection)]
        }
        if let status = statusTextField.text, status != "" {
            listOptions += [(PickerTag.status, status)]
        }
        return listOptions
    }
}

// MARK: - Instance.
extension FilterViewController {
    class func instance(tabBarItemTitle: String) -> FilterViewController {
        let controller = FilterViewController(nibName: ClassNibName.FilterViewController, bundle: Bundle.main)
        controller.viewModel.tabBarItemTitle = tabBarItemTitle
        return controller
    }
}
