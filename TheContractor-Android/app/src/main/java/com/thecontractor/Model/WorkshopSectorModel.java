package com.thecontractor.Model;

public class WorkshopSectorModel {
    private String value;
    private String title;

    public WorkshopSectorModel(String value, String title) {
        this.value = value;
        this.title = title;
    }

    public String getValue() {
        return value;
    }

    public String getTitle() {
        return title;
    }
}
