package com.thecontractor.Model;

public class AreaModel {
    private String area_id;
    private String area_name;
    private String arabic_name;

    public AreaModel(String area_id, String area_name, String arabic_name) {
        this.area_id = area_id;
        this.area_name = area_name;
        this.arabic_name = arabic_name;
    }

    public String getArea_id() {
        return area_id;
    }

    public String getArea_name() {
        return area_name;
    }

    public String getArabic_name() {
        return arabic_name;
    }
}
