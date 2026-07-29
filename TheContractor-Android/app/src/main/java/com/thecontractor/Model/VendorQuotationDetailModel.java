package com.thecontractor.Model;

import java.util.ArrayList;

public class VendorQuotationDetailModel {
    private String id;
    private String quotation_id;
    private String company_id;
    private String status_id;
    private String price;
    private String payment_id;
    private String payment_date;
    private String is_active;
    private String created_at;
    private String quo_id;
    private String quotation_number;
    private String user_id;
    private String name;
    private String surname;
    private String phone;
    private String email;
    private String message;
    private String cate_name;
    private String arabic_cate_name;
    private String sub_cat_name;
    private String arabic_sub_cat_name;
    private String company_name;
    private String company_arabic_name;
    private String company_phone;
    private String company_email;
    private String company_address;
    private String city_name;
    private String arabic_city_name;
    private String area_name;
    private String arabic_area_name;
    private String status_name;
    private String arabic_status_name;
    private String color;
    private ArrayList<QuotationImages> images;
    private ArrayList<VendorStatusModel> status;


    public String getId() {
        return id;
    }

    public String getQuotation_id() {
        return quotation_id;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getStatus_id() {
        return status_id;
    }

    public String getPrice() {
        return price;
    }

    public String getPayment_id() {
        return payment_id;
    }

    public String getPayment_date() {
        return payment_date;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getQuo_id() {
        return quo_id;
    }

    public String getQuotation_number() {
        return quotation_number;
    }

    public String getUser_id() {
        return user_id;
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

    public String getMessage() {
        return message;
    }

    public String getCate_name() {
        return cate_name;
    }

    public String getArabic_cate_name() {
        return arabic_cate_name;
    }

    public String getSub_cat_name() {
        return sub_cat_name;
    }

    public String getArabic_sub_cat_name() {
        return arabic_sub_cat_name;
    }

    public String getCompany_name() {
        return company_name;
    }

    public String getCompany_arabic_name() {
        return company_arabic_name;
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

    public String getCity_name() {
        return city_name;
    }

    public String getArabic_city_name() {
        return arabic_city_name;
    }

    public String getArea_name() {
        return area_name;
    }

    public String getArabic_area_name() {
        return arabic_area_name;
    }

    public String getStatus_name() {
        return status_name;
    }

    public String getArabic_status_name() {
        return arabic_status_name;
    }

    public String getColor() {
        return color;
    }

    public ArrayList<QuotationImages> getImages() {
        return images;
    }

    public ArrayList<VendorStatusModel> getStatus() {
        return status;
    }
}
