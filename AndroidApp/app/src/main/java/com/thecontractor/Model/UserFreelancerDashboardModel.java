package com.thecontractor.Model;

import java.util.ArrayList;

public class UserFreelancerDashboardModel {
    private String is_available_as_freelance;
    private String wallet_balance;
    private ArrayList<VendorDashboardCountModel> as_freelancer;
    private ArrayList<VendorDashboardCountModel> as_boss_details;

    public String getIs_available_as_freelance() {
        return is_available_as_freelance;
    }

    public String getWallet_balance() {
        return wallet_balance;
    }

    public ArrayList<VendorDashboardCountModel> getAs_freelancer() {
        return as_freelancer;
    }

    public ArrayList<VendorDashboardCountModel> getAs_boss_details() {
        return as_boss_details;
    }


}
