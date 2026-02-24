package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

public class FreelancerAddressModel implements Parcelable {
    private String freelancer_details_id;
    private String id;
    private String address;
    private String pick_up_address;
    private String pick_up_latitude;
    private String pick_up_longitude;
    private String status;


    public FreelancerAddressModel() {
    }

    public FreelancerAddressModel(String freelancer_details_id, String id, String address, String pick_up_address, String pick_up_latitude, String pick_up_longitude, String status) {
        this.freelancer_details_id = freelancer_details_id;
        this.id = id;
        this.address = address;
        this.pick_up_address = pick_up_address;
        this.pick_up_latitude = pick_up_latitude;
        this.pick_up_longitude = pick_up_longitude;
        this.status = status;
    }

    protected FreelancerAddressModel(Parcel in) {
        freelancer_details_id = in.readString();
        id = in.readString();
        address = in.readString();
        pick_up_address = in.readString();
        pick_up_latitude = in.readString();
        pick_up_longitude = in.readString();
        status = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(freelancer_details_id);
        dest.writeString(id);
        dest.writeString(address);
        dest.writeString(pick_up_address);
        dest.writeString(pick_up_latitude);
        dest.writeString(pick_up_longitude);
        dest.writeString(status);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<FreelancerAddressModel> CREATOR = new Creator<FreelancerAddressModel>() {
        @Override
        public FreelancerAddressModel createFromParcel(Parcel in) {
            return new FreelancerAddressModel(in);
        }

        @Override
        public FreelancerAddressModel[] newArray(int size) {
            return new FreelancerAddressModel[size];
        }
    };

    public String getFreelancer_details_id() {
        return freelancer_details_id;
    }

    public String getId() {
        return id;
    }

    public String getAddress() {
        return address;
    }

    public String getPick_up_address() {
        return pick_up_address;
    }

    public String getPick_up_latitude() {
        return pick_up_latitude;
    }

    public String getPick_up_longitude() {
        return pick_up_longitude;
    }

    public String getStatus() {
        return status;
    }
}
