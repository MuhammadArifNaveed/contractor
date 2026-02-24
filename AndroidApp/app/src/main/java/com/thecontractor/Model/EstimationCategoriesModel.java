package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.ArrayList;

public class EstimationCategoriesModel{
    private String id;
    private String name;
    private String arabic_name;
    private ArrayList<EstimationSubCategoriesModel> sub_categories;

    public EstimationCategoriesModel(String id, String name, String arabic_name, ArrayList<EstimationSubCategoriesModel> sub_categories) {
        this.id = id;
        this.name = name;
        this.arabic_name = arabic_name;
        this.sub_categories = sub_categories;
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

    public ArrayList<EstimationSubCategoriesModel> getSub_categories() {
        return sub_categories;
    }
}
