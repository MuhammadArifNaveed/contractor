package com.thecontractor.Model;

public class SearchJobTitleModel {
    private String job_id;
    private String name;

    public SearchJobTitleModel(String job_id, String name) {
        this.job_id = job_id;
        this.name = name;
    }

    public String getJob_id() {
        return job_id;
    }

    public String getName() {
        return name;
    }
}
