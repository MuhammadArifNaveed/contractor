package com.thecontractor.Model;

public class VendorMembershipModel {
    private String id;
    private String title;
    private String days;
    private String top_ten_days;
    private String top_twenty_days;
    private String featured_days;
    private String leads_capacity;
    private String quotations_capacity;
    private String customer_support;
    private String authentication_certificate;
    private String listing_in_24;
    private String welcome_kit;
    private String workshop_price;
    private String price;
    private String details;
    private String is_active;
    private String created_at;
    private String buy_type;
    private String buy_value;
    private String status_id;
    private String status_name;
    private String status_arabic_name;
    private String color;

    public VendorMembershipModel(String id, String title, String days, String top_ten_days, String top_twenty_days, String featured_days, String leads_capacity, String quotations_capacity, String customer_support, String authentication_certificate, String listing_in_24, String welcome_kit, String workshop_price, String price, String details, String is_active, String created_at, String buy_type, String buy_value, String status_id, String status_name, String status_arabic_name, String color) {
        this.id = id;
        this.title = title;
        this.days = days;
        this.top_ten_days = top_ten_days;
        this.top_twenty_days = top_twenty_days;
        this.featured_days = featured_days;
        this.leads_capacity = leads_capacity;
        this.quotations_capacity = quotations_capacity;
        this.customer_support = customer_support;
        this.authentication_certificate = authentication_certificate;
        this.listing_in_24 = listing_in_24;
        this.welcome_kit = welcome_kit;
        this.workshop_price = workshop_price;
        this.price = price;
        this.details = details;
        this.is_active = is_active;
        this.created_at = created_at;
        this.buy_type = buy_type;
        this.buy_value = buy_value;
        this.status_id = status_id;
        this.status_name = status_name;
        this.status_arabic_name = status_arabic_name;
        this.color = color;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDays() {
        return days;
    }

    public String getTop_ten_days() {
        return top_ten_days;
    }

    public String getTop_twenty_days() {
        return top_twenty_days;
    }

    public String getFeatured_days() {
        return featured_days;
    }

    public String getLeads_capacity() {
        return leads_capacity;
    }

    public String getQuotations_capacity() {
        return quotations_capacity;
    }

    public String getCustomer_support() {
        return customer_support;
    }

    public String getAuthentication_certificate() {
        return authentication_certificate;
    }

    public String getListing_in_24() {
        return listing_in_24;
    }

    public String getWelcome_kit() {
        return welcome_kit;
    }

    public String getWorkshop_price() {
        return workshop_price;
    }

    public String getPrice() {
        return price;
    }

    public String getDetails() {
        return details;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getBuy_type() {
        return buy_type;
    }

    public String getBuy_value() {
        return buy_value;
    }

    public String getStatus_id() {
        return status_id;
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
}
