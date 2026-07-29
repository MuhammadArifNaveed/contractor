package com.thecontractor.Model;

public class TransportationChargesModel {
    private String cost;
    private String discount;

    public TransportationChargesModel(String cost, String discount) {
        this.cost = cost;
        this.discount = discount;
    }

    public String getCost() {
        return cost;
    }

    public String getDiscount() {
        return discount;
    }
}
