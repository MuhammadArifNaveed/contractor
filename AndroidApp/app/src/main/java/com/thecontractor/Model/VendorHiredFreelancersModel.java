package com.thecontractor.Model;

import java.util.ArrayList;

public class VendorHiredFreelancersModel {
    private String name;
    private String email;
    private String phone;
    private String image;
    private String hourly_rate;
    private String hourly;
    private String from_time;
    private String to_time;
    private String picked;
    private String status;
    private String created_at;
    private String expired;
    private String details_id;
    private ArrayList<FreelancerSkillModel> skills;
    private ArrayList<DateModel> dates;

    public VendorHiredFreelancersModel() {
    }

    public VendorHiredFreelancersModel(String name, String email, String phone, String image, String hourly_rate, String hourly, String from_time, String to_time, String picked, String status, String created_at, String expired, String details_id, ArrayList<FreelancerSkillModel> skills, ArrayList<DateModel> dates) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.image = image;
        this.hourly_rate = hourly_rate;
        this.hourly = hourly;
        this.from_time = from_time;
        this.to_time = to_time;
        this.picked = picked;
        this.status = status;
        this.created_at = created_at;
        this.expired = expired;
        this.details_id = details_id;
        this.skills = skills;
        this.dates = dates;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getImage() {
        return image;
    }

    public String getHourly_rate() {
        return hourly_rate;
    }

    public String getHourly() {
        return hourly;
    }

    public String getFrom_time() {
        return from_time;
    }

    public String getTo_time() {
        return to_time;
    }

    public String getPicked() {
        return picked;
    }

    public String getStatus() {
        return status;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getExpired() {
        return expired;
    }

    public String getDetails_id() {
        return details_id;
    }

    public ArrayList<FreelancerSkillModel> getSkills() {
        return skills;
    }

    public ArrayList<DateModel> getDates() {
        return dates;
    }

    public class DateModel {
        private String date;

        public String getDate() {
            return date;
        }
    }
}
