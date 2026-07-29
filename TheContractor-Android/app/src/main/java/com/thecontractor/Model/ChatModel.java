package com.thecontractor.Model;

public class ChatModel {
    private String chat_uuid;
    private String company_is_view;
    private String company_uuid;
    private String message;
    private String sent_by;
    private String time;
    private String country_time;
    private String user_is_view;
    private String user_uuid;

    public ChatModel() {
    }

    public ChatModel(String chat_uuid, String company_is_view, String company_uuid, String message, String sent_by, String time, String country_time, String user_is_view, String user_uuid) {
        this.chat_uuid = chat_uuid;
        this.company_is_view = company_is_view;
        this.company_uuid = company_uuid;
        this.message = message;
        this.sent_by = sent_by;
        this.time = time;
        this.country_time = country_time;
        this.user_is_view = user_is_view;
        this.user_uuid = user_uuid;
    }

    public String getChat_uuid() {
        return chat_uuid;
    }

    public void setChat_uuid(String chat_uuid) {
        this.chat_uuid = chat_uuid;
    }

    public String getCompany_is_view() {
        return company_is_view;
    }

    public void setCompany_is_view(String company_is_view) {
        this.company_is_view = company_is_view;
    }

    public String getCompany_uuid() {
        return company_uuid;
    }

    public void setCompany_uuid(String company_uuid) {
        this.company_uuid = company_uuid;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getSent_by() {
        return sent_by;
    }

    public void setSent_by(String sent_by) {
        this.sent_by = sent_by;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getCountry_time() {
        return country_time;
    }

    public void setCountry_time(String country_time) {
        this.country_time = country_time;
    }

    public String getUser_is_view() {
        return user_is_view;
    }

    public void setUser_is_view(String user_is_view) {
        this.user_is_view = user_is_view;
    }

    public String getUser_uuid() {
        return user_uuid;
    }

    public void setUser_uuid(String user_uuid) {
        this.user_uuid = user_uuid;
    }
}
