package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import java.util.ArrayList;

public class FreelancerListModel implements Parcelable {
    private String id;
    private String uuid;
    private String user_id;
    private String name;
    private String email;
    private String phone;
    private String video;
    private String image;
    private String hourly_rate;
    private String availability;
    private String is_available_as_freelancer;
    private String available_per_hour;
    private String pick_up_latitude;
    private String pick_up_longitude;
    private String from_time;
    private String to_time;
    private String pick_up_address;
    private String created_at;
    private String job_category;
    private String job_category_title;
    private String city_id;
    private String city_name;
    private String area_id;
    private String area_name;
    private String bank_name;
    private String bank_address;
    private String account_title;
    private String iban;
    private ArrayList<FreelancerAddressModel> addresses;
    private ArrayList<FreelancerSkillModel> skills;

    public FreelancerListModel() {
    }

    protected FreelancerListModel(Parcel in) {
        id = in.readString();
        uuid = in.readString();
        user_id = in.readString();
        name = in.readString();
        email = in.readString();
        phone = in.readString();
        video = in.readString();
        image = in.readString();
        hourly_rate = in.readString();
        availability = in.readString();
        is_available_as_freelancer = in.readString();
        available_per_hour = in.readString();
        pick_up_latitude = in.readString();
        pick_up_longitude = in.readString();
        from_time = in.readString();
        to_time = in.readString();
        pick_up_address = in.readString();
        created_at = in.readString();
        job_category = in.readString();
        job_category_title = in.readString();
        city_id = in.readString();
        city_name = in.readString();
        area_id = in.readString();
        area_name = in.readString();
        bank_name = in.readString();
        bank_address = in.readString();
        account_title = in.readString();
        iban = in.readString();
        addresses = in.createTypedArrayList(FreelancerAddressModel.CREATOR);
        skills = in.createTypedArrayList(FreelancerSkillModel.CREATOR);
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(uuid);
        dest.writeString(user_id);
        dest.writeString(name);
        dest.writeString(email);
        dest.writeString(phone);
        dest.writeString(video);
        dest.writeString(image);
        dest.writeString(hourly_rate);
        dest.writeString(availability);
        dest.writeString(is_available_as_freelancer);
        dest.writeString(available_per_hour);
        dest.writeString(pick_up_latitude);
        dest.writeString(pick_up_longitude);
        dest.writeString(from_time);
        dest.writeString(to_time);
        dest.writeString(pick_up_address);
        dest.writeString(created_at);
        dest.writeString(job_category);
        dest.writeString(job_category_title);
        dest.writeString(city_id);
        dest.writeString(city_name);
        dest.writeString(area_id);
        dest.writeString(area_name);
        dest.writeString(bank_name);
        dest.writeString(bank_address);
        dest.writeString(account_title);
        dest.writeString(iban);
        dest.writeTypedList(addresses);
        dest.writeTypedList(skills);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<FreelancerListModel> CREATOR = new Creator<FreelancerListModel>() {
        @Override
        public FreelancerListModel createFromParcel(Parcel in) {
            return new FreelancerListModel(in);
        }

        @Override
        public FreelancerListModel[] newArray(int size) {
            return new FreelancerListModel[size];
        }
    };

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getUser_id() {
        return user_id;
    }

    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getVideo() {
        return video;
    }

    public void setVideo(String video) {
        this.video = video;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getHourly_rate() {
        return hourly_rate;
    }

    public void setHourly_rate(String hourly_rate) {
        this.hourly_rate = hourly_rate;
    }

    public String getAvailability() {
        return availability;
    }

    public void setAvailability(String availability) {
        this.availability = availability;
    }

    public String getIs_available_as_freelancer() {
        return is_available_as_freelancer;
    }

    public void setIs_available_as_freelancer(String is_available_as_freelancer) {
        this.is_available_as_freelancer = is_available_as_freelancer;
    }

    public String getAvailable_per_hour() {
        return available_per_hour;
    }

    public void setAvailable_per_hour(String available_per_hour) {
        this.available_per_hour = available_per_hour;
    }

    public String getPick_up_latitude() {
        return pick_up_latitude;
    }

    public void setPick_up_latitude(String pick_up_latitude) {
        this.pick_up_latitude = pick_up_latitude;
    }

    public String getPick_up_longitude() {
        return pick_up_longitude;
    }

    public void setPick_up_longitude(String pick_up_longitude) {
        this.pick_up_longitude = pick_up_longitude;
    }

    public String getFrom_time() {
        return from_time;
    }

    public void setFrom_time(String from_time) {
        this.from_time = from_time;
    }

    public String getTo_time() {
        return to_time;
    }

    public void setTo_time(String to_time) {
        this.to_time = to_time;
    }

    public String getPick_up_address() {
        return pick_up_address;
    }

    public void setPick_up_address(String pick_up_address) {
        this.pick_up_address = pick_up_address;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getJob_category() {
        return job_category;
    }

    public void setJob_category(String job_category) {
        this.job_category = job_category;
    }

    public String getJob_category_title() {
        return job_category_title;
    }

    public void setJob_category_title(String job_category_title) {
        this.job_category_title = job_category_title;
    }

    public String getCity_id() {
        return city_id;
    }

    public void setCity_id(String city_id) {
        this.city_id = city_id;
    }

    public String getCity_name() {
        return city_name;
    }

    public void setCity_name(String city_name) {
        this.city_name = city_name;
    }

    public String getArea_id() {
        return area_id;
    }

    public void setArea_id(String area_id) {
        this.area_id = area_id;
    }

    public String getArea_name() {
        return area_name;
    }

    public void setArea_name(String area_name) {
        this.area_name = area_name;
    }

    public String getBank_name() {
        return bank_name;
    }

    public void setBank_name(String bank_name) {
        this.bank_name = bank_name;
    }

    public String getBank_address() {
        return bank_address;
    }

    public void setBank_address(String bank_address) {
        this.bank_address = bank_address;
    }

    public String getAccount_title() {
        return account_title;
    }

    public void setAccount_title(String account_title) {
        this.account_title = account_title;
    }

    public String getIban() {
        return iban;
    }

    public void setIban(String iban) {
        this.iban = iban;
    }

    public ArrayList<FreelancerAddressModel> getAddresses() {
        return addresses;
    }

    public void setAddresses(ArrayList<FreelancerAddressModel> addresses) {
        this.addresses = addresses;
    }

    public ArrayList<FreelancerSkillModel> getSkills() {
        return skills;
    }

    public void setSkills(ArrayList<FreelancerSkillModel> skills) {
        this.skills = skills;
    }
}
