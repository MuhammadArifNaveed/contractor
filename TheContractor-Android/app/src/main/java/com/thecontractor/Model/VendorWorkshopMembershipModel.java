package com.thecontractor.Model;

public class VendorWorkshopMembershipModel {
    private String id;
    private String workshop_membership_number;
    private String company_id;
    private String company_membership_id;
    private String buy_type;
    private String coupon_id;
    private String coupon_code;
    private String payment_id;
    private String reply;
    private String price;
    private String workshop_start_date;
    private String workshop_end_date;
    private String status_id;
    private String is_active;
    private String created_at;
    private String s_name;
    private String color;

    public VendorWorkshopMembershipModel(String id, String workshop_membership_number, String company_id, String company_membership_id, String buy_type, String coupon_id, String coupon_code, String payment_id, String reply, String price, String workshop_start_date, String workshop_end_date, String status_id, String is_active, String created_at, String s_name, String color) {
        this.id = id;
        this.workshop_membership_number = workshop_membership_number;
        this.company_id = company_id;
        this.company_membership_id = company_membership_id;
        this.buy_type = buy_type;
        this.coupon_id = coupon_id;
        this.coupon_code = coupon_code;
        this.payment_id = payment_id;
        this.reply = reply;
        this.price = price;
        this.workshop_start_date = workshop_start_date;
        this.workshop_end_date = workshop_end_date;
        this.status_id = status_id;
        this.is_active = is_active;
        this.created_at = created_at;
        this.s_name = s_name;
        this.color = color;
    }

    public String getId() {
        return id;
    }

    public String getWorkshop_membership_number() {
        return workshop_membership_number;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getCompany_membership_id() {
        return company_membership_id;
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

    public String getPrice() {
        return price;
    }

    public String getWorkshop_start_date() {
        return workshop_start_date;
    }

    public String getWorkshop_end_date() {
        return workshop_end_date;
    }

    public String getStatus_id() {
        return status_id;
    }

    public String getIs_active() {
        return is_active;
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
}
