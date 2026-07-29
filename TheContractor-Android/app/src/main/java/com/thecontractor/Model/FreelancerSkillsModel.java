package com.thecontractor.Model;

public class FreelancerSkillsModel {
    private String id;
    private String title;

    public FreelancerSkillsModel(String id, String title) {
        this.id = id;
        this.title = title;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }
}
