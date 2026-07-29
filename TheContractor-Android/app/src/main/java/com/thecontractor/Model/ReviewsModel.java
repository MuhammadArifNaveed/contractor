package com.thecontractor.Model;

public class ReviewsModel {
    private String id;
    private String enquiry_company_id;
    private String user_id;
    private String company_id;
    private String rating;
    private String review;
    private String created_at;
    private String name;
    private String surname;

    public ReviewsModel(String id, String enquiry_company_id, String user_id, String company_id, String rating, String review, String created_at, String name, String surname) {
        this.id = id;
        this.enquiry_company_id = enquiry_company_id;
        this.user_id = user_id;
        this.company_id = company_id;
        this.rating = rating;
        this.review = review;
        this.created_at = created_at;
        this.name = name;
        this.surname = surname;
    }

    public String getId() {
        return id;
    }

    public String getEnquiry_company_id() {
        return enquiry_company_id;
    }

    public String getUser_id() {
        return user_id;
    }

    public String getCompany_id() {
        return company_id;
    }

    public String getRating() {
        return rating;
    }

    public String getReview() {
        return review;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getName() {
        return name;
    }

    public String getSurname() {
        return surname;
    }
}
