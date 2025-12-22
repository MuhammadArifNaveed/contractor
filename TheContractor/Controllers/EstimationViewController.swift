//
//  EstimationViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/25/21.
//

import UIKit

class EstimationViewController: BaseViewController {

    @IBOutlet weak var txtfSqft: UITextField!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblSqft: UILabel!
    @IBOutlet weak var lblSubcategory: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var viewEsstimation: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    var categoryList = CategoryListViewModel()
    var selectedCat = CategoryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewEsstimation.isHidden = true
        self.getEsstiamtionData()
        self.collectionViewHeight.constant = CGFloat(60 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
        // Do any additional setup after loading the view.
    }
    
    
    func configureEsstimationView(){
        let selectedSubCat = self.selectedCat.sub_categories.subCategoryList.filter({$0.isSelected})
        if(selectedSubCat.count == 0){
            self.showAlertView(message: "Please Select Category")
        }
        else if(self.txtfSqft.text == ""){
            self.showAlertView(message: "Please Enter Sqft")
        }
        else{
            self.viewEsstimation.isHidden = false
            self.lblSqft.text = "\(self.txtfSqft.text!) Sqft"
            self.lblCategory.text = self.selectedCat.name
            self.lblSubcategory.text = selectedSubCat.first!.name
            let budget = Int(selectedSubCat.first!.min_val)! * Int(self.txtfSqft.text!)!
            self.lblBudget.text = "\(budget) AED"
        }
        
    }
    
    @IBAction func actionCalculate(_ sender: Any) {
        self.configureEsstimationView()
    }
    
    
}
extension EstimationViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.categoryCollectionView){
            return self.categoryList.categoryList.count
        }
        else{
            return self.selectedCat.sub_categories.subCategoryList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.categoryCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
            if(self.categoryList.categoryList[indexPath.row].isSelected){
                cell.lblBorder.backgroundColor = UIColor.init(hexFromString: "00582A")
                cell.lblName.textColor = UIColor.init(hexFromString: "00582A")
            }
            else{
                cell.lblBorder.backgroundColor = .white
                cell.lblName.textColor = .black
            }
            cell.lblName.text = self.categoryList.categoryList[indexPath.row].name
            return cell
        }
            else{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
                if(self.selectedCat.sub_categories.subCategoryList[indexPath.item].isSelected){
                    cell.viewBack.backgroundColor = UIColor.init(hexFromString: "00582A")
                    cell.lblName.textColor = .white
                }
                else{
                    cell.viewBack.backgroundColor = .white
                    cell.lblName.textColor = .black
                }
            cell.lblName.text = self.selectedCat.sub_categories.subCategoryList[indexPath.row].name
        return cell
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         if(collectionView == categoryCollectionView){
          
            for cat in self.categoryList.categoryList{
                cat.isSelected = false
            }
            for subCat in self.selectedCat.sub_categories.subCategoryList{
                subCat.isSelected = false
            }
            self.categoryList.categoryList[indexPath.item].isSelected = true
            self.selectedCat = self.categoryList.categoryList[indexPath.item]
            self.collectionViewHeight.constant = CGFloat(60 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
            self.collectionView.reloadData()
            self.categoryCollectionView.reloadData()
        }
         else{
            for subCat in self.selectedCat.sub_categories.subCategoryList{
                subCat.isSelected = false
            }
            self.selectedCat.sub_categories.subCategoryList[indexPath.item].isSelected = true
            self.collectionView.reloadData()
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == self.categoryCollectionView){
            let string: NSString = NSString.init(string: self.categoryList.categoryList[indexPath.item].name)
            let size = string.size(withAttributes: nil)
            return CGSize(width: size.width + 60, height: 40)
        }
        else{
        return CGSize(width: self.collectionView.frame.width / 2, height: 55)
        }
    }
}

extension EstimationViewController{
    func getEsstiamtionData(){
        self.startActivity()
        GCD.async(.Background){
            LoginService.shared().getEsstimationData(params: [:]) { (message, success, categoryList) in
                GCD.async(.Main){
                    self.stopActivity()
                    if(success){
                        self.categoryList = categoryList!
                        if(self.categoryList.categoryList.count > 0){
                            self.selectedCat = self.categoryList.categoryList.first!
                            self.categoryList.categoryList.first!.isSelected = true
                            self.collectionViewHeight.constant = CGFloat(60 * ((self.selectedCat.sub_categories.subCategoryList.count / 2) + 1))
                            self.collectionView.reloadData()
                            self.categoryCollectionView.reloadData()
                           
                        }
                        
                    }
                    else{
                        self.showAlertView(message: message)
                    }
                }
            }
        }
    }
}




