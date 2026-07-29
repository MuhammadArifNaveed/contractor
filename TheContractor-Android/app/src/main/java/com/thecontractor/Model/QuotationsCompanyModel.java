package com.thecontractor.Model;

import java.util.ArrayList;

public class QuotationsCompanyModel {

    private String id;
    private String quotation_id;
    private String company_id;
    private String status_id;
    private String price;
    private String payment_id;
    private String payment_date;
    private String is_active;
    private String created_at;
    private String company_name;
    private String company_arabic_name;
    private String company_address;
    private String company_arabic_address;
    private String category_name;
    private String category_arabic_name;
    private String city_name;
    private String area_name;
    private String status_name;
    private String status_arabic_name;
    private String color;
    private String document_path;


    public QuotationsCompanyModel(String id, String quotation_id, String company_id, String status_id, String price, String payment_id, String payment_date, String is_active, String created_at, String company_name, String company_arabic_name, String company_address, String company_arabic_address, String category_name, String category_arabic_name, String city_name, String area_name, String status_name, String status_arabic_name, String color, String document_path) {
        this.id = id;
        this.quotation_id = quotation_id;
        this.company_id = company_id;
        this.status_id = status_id;
        this.price = price;
        this.payment_id = payment_id;
        this.payment_date = payment_date;
        this.is_active = is_active;
        this.created_at = created_at;
        this.company_name = company_name;
        this.company_arabic_name = company_arabic_name;
        this.company_address = company_address;
        this.company_arabic_address = company_arabic_address;
        this.category_name = category_name;
        this.category_arabic_name = category_arabic_name;
        this.city_name = city_name;
        this.area_name = area_name;
        this.status_name = status_name;
        this.status_arabic_name = status_arabic_name;
        this.color = color;
        this.document_path = document_path;
    }

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

    public String getCategory_name() {
        return category_name;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public String getCity_name() {
        return city_name;
    }

    public String getArea_name() {
        return area_name;
    }

    public String getStatus_name() {
        return status_name;
    }

    public String getStatus_arabic_name() {
        return status_arabic_name;
    }

    public String getColor() {
        return color;
    }

    public String getDocument_path() {
        return document_path;
    }
}
