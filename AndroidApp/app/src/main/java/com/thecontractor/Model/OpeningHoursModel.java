package com.thecontractor.Model;

public class OpeningHoursModel {
    private String id;
    private String company_id;
    private String name;
    private String arabic_name;
    private String status;
    private String open_time;
    private String close_time;

    public OpeningHoursModel(String id, String company_id, String name, String arabic_name, String status, String open_time, String close_time) {
        this.id = id;
        this.company_id = company_id;
        this.name = name;
        this.arabic_name = arabic_name;
        this.status = status;
        this.open_time = open_time;
        this.close_time = close_time;
    }

    public String getId() {
        return id;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getName() {
        return name;
    }

    public String getArabic_name() {
        return arabic_name;
    }

    public String getStatus() {
        return status;
    }

    public String getOpen_time() {
        return open_time;
    }

    public String getClose_time() {
        return close_time;
    }
}
