package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class EstimationModel{
    private String id;
    private String estimation_number;
    private String name;
    private String email;
    private String phone;
    private String looking_for;
    private String looking_for_arabic;
    private String category_name;
    private String category_name_arabic;
    private String entered_sqft;
    private String sqft_price;
    private String note;
    private String is_active;
    private String status_id;
    private String reply;
    private String created_at;
    private String status_name;
    private String status_arabic_name;
    private String status_color;
    private String acc_name;
    private String acc_surname;

    public EstimationModel() {
    }

    public EstimationModel(String id, String estimation_number, String name, String email, String phone, String looking_for, String looking_for_arabic, String category_name, String category_name_arabic, String entered_sqft, String sqft_price, String note, String is_active, String status_id, String reply, String created_at, String status_name, String status_arabic_name, String status_color, String acc_name, String acc_surname) {
        this.id = id;
        this.estimation_number = estimation_number;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.looking_for = looking_for;
        this.looking_for_arabic = looking_for_arabic;
        this.category_name = category_name;
        this.category_name_arabic = category_name_arabic;
        this.entered_sqft = entered_sqft;
        this.sqft_price = sqft_price;
        this.note = note;
        this.is_active = is_active;
        this.status_id = status_id;
        this.reply = reply;
        this.created_at = created_at;
        this.status_name = status_name;
        this.status_arabic_name = status_arabic_name;
        this.status_color = status_color;
        this.acc_name = acc_name;
        this.acc_surname = acc_surname;
    }

    public String getId() {
        return id;
    }

    public String getEstimation_number() {
        return estimation_number;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getLooking_for() {
        return looking_for;
    }

    public String getLooking_for_arabic() {
        return looking_for_arabic;
    }

    public String getCategory_name() {
        return category_name;
    }

    public String getCategory_name_arabic() {
        return category_name_arabic;
    }

    public String getEntered_sqft() {
        return entered_sqft;
    }

    public String getSqft_price() {
        return sqft_price;
    }

    public String getNote() {
        return note;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getStatus_id() {
        return status_id;
    }

    public String getReply() {
        return reply;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getStatus_name() {
        return status_name;
    }

    public String getStatus_arabic_name() {
        return status_arabic_name;
    }

    public String getStatus_color() {
        return status_color;
    }

    public String getAcc_name() {
        return acc_name;
    }

    public String getAcc_surname() {
        return acc_surname;
    }
}
