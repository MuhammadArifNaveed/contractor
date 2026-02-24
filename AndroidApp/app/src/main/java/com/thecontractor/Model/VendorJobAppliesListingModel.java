package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class VendorJobAppliesListingModel implements Parcelable {
    private String id;
    private String user_id;
    private String job_id;
    private String current_status;
    private String applied_at;
    private String users_user_id;
    private String users_uuid;
    private String users_user_name;
    private String users_user_sur_name;
    private String users_user_phone;
    private String users_user_email;
    private String users_user_address;
    private String users_user_image;


    public VendorJobAppliesListingModel() {
    }

    public VendorJobAppliesListingModel(String id, String user_id, String job_id, String current_status, String applied_at, String users_user_id, String users_uuid, String users_user_name, String users_user_sur_name, String users_user_phone, String users_user_email, String users_user_address, String users_user_image) {
        this.id = id;
        this.user_id = user_id;
        this.job_id = job_id;
        this.current_status = current_status;
        this.applied_at = applied_at;
        this.users_user_id = users_user_id;
        this.users_uuid = users_uuid;
        this.users_user_name = users_user_name;
        this.users_user_sur_name = users_user_sur_name;
        this.users_user_phone = users_user_phone;
        this.users_user_email = users_user_email;
        this.users_user_address = users_user_address;
        this.users_user_image = users_user_image;
    }

    protected VendorJobAppliesListingModel(Parcel in) {
        id = in.readString();
        user_id = in.readString();
        job_id = in.readString();
        current_status = in.readString();
        applied_at = in.readString();
        users_user_id = in.readString();
        users_uuid = in.readString();
        users_user_name = in.readString();
        users_user_sur_name = in.readString();
        users_user_phone = in.readString();
        users_user_email = in.readString();
        users_user_address = in.readString();
        users_user_image = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(user_id);
        dest.writeString(job_id);
        dest.writeString(current_status);
        dest.writeString(applied_at);
        dest.writeString(users_user_id);
        dest.writeString(users_uuid);
        dest.writeString(users_user_name);
        dest.writeString(users_user_sur_name);
        dest.writeString(users_user_phone);
        dest.writeString(users_user_email);
        dest.writeString(users_user_address);
        dest.writeString(users_user_image);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<VendorJobAppliesListingModel> CREATOR = new Creator<VendorJobAppliesListingModel>() {
        @Override
        public VendorJobAppliesListingModel createFromParcel(Parcel in) {
            return new VendorJobAppliesListingModel(in);
        }

        @Override
        public VendorJobAppliesListingModel[] newArray(int size) {
            return new VendorJobAppliesListingModel[size];
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

    public String getUsers_user_id() {
        return users_user_id;
    }

    public String getUsers_uuid() {
        return users_uuid;
    }

    public String getUsers_user_name() {
        return users_user_name;
    }

    public String getUsers_user_sur_name() {
        return users_user_sur_name;
    }

    public String getUsers_user_phone() {
        return users_user_phone;
    }

    public String getUsers_user_email() {
        return users_user_email;
    }

    public String getUsers_user_address() {
        return users_user_address;
    }

    public String getUsers_user_image() {
        return users_user_image;
    }
}
