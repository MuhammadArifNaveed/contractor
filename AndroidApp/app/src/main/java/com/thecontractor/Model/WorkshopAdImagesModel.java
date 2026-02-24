package com.thecontractor.Model;

public class WorkshopAdImagesModel {
    private String id;
    private String ad_id;
    private String image_path;
    private String is_active;

    public WorkshopAdImagesModel(String id, String ad_id, String image_path, String is_active) {
        this.id = id;
        this.ad_id = ad_id;
        this.image_path = image_path;
        this.is_active = is_active;
    }

    public String getId() {
        return id;
    }

    public String getAd_id() {
        return ad_id;
    }

    public String getImage_path() {
        return image_path;
    }

    public String getIs_active() {
        return is_active;
    }
}
