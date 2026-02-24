package com.thecontractor.Model;

public class VendorHiredFreelancersSummaryModel {
    private String id;
    private String payment_amount;
    private String currency;
    private String create_at;
    private String total;

    public VendorHiredFreelancersSummaryModel() {
    }

    public VendorHiredFreelancersSummaryModel(String id, String payment_amount, String currency, String create_at, String total) {
        this.id = id;
        this.payment_amount = payment_amount;
        this.currency = currency;
        this.create_at = create_at;
        this.total = total;
    }

    public String getId() {
        return id;
    }

    public String getPayment_amount() {
        return payment_amount;
    }

    public String getCurrency() {
        return currency;
    }

    public String getCreate_at() {
        return create_at;
    }

    public String getTotal() {
        return total;
    }
}
