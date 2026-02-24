package com.thecontractor.Model;

import java.time.LocalDate;
import java.util.Calendar;

public class SelectedFreelancerDateRateModel {
    private Calendar calendar;
    private double hours;
    private double rate;

    public SelectedFreelancerDateRateModel(Calendar calendar, double hours, double rate) {
        this.calendar = calendar;
        this.hours = hours;
        this.rate = rate;
    }

    public Calendar getCalendar() {
        return calendar;
    }

    public double getHours() {
        return hours;
    }

    public double getRate() {
        return rate;
    }

    public double getTotal() {
        return hours * rate;
    }
}
