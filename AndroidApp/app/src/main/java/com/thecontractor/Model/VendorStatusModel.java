package com.thecontractor.Model;

public class VendorStatusModel {
    private String id;
    private String name;
    private String arabic_name;
    private String color;

    public VendorStatusModel(String id, String name, String arabic_name, String color) {
        this.id = id;
        this.name = name;
        this.arabic_name = arabic_name;
        this.color = color;
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

    public String getColor() {
        return color;
    }
}
