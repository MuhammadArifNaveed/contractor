package com.thecontractor.Model;

public class ChatConnectionModel {
    private String company_id;
    private String company_uuid;
    private String company_serial_no;
    private String company_name;
    private String company_is_active;
    private String user_id;
    private String user_uuid;
    private String user_name;
    private String full_name;
    private String user_is_active;
    private String is_active;
    private String chat_uuid;
    private String created_at;
    private String last_message;
    private String message_time;

    public ChatConnectionModel() {
    }

    public ChatConnectionModel(String company_id, String company_uuid, String company_serial_no, String company_name, String company_is_active, String user_id, String user_uuid, String user_name, String full_name, String user_is_active, String is_active, String chat_uuid, String created_at, String last_message, String message_time) {
        this.company_id = company_id;
        this.company_uuid = company_uuid;
        this.company_serial_no = company_serial_no;
        this.company_name = company_name;
        this.company_is_active = company_is_active;
        this.user_id = user_id;
        this.user_uuid = user_uuid;
        this.user_name = user_name;
        this.full_name = full_name;
        this.user_is_active = user_is_active;
        this.is_active = is_active;
        this.chat_uuid = chat_uuid;
        this.created_at = created_at;
        this.last_message = last_message;
        this.message_time = message_time;
    }

    public String getCompany_id() {
        return company_id;
    }

    public void setCompany_id(String company_id) {
        this.company_id = company_id;
    }

    public String getCompany_uuid() {
        return company_uuid;
    }

    public void setCompany_uuid(String company_uuid) {
        this.company_uuid = company_uuid;
    }

    public String getCompany_serial_no() {
        return company_serial_no;
    }

    public void setCompany_serial_no(String company_serial_no) {
        this.company_serial_no = company_serial_no;
    }

    public String getCompany_name() {
        return company_name;
    }

    public void setCompany_name(String company_name) {
        this.company_name = company_name;
    }

    public String getCompany_is_active() {
        return company_is_active;
    }

    public void setCompany_is_active(String company_is_active) {
        this.company_is_active = company_is_active;
    }

    public String getUser_id() {
        return user_id;
    }

    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }

    public String getUser_uuid() {
        return user_uuid;
    }

    public void setUser_uuid(String user_uuid) {
        this.user_uuid = user_uuid;
    }

    public String getUser_name() {
        return user_name;
    }

    public void setUser_name(String user_name) {
        this.user_name = user_name;
    }

    public String getFull_name() {
        return full_name;
    }

    public void setFull_name(String full_name) {
        this.full_name = full_name;
    }

    public String getUser_is_active() {
        return user_is_active;
    }

    public void setUser_is_active(String user_is_active) {
        this.user_is_active = user_is_active;
    }

    public String getIs_active() {
        return is_active;
    }

    public void setIs_active(String is_active) {
        this.is_active = is_active;
    }

    public String getChat_uuid() {
        return chat_uuid;
    }

    public void setChat_uuid(String chat_uuid) {
        this.chat_uuid = chat_uuid;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getLast_message() {
        return last_message;
    }

    public void setLast_message(String last_message) {
        this.last_message = last_message;
    }

    public String getMessage_time() {
        return message_time;
    }

    public void setMessage_time(String message_time) {
        this.message_time = message_time;
    }
}
