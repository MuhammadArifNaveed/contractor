package com.thecontractor.Model;

public class FreelancerChatModel {
    private String message;
    private String created_at;
    private String sender_name;

    public FreelancerChatModel(String message, String created_at, String sender_name) {
        this.message = message;
        this.created_at = created_at;
        this.sender_name = sender_name;
    }

    public String getMessage() {
        return message;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getSender_name() {
        return sender_name;
    }
}
