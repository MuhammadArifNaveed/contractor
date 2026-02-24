package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class UserJobAppliesListingModel implements Parcelable {
    private String id;
    private String user_id;
    private String job_id;
    private String current_status;
    private String applied_at;
    private String job_uuid;
    private String company_id;
    private String title;
    private String arabic_title;
    private String description;
    private String arabic_description;
    private String vaccancies;
    private String salary;
    private String job_type;

    public UserJobAppliesListingModel() {
    }

    public UserJobAppliesListingModel(String id, String user_id, String job_id, String current_status, String applied_at, String job_uuid, String company_id, String title, String arabic_title, String description, String arabic_description, String vaccancies, String salary, String job_type) {
        this.id = id;
        this.user_id = user_id;
        this.job_id = job_id;
        this.current_status = current_status;
        this.applied_at = applied_at;
        this.job_uuid = job_uuid;
        this.company_id = company_id;
        this.title = title;
        this.arabic_title = arabic_title;
        this.description = description;
        this.arabic_description = arabic_description;
        this.vaccancies = vaccancies;
        this.salary = salary;
        this.job_type = job_type;
    }

    protected UserJobAppliesListingModel(Parcel in) {
        id = in.readString();
        user_id = in.readString();
        job_id = in.readString();
        current_status = in.readString();
        applied_at = in.readString();
        job_uuid = in.readString();
        company_id = in.readString();
        title = in.readString();
        arabic_title = in.readString();
        description = in.readString();
        arabic_description = in.readString();
        vaccancies = in.readString();
        salary = in.readString();
        job_type = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(user_id);
        dest.writeString(job_id);
        dest.writeString(current_status);
        dest.writeString(applied_at);
        dest.writeString(job_uuid);
        dest.writeString(company_id);
        dest.writeString(title);
        dest.writeString(arabic_title);
        dest.writeString(description);
        dest.writeString(arabic_description);
        dest.writeString(vaccancies);
        dest.writeString(salary);
        dest.writeString(job_type);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<UserJobAppliesListingModel> CREATOR = new Creator<UserJobAppliesListingModel>() {
        @Override
        public UserJobAppliesListingModel createFromParcel(Parcel in) {
            return new UserJobAppliesListingModel(in);
        }

        @Override
        public UserJobAppliesListingModel[] newArray(int size) {
            return new UserJobAppliesListingModel[size];
        }
    };

    public String getId() {

        return id;
    }

    public String getUser_id() {
        return user_id;
    }

    public String getJob_id() {
        return job_id;
    }

    public String getCurrent_status() {
        return current_status;
    }

    public String getApplied_at() {
        return applied_at;
    }

    public String getJob_uuid() {
        return job_uuid;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getTitle() {
        return title;
    }

    public String getArabic_title() {
        return arabic_title;
    }

    public String getDescription() {
        return description;
    }

    public String getArabic_description() {
        return arabic_description;
    }

    public String getVaccancies() {
        return vaccancies;
    }

    public String getSalary() {
        return salary;
    }

    public String getJob_type() {
        return job_type;
    }
}
