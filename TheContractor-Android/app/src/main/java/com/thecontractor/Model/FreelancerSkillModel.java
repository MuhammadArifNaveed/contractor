package com.thecontractor.Model;

import android.os.Parcel;
import android.os.Parcelable;

public class FreelancerSkillModel implements Parcelable {
    private String skill_id;
    private String skill_title;

    public FreelancerSkillModel(String skill_id, String skill_title) {
        this.skill_id = skill_id;
        this.skill_title = skill_title;
    }

    protected FreelancerSkillModel(Parcel in) {
        skill_id = in.readString();
        skill_title = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(skill_id);
        dest.writeString(skill_title);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<FreelancerSkillModel> CREATOR = new Creator<FreelancerSkillModel>() {
        @Override
        public FreelancerSkillModel createFromParcel(Parcel in) {
            return new FreelancerSkillModel(in);
        }

        @Override
        public FreelancerSkillModel[] newArray(int size) {
            return new FreelancerSkillModel[size];
        }
    };

    public String getSkill_id() {
        return skill_id;
    }

    public String getSkill_title() {
        return skill_title;
    }


}
