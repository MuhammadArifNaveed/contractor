package com.thecontractor.Model;

public class CompanyDetailSubCategoriesModel {
    private String id;
    private String name;
    private String arabic_name;

    public CompanyDetailSubCategoriesModel(String id, String name, String arabic_name) {
        this.id = id;
        this.name = name;
        this.arabic_name = arabic_name;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getArabic_name() {
        return arabic_name;
    }
}
