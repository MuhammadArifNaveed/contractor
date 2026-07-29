package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class VendorRatingModel implements Parcelable {
    private String id;
    private String enquiry_company_id;
    private String user_id;
    private String company_id;
    private String rating;
    private String review;
    private String created_at;
    private String enq_com_id;
    private String app_date_time;
    private String location;
    private String name;
    private String surname;
    private String phone;
    private String email;
    private String s_name;
    private String color;

    public VendorRatingModel(String id, String enquiry_company_id, String user_id, String company_id, String rating, String review, String created_at, String enq_com_id, String app_date_time, String location, String name, String surname, String phone, String email, String s_name, String color) {
        this.id = id;
        this.enquiry_company_id = enquiry_company_id;
        this.user_id = user_id;
        this.company_id = company_id;
        this.rating = rating;
        this.review = review;
        this.created_at = created_at;
        this.enq_com_id = enq_com_id;
        this.app_date_time = app_date_time;
        this.location = location;
        this.name = name;
        this.surname = surname;
        this.phone = phone;
        this.email = email;
        this.s_name = s_name;
        this.color = color;
    }

    protected VendorRatingModel(Parcel in) {
        id = in.readString();
        enquiry_company_id = in.readString();
        user_id = in.readString();
        company_id = in.readString();
        rating = in.readString();
        review = in.readString();
        created_at = in.readString();
        enq_com_id = in.readString();
        app_date_time = in.readString();
        location = in.readString();
        name = in.readString();
        surname = in.readString();
        phone = in.readString();
        email = in.readString();
        s_name = in.readString();
        color = in.readString();
    }

    public static final Creator<VendorRatingModel> CREATOR = new Creator<VendorRatingModel>() {
        @Override
        public VendorRatingModel createFromParcel(Parcel in) {
            return new VendorRatingModel(in);
        }

        @Override
        public VendorRatingModel[] newArray(int size) {
            return new VendorRatingModel[size];
        }
    };

    public String getId() {
        return id;
    }

    public String getEnquiry_company_id() {
        return enquiry_company_id;
    }

    public String getUser_id() {
        return user_id;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getRating() {
        return rating;
    }

    public String getReview() {
        return review;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getEnq_com_id() {
        return enq_com_id;
    }

    public String getApp_date_time() {
        return app_date_time;
    }

    public String getLocation() {
        return location;
    }

    public String getName() {
        return name;
    }

    public String getSurname() {
        return surname;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }

    public String getS_name() {
        return s_name;
    }

    public String getColor() {
        return color;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(enquiry_company_id);
        dest.writeString(user_id);
        dest.writeString(company_id);
        dest.writeString(rating);
        dest.writeString(review);
        dest.writeString(created_at);
        dest.writeString(enq_com_id);
        dest.writeString(app_date_time);
        dest.writeString(location);
        dest.writeString(name);
        dest.writeString(surname);
        dest.writeString(phone);
        dest.writeString(email);
        dest.writeString(s_name);
        dest.writeString(color);
    }
}
