package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class ComplaintModel{
    private String id;
    private String complaint_id;
    private String user_id;
    private String company_id;
    private String complaint;
    private String status_id;
    private String reply;
    private String is_active;
    private String created_at;
    private String u_name;
    private String s_name;
    private String u_phone;
    private String u_email;
    private String company_logo;
    private String company_name;
    private String company_arabic_name;
    private String company_category;
    private String category_arabic_name;
    private String company_email;
    private String company_phone;
    private String company_address;
    private String company_arabic_address;
    private String status_name;
    private String status_arabic_name;
    private String status_color;

    public ComplaintModel() {
    }

    public ComplaintModel(String id, String complaint_id, String user_id, String company_id, String complaint, String status_id, String reply, String is_active, String created_at, String u_name, String s_name, String u_phone, String u_email, String company_logo, String company_name, String company_arabic_name, String company_category, String category_arabic_name, String company_email, String company_phone, String company_address, String company_arabic_address, String status_name, String status_arabic_name, String status_color) {
        this.id = id;
        this.complaint_id = complaint_id;
        this.user_id = user_id;
        this.company_id = company_id;
        this.complaint = complaint;
        this.status_id = status_id;
        this.reply = reply;
        this.is_active = is_active;
        this.created_at = created_at;
        this.u_name = u_name;
        this.s_name = s_name;
        this.u_phone = u_phone;
        this.u_email = u_email;
        this.company_logo = company_logo;
        this.company_name = company_name;
        this.company_arabic_name = company_arabic_name;
        this.company_category = company_category;
        this.category_arabic_name = category_arabic_name;
        this.company_email = company_email;
        this.company_phone = company_phone;
        this.company_address = company_address;
        this.company_arabic_address = company_arabic_address;
        this.status_name = status_name;
        this.status_arabic_name = status_arabic_name;
        this.status_color = status_color;
    }

    public String getId() {
        return id;
    }

    public String getComplaint_id() {
        return complaint_id;
    }

    public String getUser_id() {
        return user_id;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getComplaint() {
        return complaint;
    }

    public String getStatus_id() {
        return status_id;
    }

    public String getReply() {
        return reply;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getU_name() {
        return u_name;
    }

    public String getS_name() {
        return s_name;
    }

    public String getU_phone() {
        return u_phone;
    }

    public String getU_email() {
        return u_email;
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

    public String getCompany_category() {
        return company_category;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public String getCompany_email() {
        return company_email;
    }

    public String getCompany_phone() {
        return company_phone;
    }

    public String getCompany_address() {
        return company_address;
    }

    public String getCompany_arabic_address() {
        return company_arabic_address;
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
}
