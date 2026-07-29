package com.thecontractor.Model;

import java.util.ArrayList;

public class CategoriesWithCompaniesModel {
    private String category_name;
    private String category_arabic_name;
    private ArrayList<CompaniesModel> companies;

    public CategoriesWithCompaniesModel(String category_name, String category_arabic_name, ArrayList<CompaniesModel> companies) {
        this.category_name = category_name;
        this.category_arabic_name = category_arabic_name;
        this.companies = companies;
    }

    public String getCategory_name() {
        return category_name;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public ArrayList<CompaniesModel> getCompanies() {
        return companies;
    }
}
