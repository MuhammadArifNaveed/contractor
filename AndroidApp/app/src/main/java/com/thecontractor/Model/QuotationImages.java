package com.thecontractor.Model;

public class QuotationImages {
    private String id;
    private String quotation_id;
    private String image_path;
    private String is_active;

    public QuotationImages(String id, String quotation_id, String image_path, String is_active) {
        this.id = id;
        this.quotation_id = quotation_id;
        this.image_path = image_path;
        this.is_active = is_active;
    }

    public String getId() {
        return id;
    }

    public String getQuotation_id() {
        return quotation_id;
    }

    public String getImage_path() {
        return image_path;
    }

    public String getIs_active() {
        return is_active;
    }
}
