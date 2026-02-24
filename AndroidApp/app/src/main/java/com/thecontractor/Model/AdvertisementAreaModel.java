package com.thecontractor.Model;

public class AdvertisementAreaModel {
    private String id;
    private String title;
    private String per_day_rate;

    public AdvertisementAreaModel(String id, String title, String per_day_rate) {
        this.id = id;
        this.title = title;
        this.per_day_rate = per_day_rate;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getPer_day_rate() {
        return per_day_rate;
    }
}
