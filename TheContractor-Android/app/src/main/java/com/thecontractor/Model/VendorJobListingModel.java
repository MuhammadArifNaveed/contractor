package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

public class VendorJobListingModel implements Parcelable {
    private String id;
    private String job_uuid;
    private String title;
    private String arabic_title;
    private String description;
    private String arabic_description;
    private String vaccancies;
    private String salary;
    private String job_type;
    private String job_location;
    private String loaction_name;
    private String loaction_arabic_name;
    private String job_category;
    private String job_category_name;
    private String job_category_arabic_name;
    private String status;
    private String approved;
    private String advertisement;
    private String deadline;
    private String created_at;
    private String amount;
    private String payment_status;
    private String application_count;

    public VendorJobListingModel() {
    }

    public VendorJobListingModel(String id, String job_uuid, String title, String arabic_title, String description, String arabic_description, String vaccancies, String salary, String job_type, String job_location, String loaction_name, String loaction_arabic_name, String job_category, String job_category_name, String job_category_arabic_name, String status, String approved, String advertisement, String deadline, String created_at, String amount, String payment_status, String application_count) {
        this.id = id;
        this.job_uuid = job_uuid;
        this.title = title;
        this.arabic_title = arabic_title;
        this.description = description;
        this.arabic_description = arabic_description;
        this.vaccancies = vaccancies;
        this.salary = salary;
        this.job_type = job_type;
        this.job_location = job_location;
        this.loaction_name = loaction_name;
        this.loaction_arabic_name = loaction_arabic_name;
        this.job_category = job_category;
        this.job_category_name = job_category_name;
        this.job_category_arabic_name = job_category_arabic_name;
        this.status = status;
        this.approved = approved;
        this.advertisement = advertisement;
        this.deadline = deadline;
        this.created_at = created_at;
        this.amount = amount;
        this.payment_status = payment_status;
        this.application_count = application_count;
    }

    protected VendorJobListingModel(Parcel in) {
        id = in.readString();
        job_uuid = in.readString();
        title = in.readString();
        arabic_title = in.readString();
        description = in.readString();
        arabic_description = in.readString();
        vaccancies = in.readString();
        salary = in.readString();
        job_type = in.readString();
        job_location = in.readString();
        loaction_name = in.readString();
        loaction_arabic_name = in.readString();
        job_category = in.readString();
        job_category_name = in.readString();
        job_category_arabic_name = in.readString();
        status = in.readString();
        approved = in.readString();
        advertisement = in.readString();
        deadline = in.readString();
        created_at = in.readString();
        amount = in.readString();
        payment_status = in.readString();
        application_count = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(job_uuid);
        dest.writeString(title);
        dest.writeString(arabic_title);
        dest.writeString(description);
        dest.writeString(arabic_description);
        dest.writeString(vaccancies);
        dest.writeString(salary);
        dest.writeString(job_type);
        dest.writeString(job_location);
        dest.writeString(loaction_name);
        dest.writeString(loaction_arabic_name);
        dest.writeString(job_category);
        dest.writeString(job_category_name);
        dest.writeString(job_category_arabic_name);
        dest.writeString(status);
        dest.writeString(approved);
        dest.writeString(advertisement);
        dest.writeString(deadline);
        dest.writeString(created_at);
        dest.writeString(amount);
        dest.writeString(payment_status);
        dest.writeString(application_count);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<VendorJobListingModel> CREATOR = new Creator<VendorJobListingModel>() {
        @Override
        public VendorJobListingModel createFromParcel(Parcel in) {
            return new VendorJobListingModel(in);
        }

        @Override
        public VendorJobListingModel[] newArray(int size) {
            return new VendorJobListingModel[size];
        }
    };

    public String getId() {
        return id;
    }

    public String getJob_uuid() {
        return job_uuid;
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

    public String getJob_location() {
        return job_location;
    }

    public String getLoaction_name() {
        return loaction_name;
    }

    public String getLoaction_arabic_name() {
        return loaction_arabic_name;
    }

    public String getJob_category() {
        return job_category;
    }

    public String getJob_category_name() {
        return job_category_name;
    }

    public String getJob_category_arabic_name() {
        return job_category_arabic_name;
    }

    public String getStatus() {
        return status;
    }

    public String getApproved() {
        return approved;
    }

    public String getAdvertisement() {
        return advertisement;
    }

    public String getDeadline() {
        return deadline;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getAmount() {
        return amount;
    }

    public String getPayment_status() {
        return payment_status;
    }

    public String getApplication_count() {
        return application_count;
    }
}
