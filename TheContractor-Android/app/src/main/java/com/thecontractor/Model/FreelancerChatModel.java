package com.thecontractor.Model;

public class FreelancerChatModel {
    private String message;
    private String created_at;
    private String sender_name;
    private String sender_id;
    private String sender_type;
    private String order_id;

    public FreelancerChatModel() {
    }

    public FreelancerChatModel(String message, String created_at, String sender_name, String sender_id, String sender_type, String order_id) {
        this.message = message;
        this.created_at = created_at;
        this.sender_name = sender_name;
        this.sender_id = sender_id;
        this.sender_type = sender_type;
        this.order_id = order_id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getSender_name() {
        return sender_name;
    }

    public void setSender_name(String sender_name) {
        this.sender_name = sender_name;
    }

    public String getSender_id() {
        return sender_id;
    }

    public void setSender_id(String sender_id) {
        this.sender_id = sender_id;
    }

    public String getSender_type() {
        return sender_type;
    }

    public void setSender_type(String sender_type) {
        this.sender_type = sender_type;
    }

    public String getOrder_id() {
        return order_id;
    }

    public void setOrder_id(String order_id) {
        this.order_id = order_id;
    }
}
