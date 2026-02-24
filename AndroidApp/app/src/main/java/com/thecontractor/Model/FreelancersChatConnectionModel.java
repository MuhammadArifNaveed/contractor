package com.thecontractor.Model;
public class FreelancersChatConnectionModel {
    private BasicDetails basic_details;
    private String freelancer_name;
    private String image;
    private String order_id;

    public BasicDetails getBasic_details() {
        return basic_details;
    }

    public String getFreelancer_name() {
        return freelancer_name;
    }

    public String getImage() {
        return image;
    }

    public String getOrder_id() {
        return order_id;
    }

    public class BasicDetails{
        private String created_at;

        public String getCreated_at() {
            return created_at;
        }
    }

}


