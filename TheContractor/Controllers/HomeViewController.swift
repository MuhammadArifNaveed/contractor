//
//  HomeViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/26/21.
//

import UIKit

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var companyCollectionView: UICollectionView!
    @IBOutlet weak var subCategoryCollectionView: UICollectionView!
    @IBOutlet weak var browseCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var heightSubcategoryCollection: NSLayoutConstraint!
    var homeData = HomeViewModel()
    var selectedCat = CategoryViewModel()
    var selectedBrowse = 0
    var selectedCategory = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getHomeData()
        self.heightSubcategoryCollection.constant = CGFloat(75 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
        
    }
    @IBAction func actionSearch(_ sender: Any) {
        if let container = self.mainContainer{
            container.showSearchCompanyController()
        }
    }
}
extension HomeViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.categoryCollectionView || collectionView == browseCollectionView){
            return self.homeData.categoryList.categoryList.count
        }
        else if(collectionView == companyCollectionView){
            return self.homeData.titiniumCompanyList.companyList.count
        }
        else{
            return self.selectedCat.sub_categories.subCategoryList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.categoryCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            if(self.homeData.categoryList.categoryList[indexPath.row].isSelected){
                //  cell.lblBorder.backgroundColor = UIColor.init(hexFromString: "00582A")
                cell.lblName.textColor = UIColor.init(hexFromString: "00582A")
            }
            else{
                // cell.lblBorder.backgroundColor = .white
                cell.lblName.textColor = .black
            }
            cell.lblName.text = self.homeData.categoryList.categoryList[indexPath.item].name
            return cell
        }
        else if(collectionView == self.browseCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
            if(self.homeData.categoryList.categoryList[indexPath.row].isSelected){
                cell.lblBorder.backgroundColor = UIColor.init(hexFromString: "00582A")
                cell.lblName.textColor = UIColor.init(hexFromString: "00582A")
            }
            else{
                cell.lblBorder.backgroundColor = .white
                cell.lblName.textColor = .black
            }
            cell.lblName.text = self.homeData.categoryList.categoryList[indexPath.row].name
            return cell
        }
        else if collectionView == subCategoryCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.lblName.text = self.selectedCat.sub_categories.subCategoryList[indexPath.row].name
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCollectionViewCell", for: indexPath) as! CompanyCollectionViewCell
            self.setImageWithUrl(imageView: cell.imgCompany, url: self.homeData.titiniumCompanyList.companyList[indexPath.row].company_logo)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.categoryCollectionView){
            self.selectedBrowse = indexPath.item
            for cat in self.homeData.categoryList.categoryList{
                cat.isSelected = false
            }
            self.homeData.categoryList.categoryList[indexPath.item].isSelected = true
            self.selectedCat = self.homeData.categoryList.categoryList[indexPath.item]
            self.heightSubcategoryCollection.constant = CGFloat(75 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
            self.subCategoryCollectionView.reloadData()
            self.browseCollectionView.reloadData()
        }
        else if(collectionView == browseCollectionView){
            self.selectedCategory = indexPath.item
            for cat in self.homeData.categoryList.categoryList{
                cat.isSelected = false
            }
            self.homeData.categoryList.categoryList[indexPath.item].isSelected = true
            self.selectedCat = self.homeData.categoryList.categoryList[indexPath.item]
            self.heightSubcategoryCollection.constant = CGFloat(75 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
            self.subCategoryCollectionView.reloadData()
            self.browseCollectionView.reloadData()
        }
        else if collectionView == subCategoryCollectionView{
            let params : ParamsAny = ["category_id" : self.selectedCat.id ,"sub_category" : self.selectedCat.sub_categories.subCategoryList[indexPath.row].id]
            self.getSearchedCompaniesData(params: params)
        }
        else{
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CompanyDetailsViewController") as! CompanyDetailsViewController
            vc.companyDetails = self.homeData.titiniumCompanyList.companyList[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == self.categoryCollectionView){
            let string: NSString = NSString.init(string: self.homeData.categoryList.categoryList[indexPath.item].name)
            let size = string.size(withAttributes: nil)
            return CGSize(width: size.width + 60, height: 40)
        }
        else if(collectionView == browseCollectionView){
            let string: NSString = NSString.init(string: self.homeData.categoryList.categoryList[indexPath.item].name)
            let size = string.size(withAttributes: nil)
            return CGSize(width: size.width + 35, height: 40)
        }
        else if(collectionView == self.subCategoryCollectionView){
            return CGSize(width: self.subCategoryCollectionView.frame.width / 2, height: 65)
        }
        else{
            return CGSize(width: self.companyCollectionView.frame.width / 2.5, height: 115)
        }
    }
}
extension HomeViewController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeData.companyList.companyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyDetailsTableViewCell", for: indexPath) as! CompanyDetailsTableViewCell
        cell.selectionStyle = .none
        cell.configureView(company: self.homeData.companyList.companyList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CompanyDetailsViewController") as! CompanyDetailsViewController
        vc.companyDetails = self.homeData.companyList.companyList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController{
    func getHomeData(){
        self.startActivity()
        GCD.async(.Background){
            LoginService.shared().getHomeData(params: [:]) { (message, success, homeData) in
                GCD.async(.Main){
                    self.stopActivity()
                    if(success){
                        self.homeData = homeData!
                        if(self.homeData.categoryList.categoryList.count > 0){
                            self.selectedCat =     self.homeData.categoryList.categoryList.first!
                            self.homeData.categoryList.categoryList.first!.isSelected = true
                            self.heightSubcategoryCollection.constant = CGFloat(75 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
                            self.heightTableView.constant = CGFloat(135 * self.homeData.companyList.companyList.count)
                            self.categoryCollectionView.reloadData()
                            self.subCategoryCollectionView.reloadData()
                            self.browseCollectionView.reloadData()
                            self.companyCollectionView.reloadData()
                            self.tableView.reloadData()
                        }
                        
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


