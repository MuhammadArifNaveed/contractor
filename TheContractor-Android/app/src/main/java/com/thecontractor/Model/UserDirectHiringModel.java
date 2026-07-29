package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class UserDirectHiringModel implements Parcelable {
    private String hiring_id;
    private String hiring_status;
    private String created_at;
    private String company_id;
    private String company_name;
    private String company_phone;
    private String company_email;
    private String company_address;
    private String category_title;
    private String category_arabic_title;

    public UserDirectHiringModel() {
    }

    public UserDirectHiringModel(String hiring_id, String hiring_status, String created_at, String company_id, String company_name, String company_phone, String company_email, String company_address, String category_title, String category_arabic_title) {
        this.hiring_id = hiring_id;
        this.hiring_status = hiring_status;
        this.created_at = created_at;
        this.company_id = company_id;
        this.company_name = company_name;
        this.company_phone = company_phone;
        this.company_email = company_email;
        this.company_address = company_address;
        this.category_title = category_title;
        this.category_arabic_title = category_arabic_title;
    }

    protected UserDirectHiringModel(Parcel in) {
        hiring_id = in.readString();
        hiring_status = in.readString();
        created_at = in.readString();
        company_id = in.readString();
        company_name = in.readString();
        company_phone = in.readString();
        company_email = in.readString();
        company_address = in.readString();
        category_title = in.readString();
        category_arabic_title = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(hiring_id);
        dest.writeString(hiring_status);
        dest.writeString(created_at);
        dest.writeString(company_id);
        dest.writeString(company_name);
        dest.writeString(company_phone);
        dest.writeString(company_email);
        dest.writeString(company_address);
        dest.writeString(category_title);
        dest.writeString(category_arabic_title);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<UserDirectHiringModel> CREATOR = new Creator<UserDirectHiringModel>() {
        @Override
        public UserDirectHiringModel createFromParcel(Parcel in) {
            return new UserDirectHiringModel(in);
        }

        @Override
        public UserDirectHiringModel[] newArray(int size) {
            return new UserDirectHiringModel[size];
        }
    };

    public String getHiring_id() {
        return hiring_id;
    }

    public String getHiring_status() {
        return hiring_status;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getCompany_name() {
        return company_name;
    }

    public String getCompany_phone() {
        return company_phone;
    }

    public String getCompany_email() {
        return company_email;
    }

    public String getCompany_address() {
        return company_address;
    }

    public String getCategory_title() {
        return category_title;
    }

    public String getCategory_arabic_title() {
        return category_arabic_title;
    }
}
