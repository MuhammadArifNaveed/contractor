package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

public class SpecialityModel implements Parcelable {
    private String id;
    private String speciality_title;
    private String speciality_title_arabic;
    private String is_active;


    public SpecialityModel(String id, String speciality_title, String speciality_title_arabic, String is_active) {
        this.id = id;
        this.speciality_title = speciality_title;
        this.speciality_title_arabic = speciality_title_arabic;
        this.is_active = is_active;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSpeciality_title() {
        return speciality_title;
    }

    public void setSpeciality_title(String speciality_title) {
        this.speciality_title = speciality_title;
    }

    public String getSpeciality_title_arabic() {
        return speciality_title_arabic;
    }

    public void setSpeciality_title_arabic(String speciality_title_arabic) {
        this.speciality_title_arabic = speciality_title_arabic;
    }

    public String getIs_active() {
        return is_active;
    }

    public void setIs_active(String is_active) {
        this.is_active = is_active;
    }

    protected SpecialityModel(Parcel in) {
        id = in.readString();
        speciality_title = in.readString();
        speciality_title_arabic = in.readString();
        is_active = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(speciality_title);
        dest.writeString(speciality_title_arabic);
        dest.writeString(is_active);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<SpecialityModel> CREATOR = new Creator<SpecialityModel>() {
        @Override
        public SpecialityModel createFromParcel(Parcel in) {
            return new SpecialityModel(in);
        }

        @Override
        public SpecialityModel[] newArray(int size) {
            return new SpecialityModel[size];
        }
    };
}
