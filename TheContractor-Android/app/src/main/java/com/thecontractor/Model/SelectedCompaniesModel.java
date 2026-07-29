package com.thecontractor.Model;

import java.util.ArrayList;

public class SelectedCompaniesModel {

    private String id;
    private String company_name;
    private String company_arabic_name;
    private String company_logo;
    private String category_name;
    private String category_arabic_name;
    private String review_count;
    private String avg_rating;
    private String is_verified;
    private String date_time;
    private String location;
    private String lat;
    private String lng;
    private String description;

    public SelectedCompaniesModel(String id, String company_name, String company_arabic_name, String company_logo, String category_name, String category_arabic_name, String review_count, String avg_rating, String is_verified, String date_time, String location, String lat, String lng, String description) {
        this.id = id;
        this.company_name = company_name;
        this.company_arabic_name = company_arabic_name;
        this.company_logo = company_logo;
        this.category_name = category_name;
        this.category_arabic_name = category_arabic_name;
        this.review_count = review_count;
        this.avg_rating = avg_rating;
        this.is_verified = is_verified;
        this.date_time = date_time;
        this.location = location;
        this.lat = lat;
        this.lng = lng;
        this.description = description;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCompany_name() {
        return company_name;
    }

    public void setCompany_name(String company_name) {
        this.company_name = company_name;
    }

    public String getCompany_arabic_name() {
        return company_arabic_name;
    }

    public void setCompany_arabic_name(String company_arabic_name) {
        this.company_arabic_name = company_arabic_name;
    }

    public String getCompany_logo() {
        return company_logo;
    }

    public void setCompany_logo(String company_logo) {
        this.company_logo = company_logo;
    }

    public String getCategory_name() {
        return category_name;
    }

    public void setCategory_name(String category_name) {
        this.category_name = category_name;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public void setCategory_arabic_name(String category_arabic_name) {
        this.category_arabic_name = category_arabic_name;
    }

    public String getReview_count() {
        return review_count;
    }

    public void setReview_count(String review_count) {
        this.review_count = review_count;
    }

    public String getAvg_rating() {
        return avg_rating;
    }

    public void setAvg_rating(String avg_rating) {
        this.avg_rating = avg_rating;
    }

    public String getIs_verified() {
        return is_verified;
    }

    public void setIs_verified(String is_verified) {
        this.is_verified = is_verified;
    }

    public String getDate_time() {
        return date_time;
    }

    public void setDate_time(String date_time) {
        this.date_time = date_time;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getLat() {
        return lat;
    }

    public void setLat(String lat) {
        this.lat = lat;
    }

    public String getLng() {
        return lng;
    }

    public void setLng(String lng) {
        this.lng = lng;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
