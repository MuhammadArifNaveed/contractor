package com.thecontractor.Model;

public class VendorJobCategoriesModel {
    private String id;
    private String title;
    private String arabic_title;

    public VendorJobCategoriesModel(String id, String title, String arabic_title) {
        this.id = id;
        this.title = title;
        this.arabic_title = arabic_title;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getArabic_title() {
        return arabic_title;
    }
}
