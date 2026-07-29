package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class VendorDashboardCountModel implements Parcelable {
    private String id;
    private String name;
    private String count;

    public VendorDashboardCountModel(String id, String name, String count) {
        this.id = id;
        this.name = name;
        this.count = count;
    }

    protected VendorDashboardCountModel(Parcel in) {
        id = in.readString();
        name = in.readString();
        count = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(name);
        dest.writeString(count);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<VendorDashboardCountModel> CREATOR = new Creator<VendorDashboardCountModel>() {
        @Override
        public VendorDashboardCountModel createFromParcel(Parcel in) {
            return new VendorDashboardCountModel(in);
        }

        @Override
        public VendorDashboardCountModel[] newArray(int size) {
            return new VendorDashboardCountModel[size];
        }
    };

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getCount() {
        return count;
    }
}
