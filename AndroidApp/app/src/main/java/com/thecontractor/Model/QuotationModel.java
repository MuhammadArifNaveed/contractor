package com.thecontractor.Model;

import java.util.ArrayList;

public class QuotationModel {
    private String id;
    private String quotation_number;
    private String category_id;
    private String sub_category_id;
    private String user_id;
    private String name;
    private String surname;
    private String phone;
    private String email;
    private String message;
    private String status_id;
    private String reply;
    private String is_active;
    private String created_at;
    private String cate_name;
    private String category_arabic_name;
    private String sub_cat_name;
    private String sub_category_arabic_name;
    private String status_name;
    private String status_arabic_name;
    private String color;
    private ArrayList<QuotationImages> images;
    private ArrayList<QuotationsCompanyModel> companies;

    public QuotationModel() {
    }

    public QuotationModel(String id, String quotation_number, String category_id, String sub_category_id, String user_id, String name, String surname, String phone, String email, String message, String status_id, String reply, String is_active, String created_at, String cate_name, String category_arabic_name, String sub_cat_name, String sub_category_arabic_name, String status_name, String status_arabic_name, String color, ArrayList<QuotationImages> images, ArrayList<QuotationsCompanyModel> companies) {
        this.id = id;
        this.quotation_number = quotation_number;
        this.category_id = category_id;
        this.sub_category_id = sub_category_id;
        this.user_id = user_id;
        this.name = name;
        this.surname = surname;
        this.phone = phone;
        this.email = email;
        this.message = message;
        this.status_id = status_id;
        this.reply = reply;
        this.is_active = is_active;
        this.created_at = created_at;
        this.cate_name = cate_name;
        this.category_arabic_name = category_arabic_name;
        this.sub_cat_name = sub_cat_name;
        this.sub_category_arabic_name = sub_category_arabic_name;
        this.status_name = status_name;
        this.status_arabic_name = status_arabic_name;
        this.color = color;
        this.images = images;
        this.companies = companies;
    }

    public String getId() {
        return id;
    }

    public String getQuotation_number() {
        return quotation_number;
    }

    public String getCategory_id() {
        return category_id;
    }

    public String getSub_category_id() {
        return sub_category_id;
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

    public String getCate_name() {
        return cate_name;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public String getSub_cat_name() {
        return sub_cat_name;
    }

    public String getSub_category_arabic_name() {
        return sub_category_arabic_name;
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

    public ArrayList<QuotationImages> getImages() {
        return images;
    }

    public ArrayList<QuotationsCompanyModel> getCompanies() {
        return companies;
    }
}
