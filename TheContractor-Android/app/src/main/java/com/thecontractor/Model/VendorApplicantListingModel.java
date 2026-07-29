package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class VendorApplicantListingModel implements Parcelable {
    private String id;
    private String uuid;
    private String name;
    private String surname;
    private String email;
    private String phone;
    private String image;
    private String created_at;
    private String video;
    private String address;
    private String country_name;
    private String category_title;
    private String user_city_name;

    public VendorApplicantListingModel() {
    }

    public VendorApplicantListingModel(String id, String uuid, String name, String surname, String email, String phone, String image, String created_at, String video, String address, String country_name, String category_title, String user_city_name) {
        this.id = id;
        this.uuid = uuid;
        this.name = name;
        this.surname = surname;
        this.email = email;
        this.phone = phone;
        this.image = image;
        this.created_at = created_at;
        this.video = video;
        this.address = address;
        this.country_name = country_name;
        this.category_title = category_title;
        this.user_city_name = user_city_name;
    }

    protected VendorApplicantListingModel(Parcel in) {
        id = in.readString();
        uuid = in.readString();
        name = in.readString();
        surname = in.readString();
        email = in.readString();
        phone = in.readString();
        image = in.readString();
        created_at = in.readString();
        video = in.readString();
        address = in.readString();
        country_name = in.readString();
        category_title = in.readString();
        user_city_name = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(uuid);
        dest.writeString(name);
        dest.writeString(surname);
        dest.writeString(email);
        dest.writeString(phone);
        dest.writeString(image);
        dest.writeString(created_at);
        dest.writeString(video);
        dest.writeString(address);
        dest.writeString(country_name);
        dest.writeString(category_title);
        dest.writeString(user_city_name);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<VendorApplicantListingModel> CREATOR = new Creator<VendorApplicantListingModel>() {
        @Override
        public VendorApplicantListingModel createFromParcel(Parcel in) {
            return new VendorApplicantListingModel(in);
        }

        @Override
        public VendorApplicantListingModel[] newArray(int size) {
            return new VendorApplicantListingModel[size];
        }
    };

    public String getId() {
        return id;
    }

    public String getUuid() {
        return uuid;
    }

    public String getName() {
        return name;
    }

    public String getSurname() {
        return surname;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getImage() {
        return image;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getVideo() {
        return video;
    }

    public String getAddress() {
        return address;
    }

    public String getCountry_name() {
        return country_name;
    }

    public String getCategory_title() {
        return category_title;
    }

    public String getUser_city_name() {
        return user_city_name;
    }
}
