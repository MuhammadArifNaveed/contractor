package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class SubCategoriesModel implements Parcelable {
    private String id;
    private String category_id;
    private String name;
    private String arabic_name;
    private String is_active;

    public SubCategoriesModel(String id, String category_id, String name, String arabic_name, String is_active) {
        this.id = id;
        this.category_id = category_id;
        this.name = name;
        this.arabic_name = arabic_name;
        this.is_active = is_active;
    }

    protected SubCategoriesModel(Parcel in) {
        id = in.readString();
        category_id = in.readString();
        name = in.readString();
        arabic_name = in.readString();
        is_active = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(category_id);
        dest.writeString(name);
        dest.writeString(arabic_name);
        dest.writeString(is_active);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<SubCategoriesModel> CREATOR = new Creator<SubCategoriesModel>() {
        @Override
        public SubCategoriesModel createFromParcel(Parcel in) {
            return new SubCategoriesModel(in);
        }

        @Override
        public SubCategoriesModel[] newArray(int size) {
            return new SubCategoriesModel[size];
        }
    };

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

    public String getIs_active() {
        return is_active;
    }
}
