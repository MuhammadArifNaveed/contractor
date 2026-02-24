package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class VendorDirectHiringModel implements Parcelable {
    private String hiring_id;
    private String hiring_status;
    private String created_at;
    private String name;
    private String surname;
    private String image;
    private String email;
    private String phone;
    private String address;
    private String video;
    private String category_title;
    private String category_arabic_title;

    public VendorDirectHiringModel() {
    }

    public VendorDirectHiringModel(String hiring_id, String hiring_status, String created_at, String name, String surname, String image, String email, String phone, String address, String video, String category_title, String category_arabic_title) {
        this.hiring_id = hiring_id;
        this.hiring_status = hiring_status;
        this.created_at = created_at;
        this.name = name;
        this.surname = surname;
        this.image = image;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.video = video;
        this.category_title = category_title;
        this.category_arabic_title = category_arabic_title;
    }

    protected VendorDirectHiringModel(Parcel in) {
        hiring_id = in.readString();
        hiring_status = in.readString();
        created_at = in.readString();
        name = in.readString();
        surname = in.readString();
        image = in.readString();
        email = in.readString();
        phone = in.readString();
        address = in.readString();
        video = in.readString();
        category_title = in.readString();
        category_arabic_title = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(hiring_id);
        dest.writeString(hiring_status);
        dest.writeString(created_at);
        dest.writeString(name);
        dest.writeString(surname);
        dest.writeString(image);
        dest.writeString(email);
        dest.writeString(phone);
        dest.writeString(address);
        dest.writeString(video);
        dest.writeString(category_title);
        dest.writeString(category_arabic_title);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<VendorDirectHiringModel> CREATOR = new Creator<VendorDirectHiringModel>() {
        @Override
        public VendorDirectHiringModel createFromParcel(Parcel in) {
            return new VendorDirectHiringModel(in);
        }

        @Override
        public VendorDirectHiringModel[] newArray(int size) {
            return new VendorDirectHiringModel[size];
        }
    };

    public String getHiring_id() {
        return hiring_id;
    }

    public String getHiring_status() {
        return hiring_status;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getName() {
        return name;
    }

    public String getSurname() {
        return surname;
    }

    public String getImage() {
        return image;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getAddress() {
        return address;
    }

    public String getVideo() {
        return video;
    }

    public String getCategory_title() {
        return category_title;
    }

    public String getCategory_arabic_title() {
        return category_arabic_title;
    }
}
