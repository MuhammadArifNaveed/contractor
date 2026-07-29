package com.thecontractor.Model;

import java.util.ArrayList;

public class VendorJobCitiesModel {
    private String id;
    private String name;
    private String arabic_name;
    private ArrayList<AreaModel> areas;

    public VendorJobCitiesModel(String id, String name, String arabic_name, ArrayList<AreaModel> areas) {
        this.id = id;
        this.name = name;
        this.arabic_name = arabic_name;
        this.areas = areas;
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

    public ArrayList<AreaModel> getAreas() {
        return areas;
    }
}
