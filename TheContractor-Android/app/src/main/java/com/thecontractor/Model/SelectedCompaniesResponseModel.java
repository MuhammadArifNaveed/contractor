package com.thecontractor.Model;

public class SelectedCompaniesResponseModel {

    private String company_id;
    private String date_time;
    private String location;
    private String lat;
    private String lng;
    private String description;

    public SelectedCompaniesResponseModel(String company_id, String date_time, String location, String lat, String lng, String description) {
        this.company_id = company_id;
        this.date_time = date_time;
        this.location = location;
        this.lat = lat;
        this.lng = lng;
        this.description = description;
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

    public String getLat() {
        return lat;
    }

    public String getLng() {
        return lng;
    }

    public String getDescription() {
        return description;
    }
}
