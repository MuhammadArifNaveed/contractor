package com.thecontractor.Model;

import java.util.ArrayList;

public class SelectedFreelancersDetailDatabaseModel {
    private String isHourly;
    private String fromTime;
    private String toTime;
    private String isPicked;
    private ArrayList<SelectedFreelancersDateDatabaseModel> dates;

    public SelectedFreelancersDetailDatabaseModel() {
    }

    public SelectedFreelancersDetailDatabaseModel(String isHourly, String fromTime, String toTime, String isPicked, ArrayList<SelectedFreelancersDateDatabaseModel> dates) {
        this.isHourly = isHourly;
        this.fromTime = fromTime;
        this.toTime = toTime;
        this.isPicked = isPicked;
        this.dates = dates;
    }

    public String getIsHourly() {
        return isHourly;
    }

    public void setIsHourly(String isHourly) {
        this.isHourly = isHourly;
    }

    public String getFromTime() {
        return fromTime;
    }

    public void setFromTime(String fromTime) {
        this.fromTime = fromTime;
    }

    public String getToTime() {
        return toTime;
    }

    public void setToTime(String toTime) {
        this.toTime = toTime;
    }

    public String getIsPicked() {
        return isPicked;
    }

    public void setIsPicked(String isPicked) {
        this.isPicked = isPicked;
    }

    public ArrayList<SelectedFreelancersDateDatabaseModel> getDates() {
        return dates;
    }

    public void setDates(ArrayList<SelectedFreelancersDateDatabaseModel> dates) {
        this.dates = dates;
    }
}
