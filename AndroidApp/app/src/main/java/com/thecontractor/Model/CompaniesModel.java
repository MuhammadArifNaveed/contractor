package com.thecontractor.Model;

import java.util.ArrayList;

public class CompaniesModel {

    private String id;
    private String company_serial_number;
    private String company_membership_number;
    private String login_email;
    private String login_password;
    private String company_code;
    private String category_id;
    private String company_name;
    private String company_phone;
    private String company_whatsapp;
    private String company_email;
    private String company_address;
    private String company_arabic_address;
    private String company_discription;
    private String company_arabic_discription;
    private String company_facebook;
    private String company_twitter;
    private String company_linkedin;
    private String company_status;
    private String company_for_24_hours;
    private String country_id;
    private String city_id;
    private String area_id;
    private String company_license;
    private String company_arabic_name;
    private String company_timing;
    private String company_employees;
    private String company_since;
    private String company_owner_name;
    private String company_owner_contact;
    private String company_owner_email;
    private String company_logo;
    private String is_verified;
    private String is_active;
    private String is_approved;
    private String is_online;
    private String is_featured;
    private String is_instalment;
    private String is_titanium;
    private String is_trusted;
    private String is_vip;
    private String sales_team_id;
    private String is_email_verified;
    private String verified_token;
    private String password_update_token;
    private String created_at;
    private String update_at;
    private String category_name;
    private String category_arabic_name;
    private String country_name;
    private String city_name;
    private String city_arabic_name;
    private String area_name;
    private String area_arabic_name;
    private String avg_rating;
    private String total_rating;
    private String review_count;
    private ArrayList<CompanyDetailSubCategoriesModel> categories;
    private ArrayList<ReviewsModel> reviews;
    private ArrayList<OpeningHoursModel> timing;

    public CompaniesModel() {
    }

    public CompaniesModel(String id, String company_serial_number, String company_membership_number, String login_email, String login_password, String company_code, String category_id, String company_name, String company_phone, String company_whatsapp, String company_email, String company_address, String company_arabic_address, String company_discription, String company_arabic_discription, String company_facebook, String company_twitter, String company_linkedin, String company_status, String company_for_24_hours, String country_id, String city_id, String area_id, String company_license, String company_arabic_name, String company_timing, String company_employees, String company_since, String company_owner_name, String company_owner_contact, String company_owner_email, String company_logo, String is_verified, String is_active, String is_approved, String is_online, String is_featured, String is_instalment, String is_titanium, String is_trusted, String is_vip, String sales_team_id, String is_email_verified, String verified_token, String password_update_token, String created_at, String update_at, String category_name, String category_arabic_name, String country_name, String city_name, String city_arabic_name, String area_name, String area_arabic_name, String avg_rating, String total_rating, String review_count, ArrayList<CompanyDetailSubCategoriesModel> categories, ArrayList<ReviewsModel> reviews, ArrayList<OpeningHoursModel> timing) {
        this.id = id;
        this.company_serial_number = company_serial_number;
        this.company_membership_number = company_membership_number;
        this.login_email = login_email;
        this.login_password = login_password;
        this.company_code = company_code;
        this.category_id = category_id;
        this.company_name = company_name;
        this.company_phone = company_phone;
        this.company_whatsapp = company_whatsapp;
        this.company_email = company_email;
        this.company_address = company_address;
        this.company_arabic_address = company_arabic_address;
        this.company_discription = company_discription;
        this.company_arabic_discription = company_arabic_discription;
        this.company_facebook = company_facebook;
        this.company_twitter = company_twitter;
        this.company_linkedin = company_linkedin;
        this.company_status = company_status;
        this.company_for_24_hours = company_for_24_hours;
        this.country_id = country_id;
        this.city_id = city_id;
        this.area_id = area_id;
        this.company_license = company_license;
        this.company_arabic_name = company_arabic_name;
        this.company_timing = company_timing;
        this.company_employees = company_employees;
        this.company_since = company_since;
        this.company_owner_name = company_owner_name;
        this.company_owner_contact = company_owner_contact;
        this.company_owner_email = company_owner_email;
        this.company_logo = company_logo;
        this.is_verified = is_verified;
        this.is_active = is_active;
        this.is_approved = is_approved;
        this.is_online = is_online;
        this.is_featured = is_featured;
        this.is_instalment = is_instalment;
        this.is_titanium = is_titanium;
        this.is_trusted = is_trusted;
        this.is_vip = is_vip;
        this.sales_team_id = sales_team_id;
        this.is_email_verified = is_email_verified;
        this.verified_token = verified_token;
        this.password_update_token = password_update_token;
        this.created_at = created_at;
        this.update_at = update_at;
        this.category_name = category_name;
        this.category_arabic_name = category_arabic_name;
        this.country_name = country_name;
        this.city_name = city_name;
        this.city_arabic_name = city_arabic_name;
        this.area_name = area_name;
        this.area_arabic_name = area_arabic_name;
        this.avg_rating = avg_rating;
        this.total_rating = total_rating;
        this.review_count = review_count;
        this.categories = categories;
        this.reviews = reviews;
        this.timing = timing;
    }

    public String getId() {
        return id;
    }

    public String getCompany_serial_number() {
        return company_serial_number;
    }

    public String getCompany_membership_number() {
        return company_membership_number;
    }

    public String getLogin_email() {
        return login_email;
    }

    public String getLogin_password() {
        return login_password;
    }

    public String getCompany_code() {
        return company_code;
    }

    public String getCategory_id() {
        return category_id;
    }

    public String getCompany_name() {
        return company_name;
    }

    public String getCompany_phone() {
        return company_phone;
    }

    public String getCompany_whatsapp() {
        return company_whatsapp;
    }

    public String getCompany_email() {
        return company_email;
    }

    public String getCompany_address() {
        return company_address;
    }

    public String getCompany_arabic_address() {
        return company_arabic_address;
    }

    public String getCompany_discription() {
        return company_discription;
    }

    public String getCompany_arabic_discription() {
        return company_arabic_discription;
    }

    public String getCompany_facebook() {
        return company_facebook;
    }

    public String getCompany_twitter() {
        return company_twitter;
    }

    public String getCompany_linkedin() {
        return company_linkedin;
    }

    public String getCompany_status() {
        return company_status;
    }

    public String getCompany_for_24_hours() {
        return company_for_24_hours;
    }

    public String getCountry_id() {
        return country_id;
    }

    public String getCity_id() {
        return city_id;
    }

    public String getArea_id() {
        return area_id;
    }

    public String getCompany_license() {
        return company_license;
    }

    public String getCompany_arabic_name() {
        return company_arabic_name;
    }

    public String getCompany_timing() {
        return company_timing;
    }

    public String getCompany_employees() {
        return company_employees;
    }

    public String getCompany_since() {
        return company_since;
    }

    public String getCompany_owner_name() {
        return company_owner_name;
    }

    public String getCompany_owner_contact() {
        return company_owner_contact;
    }

    public String getCompany_owner_email() {
        return company_owner_email;
    }

    public String getCompany_logo() {
        return company_logo;
    }

    public String getIs_verified() {
        return is_verified;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getIs_approved() {
        return is_approved;
    }

    public String getIs_online() {
        return is_online;
    }

    public String getIs_featured() {
        return is_featured;
    }

    public String getIs_instalment() {
        return is_instalment;
    }

    public String getIs_titanium() {
        return is_titanium;
    }

    public String getIs_trusted() {
        return is_trusted;
    }

    public String getIs_vip() {
        return is_vip;
    }

    public String getSales_team_id() {
        return sales_team_id;
    }

    public String getIs_email_verified() {
        return is_email_verified;
    }

    public String getVerified_token() {
        return verified_token;
    }

    public String getPassword_update_token() {
        return password_update_token;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getUpdate_at() {
        return update_at;
    }

    public String getCategory_name() {
        return category_name;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public String getCountry_name() {
        return country_name;
    }

    public String getCity_name() {
        return city_name;
    }

    public String getCity_arabic_name() {
        return city_arabic_name;
    }

    public String getArea_name() {
        return area_name;
    }

    public String getArea_arabic_name() {
        return area_arabic_name;
    }

    public String getAvg_rating() {
        return avg_rating;
    }

    public String getTotal_rating() {
        return total_rating;
    }

    public String getReview_count() {
        return review_count;
    }

    public ArrayList<CompanyDetailSubCategoriesModel> getCategories() {
        return categories;
    }

    public ArrayList<ReviewsModel> getReviews() {
        return reviews;
    }

    public ArrayList<OpeningHoursModel> getTiming() {
        return timing;
    }
}
