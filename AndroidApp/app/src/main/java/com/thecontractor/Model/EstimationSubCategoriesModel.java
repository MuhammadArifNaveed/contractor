package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class EstimationSubCategoriesModel{
    private String id;
    private String category_id;
    private String name;
    private String arabic_name;
    private String min_val;
    private String is_active;

    public EstimationSubCategoriesModel(String id, String category_id, String name, String arabic_name, String min_val, String is_active) {
        this.id = id;
        this.category_id = category_id;
        this.name = name;
        this.arabic_name = arabic_name;
        this.min_val = min_val;
        this.is_active = is_active;
    }

    public String getId() {
        return id;
    }

    public String getCategory_id() {
        return category_id;
    }

    public String getName() {
        return name;
    }

    public String getArabic_name() {
        return arabic_name;
    }

    public String getMin_val() {
        return min_val;
    }

    public String getIs_active() {
        return is_active;
    }
}
