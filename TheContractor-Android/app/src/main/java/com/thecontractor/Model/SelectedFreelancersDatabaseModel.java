package com.thecontractor.Model;

import java.util.ArrayList;

public class SelectedFreelancersDatabaseModel {
    private String id;
    private String uuid;
    private String cityId;
    private String name;
    private String image;
    private String category;
    private String hourlyRate;
    private String commission;
    private String city;
    private String area;
    private String transportation_charges;
    private SelectedFreelancersDetailDatabaseModel detail;

    public SelectedFreelancersDatabaseModel() {
    }

    public SelectedFreelancersDatabaseModel(String id, String uuid, String cityId, String name, String image, String category, String hourlyRate, String commission, String city, String area, String transportation_charges, SelectedFreelancersDetailDatabaseModel detail) {
        this.id = id;
        this.uuid = uuid;
        this.cityId = cityId;
        this.name = name;
        this.image = image;
        this.category = category;
        this.hourlyRate = hourlyRate;
        this.commission = commission;
        this.city = city;
        this.area = area;
        this.transportation_charges = transportation_charges;
        this.detail = detail;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getCityId() {
        return cityId;
    }

    public void setCityId(String cityId) {
        this.cityId = cityId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getHourlyRate() {
        return hourlyRate;
    }

    public void setHourlyRate(String hourlyRate) {
        this.hourlyRate = hourlyRate;
    }

    public String getCommission() {
        return commission;
    }

    public void setCommission(String commission) {
        this.commission = commission;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getTransportation_charges() {
        return transportation_charges;
    }

    public void setTransportation_charges(String transportation_charges) {
        this.transportation_charges = transportation_charges;
    }

    public SelectedFreelancersDetailDatabaseModel getDetail() {
        return detail;
    }

    public void setDetail(SelectedFreelancersDetailDatabaseModel detail) {
        this.detail = detail;
    }
}
