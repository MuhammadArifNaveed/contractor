package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class VendorMyMembershipModel{
    private String id;
    private String membership_number;
    private String membership_id;
    private String company_id;
    private String membership_title;
    private String membership_price;
    private String top_ten_start_date;
    private String membership_top_ten_days;
    private String top_twenty_start_date;
    private String membership_top_twenty_days;
    private String membership_featured_days;
    private String membership_leads_capacity;
    private String leads_used;
    private String membership_quotations_capacity;
    private String quotations_used;
    private String workshop_price;
    private String top_ten_expiry_date;
    private String top_twenty_expiry_date;
    private String featured_expiry_date;
    private String workshop_include;
    private String membership_detail;
    private String expiry_date;
    private String expiry_days;
    private String status_id;
    private String buy_type;
    private String coupon_id;
    private String coupon_code;
    private String payment_id;
    private String reply;
    private String is_active;
    private String membership_start_datetime;
    private String created_at;
    private String s_name;
    private String color;
    private String com_id;
    private String company_name;
    private String company_phone;
    private String company_email;
    private VendorWorkshopMembershipModel workshop;


    public VendorMyMembershipModel(String id, String membership_number, String membership_id, String company_id, String membership_title, String membership_price, String top_ten_start_date, String membership_top_ten_days, String top_twenty_start_date, String membership_top_twenty_days, String membership_featured_days, String membership_leads_capacity, String leads_used, String membership_quotations_capacity, String quotations_used, String workshop_price, String top_ten_expiry_date, String top_twenty_expiry_date, String featured_expiry_date, String workshop_include, String membership_detail, String expiry_date, String expiry_days, String status_id, String buy_type, String coupon_id, String coupon_code, String payment_id, String reply, String is_active, String membership_start_datetime, String created_at, String s_name, String color, String com_id, String company_name, String company_phone, String company_email, VendorWorkshopMembershipModel workshop) {
        this.id = id;
        this.membership_number = membership_number;
        this.membership_id = membership_id;
        this.company_id = company_id;
        this.membership_title = membership_title;
        this.membership_price = membership_price;
        this.top_ten_start_date = top_ten_start_date;
        this.membership_top_ten_days = membership_top_ten_days;
        this.top_twenty_start_date = top_twenty_start_date;
        this.membership_top_twenty_days = membership_top_twenty_days;
        this.membership_featured_days = membership_featured_days;
        this.membership_leads_capacity = membership_leads_capacity;
        this.leads_used = leads_used;
        this.membership_quotations_capacity = membership_quotations_capacity;
        this.quotations_used = quotations_used;
        this.workshop_price = workshop_price;
        this.top_ten_expiry_date = top_ten_expiry_date;
        this.top_twenty_expiry_date = top_twenty_expiry_date;
        this.featured_expiry_date = featured_expiry_date;
        this.workshop_include = workshop_include;
        this.membership_detail = membership_detail;
        this.expiry_date = expiry_date;
        this.expiry_days = expiry_days;
        this.status_id = status_id;
        this.buy_type = buy_type;
        this.coupon_id = coupon_id;
        this.coupon_code = coupon_code;
        this.payment_id = payment_id;
        this.reply = reply;
        this.is_active = is_active;
        this.membership_start_datetime = membership_start_datetime;
        this.created_at = created_at;
        this.s_name = s_name;
        this.color = color;
        this.com_id = com_id;
        this.company_name = company_name;
        this.company_phone = company_phone;
        this.company_email = company_email;
        this.workshop = workshop;
    }

    public String getId() {
        return id;
    }

    public String getMembership_number() {
        return membership_number;
    }

    public String getMembership_id() {
        return membership_id;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getMembership_title() {
        return membership_title;
    }

    public String getMembership_price() {
        return membership_price;
    }

    public String getTop_ten_start_date() {
        return top_ten_start_date;
    }

    public String getMembership_top_ten_days() {
        return membership_top_ten_days;
    }

    public String getTop_twenty_start_date() {
        return top_twenty_start_date;
    }

    public String getMembership_top_twenty_days() {
        return membership_top_twenty_days;
    }

    public String getMembership_featured_days() {
        return membership_featured_days;
    }

    public String getMembership_leads_capacity() {
        return membership_leads_capacity;
    }

    public String getLeads_used() {
        return leads_used;
    }

    public String getMembership_quotations_capacity() {
        return membership_quotations_capacity;
    }

    public String getQuotations_used() {
        return quotations_used;
    }

    public String getWorkshop_price() {
        return workshop_price;
    }

    public String getTop_ten_expiry_date() {
        return top_ten_expiry_date;
    }

    public String getTop_twenty_expiry_date() {
        return top_twenty_expiry_date;
    }

    public String getFeatured_expiry_date() {
        return featured_expiry_date;
    }

    public String getWorkshop_include() {
        return workshop_include;
    }

    public String getMembership_detail() {
        return membership_detail;
    }

    public String getExpiry_date() {
        return expiry_date;
    }

    public String getExpiry_days() {
        return expiry_days;
    }

    public String getStatus_id() {
        return status_id;
    }

    public String getBuy_type() {
        return buy_type;
    }

    public String getCoupon_id() {
        return coupon_id;
    }

    public String getCoupon_code() {
        return coupon_code;
    }

    public String getPayment_id() {
        return payment_id;
    }

    public String getReply() {
        return reply;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getMembership_start_datetime() {
        return membership_start_datetime;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getS_name() {
        return s_name;
    }

    public String getColor() {
        return color;
    }

    public String getCom_id() {
        return com_id;
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

    public VendorWorkshopMembershipModel getWorkshop() {
        return workshop;
    }
}
