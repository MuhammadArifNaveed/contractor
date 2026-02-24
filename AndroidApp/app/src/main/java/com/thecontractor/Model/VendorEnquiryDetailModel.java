package com.thecontractor.Model;

import java.util.ArrayList;

public class VendorEnquiryDetailModel {
    private String id;
    private String enquiry_number;
    private String enquiry_id;
    private String user_id;
    private String company_id;
    private String date_time;
    private String location;
    private String description;
    private String status_id;
    private String company_membership_id;
    private String is_active;
    private String created_at;
    private String name;
    private String surname;
    private String phone;
    private String email;
    private String s_name;
    private String status_arabic_name;
    private String color;
    private ArrayList<VendorStatusModel> status;


    public String getId() {
        return id;
    }

    public String getEnquiry_number() {
        return enquiry_number;
    }

    public String getEnquiry_id() {
        return enquiry_id;
    }

    public String getUser_id() {
        return user_id;
    }

    public String getCompany_id() {
        return company_id;
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

    public String getStatus_id() {
        return status_id;
    }

    public String getCompany_membership_id() {
        return company_membership_id;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getCreated_at() {
        return created_at;
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

    public String getStatus_arabic_name() {
        return status_arabic_name;
    }

    public String getColor() {
        return color;
    }

    public ArrayList<VendorStatusModel> getStatus() {
        return status;
    }
}
