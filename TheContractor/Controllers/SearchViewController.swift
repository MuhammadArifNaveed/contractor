//
//  SearchViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/26/21.
//

import UIKit
import iOSDropDown

class SearchViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var txtfArea: DropDown!
    @IBOutlet weak var citiesCollectionView: UICollectionView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var heightSubCategoryCollection: NSLayoutConstraint!
    @IBOutlet weak var txtfKeyword: UITextField!
    var searchData = SearchViewModel()
    var selectedCat = CategoryViewModel()
    var isCheckSelected = false
    var areaID = ""
    
    
    //  var categories = ["Construction","Decore" ,"Maintenance"]
    // var selectedCity = 0
    //var selectedCategory = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSearchData()
        self.btnCheck.setImage(UIImage(named: "check"), for: .normal)
        self.txtfArea.allowsEditingTextAttributes = false
        self.heightSubCategoryCollection.constant = CGFloat(60 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionCheck(_ sender: Any) {
        self.isCheckSelected = !isCheckSelected
        if(isCheckSelected){
            self.btnCheck.setImage(UIImage(named: "checked"), for: .normal)
        }
        else{
            self.btnCheck.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    @IBAction func actionSearch(_ sender: Any) {
        let selectedSubCat = self.selectedCat.sub_categories.subCategoryList.filter({$0.isSelected})
        if(selectedSubCat.count == 0){
            self.showAlertView(message: "Please Select SubCategory")
        }
        else{
            var selectedcityId = ""
            var isVerified = "0"
            if(self.isCheckSelected){
                isVerified = "1"
            }
            else{
                isVerified = "0"
            }
            let selectedCity = self.searchData.cities.cityList.filter({$0.isSelected})
            if(selectedCity.count > 0){
                selectedcityId = selectedCity.first!.id
            }
            let params : ParamsAny = ["category_id" : self.selectedCat.id ,"sub_category" : selectedSubCat.first!.id , "city" : selectedcityId, "area" : self.areaID, "verified" : isVerified , "keyword" : self.txtfKeyword.text ?? ""]
            self.getSearchedCompaniesData(params: params)
        }
        
    }
    
}
extension SearchViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.citiesCollectionView){
            return self.searchData.cities.cityList.count
        }
        else if(collectionView == self.categoryCollectionView){
            return self.searchData.categories.categoryList.count
        }
        else{
            return self.selectedCat.sub_categories.subCategoryList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.citiesCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
            if(self.searchData.cities.cityList[indexPath.row].isSelected){
                cell.lblBorder.backgroundColor = UIColor.init(hexFromString: "00582A")
                cell.lblName.textColor = UIColor.init(hexFromString: "00582A")
            }
            else{
                cell.lblBorder.backgroundColor = .white
                cell.lblName.textColor = .black
            }
            cell.lblName.text = self.searchData.cities.cityList[indexPath.row].name
            return cell
        }
        else if(collectionView == self.categoryCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
            if(self.searchData.categories.categoryList[indexPath.row].isSelected){
                cell.lblBorder.backgroundColor = UIColor.init(hexFromString: "00582A")
                cell.lblName.textColor = UIColor.init(hexFromString: "00582A")
            }
            else{
                cell.lblBorder.backgroundColor = .white
                cell.lblName.textColor = .black
            }
            cell.lblName.text = self.searchData.categories.categoryList[indexPath.row].name
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.lblName.text = self.selectedCat.sub_categories.subCategoryList[indexPath.row].name
            if(self.selectedCat.sub_categories.subCategoryList[indexPath.row].isSelected){
                cell.viewBack.backgroundColor = UIColor.init(hexFromString: "00582A")
                cell.lblName.textColor = .white
            }
            else{
                cell.viewBack.backgroundColor = .white
                cell.lblName.textColor = .black
            }
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.citiesCollectionView){
            self.txtfArea.text?.removeAll()
            for city in self.searchData.cities.cityList{
                city.isSelected = false
            }
            self.areaID = ""
            self.searchData.cities.cityList[indexPath.row].isSelected = true
            var areaNames = self.searchData.cities.cityList[indexPath.row].areas.areaList.map({$0.area_name})
            areaNames.insert("Select Area", at: 0)
            var areaIds = self.searchData.cities.cityList[indexPath.row].areas.areaList.map({Int($0.area_id)!})
            areaIds.insert(-1, at: 0)
            txtfArea.optionArray = areaNames
            txtfArea.optionIds = areaIds
            txtfArea.didSelect{(selectedText , index ,id) in
                if(id == -1){
                    self.areaID = ""
                }
                else{
                    self.areaID = "\(id)"
                }
                // self.valueLabel.text = "Selected String: \(selectedText) \n index: \(index)"
            }
            self.citiesCollectionView.reloadData()
        }
        else if(collectionView == categoryCollectionView){
            for cat in self.searchData.categories.categoryList{
                cat.isSelected = false
            }
            self.selectedCat = self.searchData.categories.categoryList[indexPath.item]
            self.searchData.categories.categoryList[indexPath.row].isSelected = true
            self.heightSubCategoryCollection.constant = CGFloat(60 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
            self.collectionView.reloadData()
            self.categoryCollectionView.reloadData()
        }
        else{
            for subCat in self.selectedCat.sub_categories.subCategoryList{
                subCat.isSelected = false
            }
            self.selectedCat.sub_categories.subCategoryList[indexPath.row].isSelected = true
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == self.citiesCollectionView){
            let string: NSString = NSString.init(string: self.searchData.cities.cityList[indexPath.item].name)
            let size = string.size(withAttributes: nil)
            return CGSize(width: size.width + 35, height: 40)
        }
        else if(collectionView == self.categoryCollectionView){
            let string: NSString = NSString.init(string: self.searchData.categories.categoryList[indexPath.item].name)
            let size = string.size(withAttributes: nil)
            return CGSize(width: size.width + 35, height: 40)
        }
        else{
            return CGSize(width: self.collectionView.frame.width / 2, height: 55)
        }
    }
}
extension SearchViewController{
    func getSearchData(){
        self.startActivity()
        GCD.async(.Background){
            LoginService.shared().getSearchData(params: [:]) { (message, success, searchData) in
                GCD.async(.Main){
                    self.stopActivity()
                    if(success){
                        self.searchData = searchData!
                        if(self.searchData.categories.categoryList.count > 0){
                            self.selectedCat = self.searchData.categories.categoryList.first!
                            self.heightSubCategoryCollection.constant = CGFloat(60 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
                            self.searchData.categories.categoryList.first!.isSelected = true
                        }
                        self.collectionView.reloadData()
                        self.categoryCollectionView.reloadData()
                        self.citiesCollectionView.reloadData()
                    }
                    else{
                        self.showAlertView(message: message)
                    }
                }
            }
        }
    }
    func getSearchedCompaniesData(params : ParamsAny){
        self.startActivity()
        GCD.async(.Background){
            LoginService.shared().getSearchedCompanies(params: params) { (message, success, companylist) in
                GCD.async(.Main){
                    self.stopActivity()
                    if(success){
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "CompaniesListViewController") as! CompaniesListViewController
                        vc.companyList = companylist!
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else{
                        self.showAlertView(message: message)
                    }
                }
            }
        }
    }
}

