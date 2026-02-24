package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class AvailableJobListingModel implements Parcelable {
    private String id;
    private String uuid;
    private String company_name;
    private String company_arabic_name;
    private String company_logo;
    private String is_verified;
    private String company_for_24_hours;
    private String category_name;
    private String city_name;
    private String area_name;
    private String job_id;
    private String job_uuid;
    private String job_title;
    private String arabic_title;
    private String arabic_description;
    private String job_description;
    private String salary;
    private String vaccancies;
    private String job_type;
    private String amount;
    private String deadline;
    private String job_location_name;
    private String job_category_title;

    public AvailableJobListingModel() {
    }

    public AvailableJobListingModel(String id, String uuid, String company_name, String company_arabic_name, String company_logo, String is_verified, String company_for_24_hours, String category_name, String city_name, String area_name, String job_id, String job_uuid, String job_title, String arabic_title, String arabic_description, String job_description, String salary, String vaccancies, String job_type, String amount, String deadline, String job_location_name, String job_category_title) {
        this.id = id;
        this.uuid = uuid;
        this.company_name = company_name;
        this.company_arabic_name = company_arabic_name;
        this.company_logo = company_logo;
        this.is_verified = is_verified;
        this.company_for_24_hours = company_for_24_hours;
        this.category_name = category_name;
        this.city_name = city_name;
        this.area_name = area_name;
        this.job_id = job_id;
        this.job_uuid = job_uuid;
        this.job_title = job_title;
        this.arabic_title = arabic_title;
        this.arabic_description = arabic_description;
        this.job_description = job_description;
        this.salary = salary;
        this.vaccancies = vaccancies;
        this.job_type = job_type;
        this.amount = amount;
        this.deadline = deadline;
        this.job_location_name = job_location_name;
        this.job_category_title = job_category_title;
    }

    protected AvailableJobListingModel(Parcel in) {
        id = in.readString();
        uuid = in.readString();
        company_name = in.readString();
        company_arabic_name = in.readString();
        company_logo = in.readString();
        is_verified = in.readString();
        company_for_24_hours = in.readString();
        category_name = in.readString();
        city_name = in.readString();
        area_name = in.readString();
        job_id = in.readString();
        job_uuid = in.readString();
        job_title = in.readString();
        arabic_title = in.readString();
        arabic_description = in.readString();
        job_description = in.readString();
        salary = in.readString();
        vaccancies = in.readString();
        job_type = in.readString();
        amount = in.readString();
        deadline = in.readString();
        job_location_name = in.readString();
        job_category_title = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(uuid);
        dest.writeString(company_name);
        dest.writeString(company_arabic_name);
        dest.writeString(company_logo);
        dest.writeString(is_verified);
        dest.writeString(company_for_24_hours);
        dest.writeString(category_name);
        dest.writeString(city_name);
        dest.writeString(area_name);
        dest.writeString(job_id);
        dest.writeString(job_uuid);
        dest.writeString(job_title);
        dest.writeString(arabic_title);
        dest.writeString(arabic_description);
        dest.writeString(job_description);
        dest.writeString(salary);
        dest.writeString(vaccancies);
        dest.writeString(job_type);
        dest.writeString(amount);
        dest.writeString(deadline);
        dest.writeString(job_location_name);
        dest.writeString(job_category_title);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<AvailableJobListingModel> CREATOR = new Creator<AvailableJobListingModel>() {
        @Override
        public AvailableJobListingModel createFromParcel(Parcel in) {
            return new AvailableJobListingModel(in);
        }

        @Override
        public AvailableJobListingModel[] newArray(int size) {
            return new AvailableJobListingModel[size];
        }
    };

    public String getId() {
        return id;
    }

    public String getUuid() {
        return uuid;
    }

    public String getCompany_name() {
        return company_name;
    }

    public String getCompany_arabic_name() {
        return company_arabic_name;
    }

    public String getCompany_logo() {
        return company_logo;
    }

    public String getIs_verified() {
        return is_verified;
    }

    public String getCompany_for_24_hours() {
        return company_for_24_hours;
    }

    public String getCategory_name() {
        return category_name;
    }

    public String getCity_name() {
        return city_name;
    }

    public String getArea_name() {
        return area_name;
    }

    public String getJob_id() {
        return job_id;
    }

    public String getJob_uuid() {
        return job_uuid;
    }

    public String getJob_title() {
        return job_title;
    }

    public String getArabic_title() {
        return arabic_title;
    }

    public String getArabic_description() {
        return arabic_description;
    }

    public String getJob_description() {
        return job_description;
    }

    public String getSalary() {
        return salary;
    }

    public String getVaccancies() {
        return vaccancies;
    }

    public String getJob_type() {
        return job_type;
    }

    public String getAmount() {
        return amount;
    }

    public String getDeadline() {
        return deadline;
    }

    public String getJob_location_name() {
        return job_location_name;
    }

    public String getJob_category_title() {
        return job_category_title;
    }


}
