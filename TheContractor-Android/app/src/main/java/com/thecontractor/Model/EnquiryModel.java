package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class EnquiryModel {
    private String id;
    private String date_time;
    private String location;
    private String description;
    private String user_id;
    private String company_id;
    private String company_logo;
    private String company_name;
    private String company_arabic_name;
    private String company_address;
    private String company_arabic_address;
    private String company_phone;
    private String company_whatsapp_phone;
    private String company_email;
    private String s_id;
    private String s_name;
    private String s_arabic_name;
    private String s_color;
    private String name;
    private String surname;
    private String phone;
    private String email;
    private String created_at;
    private String category_name;
    private String category_arabic_name;
    private String reason;

    public EnquiryModel() {
    }

    public EnquiryModel(String id, String date_time, String location, String description, String user_id, String company_id, String company_logo, String company_name, String company_arabic_name, String company_address, String company_arabic_address, String company_phone, String company_whatsapp_phone, String company_email, String s_id, String s_name, String s_arabic_name, String s_color, String name, String surname, String phone, String email, String created_at, String category_name, String category_arabic_name, String reason) {
        this.id = id;
        this.date_time = date_time;
        this.location = location;
        this.description = description;
        this.user_id = user_id;
        this.company_id = company_id;
        this.company_logo = company_logo;
        this.company_name = company_name;
        this.company_arabic_name = company_arabic_name;
        this.company_address = company_address;
        this.company_arabic_address = company_arabic_address;
        this.company_phone = company_phone;
        this.company_whatsapp_phone = company_whatsapp_phone;
        this.company_email = company_email;
        this.s_id = s_id;
        this.s_name = s_name;
        this.s_arabic_name = s_arabic_name;
        this.s_color = s_color;
        this.name = name;
        this.surname = surname;
        this.phone = phone;
        this.email = email;
        this.created_at = created_at;
        this.category_name = category_name;
        this.category_arabic_name = category_arabic_name;
        this.reason = reason;
    }

    public String getId() {
        return id;
    }

    public String getDate_time() {
        return date_time;
    }

    public String getLocation() {
        return location;
    }

    public String getDescription() {
        return description;
    }

    public String getUser_id() {
        return user_id;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getCompany_logo() {
        return company_logo;
    }

    public String getCompany_name() {
        return company_name;
    }

    public String getCompany_arabic_name() {
        return company_arabic_name;
    }

    public String getCompany_address() {
        return company_address;
    }

    public String getCompany_arabic_address() {
        return company_arabic_address;
    }

    public String getCompany_phone() {
        return company_phone;
    }

    public String getCompany_whatsapp_phone() {
        return company_whatsapp_phone;
    }

    public String getCompany_email() {
        return company_email;
    }

    public String getS_id() {
        return s_id;
    }

    public String getS_name() {
        return s_name;
    }

    public String getS_arabic_name() {
        return s_arabic_name;
    }

    public String getS_color() {
        return s_color;
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

    public String getCreated_at() {
        return created_at;
    }

    public String getCategory_name() {
        return category_name;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public String getReason() {
        return reason;
    }
}
