package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.ArrayList;

public class CategoriesModel implements Parcelable {
    private String id;
    private String name;
    private String arabic_name;
    private String icon;
    private ArrayList<SubCategoriesModel> sub_categories;

    public CategoriesModel(String id, String name, String arabic_name, String icon, ArrayList<SubCategoriesModel> sub_categories) {
        this.id = id;
        this.name = name;
        this.arabic_name = arabic_name;
        this.icon = icon;
        this.sub_categories = sub_categories;
    }

    protected CategoriesModel(Parcel in) {
        id = in.readString();
        name = in.readString();
        arabic_name = in.readString();
        icon = in.readString();
        sub_categories = in.createTypedArrayList(SubCategoriesModel.CREATOR);
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(name);
        dest.writeString(arabic_name);
        dest.writeString(icon);
        dest.writeTypedList(sub_categories);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<CategoriesModel> CREATOR = new Creator<CategoriesModel>() {
        @Override
        public CategoriesModel createFromParcel(Parcel in) {
            return new CategoriesModel(in);
        }

        @Override
        public CategoriesModel[] newArray(int size) {
            return new CategoriesModel[size];
        }
    };

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getArabic_name() {
        return arabic_name;
    }

    public String getIcon() {
        return icon;
    }

    public ArrayList<SubCategoriesModel> getSub_categories() {
        return sub_categories;
    }
}
