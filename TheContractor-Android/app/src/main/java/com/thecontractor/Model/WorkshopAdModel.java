package com.thecontractor.Model;

import java.util.ArrayList;

public class WorkshopAdModel {
    private String id;
    private String ad_id;
    private String user_id;
    private String bid_type;
    private String work_sector;
    private String work_city;
    private String city_name;
    private String is_paid;
    private String category_id;
    private String sub_category_id;
    private String title;
    private String description;
    private String address;
    private String lat;
    private String lng;
    private String name;
    private String surname;
    private String user_uuid;
    private String user_name;
    private String user_surname;
    private String username;
    private String phone;
    private String reason;
    private String status_id;
    private String is_active;
    private String show_info;
    private String show_call;
    private String show_whatsapp;
    private String show_chat;
    private String view_count;
    private String created_at;
    private String update_at;
    private String category_name;
    private String category_arabic_name;
    private String sub_category_name;
    private String arabic_sub_category_name;
    private String status_name;
    private String arabic_status_name;
    private String status_color;
    private String image_path;
    private String interested;
    private ArrayList<WorkshopAdImagesModel> images;
    private ArrayList<VendorStatusModel> status;
    private ArrayList<QuotationsModel> quotations;

    public WorkshopAdModel() {
    }

    public WorkshopAdModel(String id, String ad_id, String user_id, String bid_type, String work_sector, String work_city, String city_name, String is_paid, String category_id, String sub_category_id, String title, String description, String address, String lat, String lng, String name, String surname, String user_uuid, String user_name, String user_surname, String username, String phone, String reason, String status_id, String is_active, String show_info, String show_call, String show_whatsapp, String show_chat, String view_count, String created_at, String update_at, String category_name, String category_arabic_name, String sub_category_name, String arabic_sub_category_name, String status_name, String arabic_status_name, String status_color, String image_path, String interested, ArrayList<WorkshopAdImagesModel> images, ArrayList<VendorStatusModel> status, ArrayList<QuotationsModel> quotations) {
        this.id = id;
        this.ad_id = ad_id;
        this.user_id = user_id;
        this.bid_type = bid_type;
        this.work_sector = work_sector;
        this.work_city = work_city;
        this.city_name = city_name;
        this.is_paid = is_paid;
        this.category_id = category_id;
        this.sub_category_id = sub_category_id;
        this.title = title;
        this.description = description;
        this.address = address;
        this.lat = lat;
        this.lng = lng;
        this.name = name;
        this.surname = surname;
        this.user_uuid = user_uuid;
        this.user_name = user_name;
        this.user_surname = user_surname;
        this.username = username;
        this.phone = phone;
        this.reason = reason;
        this.status_id = status_id;
        this.is_active = is_active;
        this.show_info = show_info;
        this.show_call = show_call;
        this.show_whatsapp = show_whatsapp;
        this.show_chat = show_chat;
        this.view_count = view_count;
        this.created_at = created_at;
        this.update_at = update_at;
        this.category_name = category_name;
        this.category_arabic_name = category_arabic_name;
        this.sub_category_name = sub_category_name;
        this.arabic_sub_category_name = arabic_sub_category_name;
        this.status_name = status_name;
        this.arabic_status_name = arabic_status_name;
        this.status_color = status_color;
        this.image_path = image_path;
        this.interested = interested;
        this.images = images;
        this.status = status;
        this.quotations = quotations;
    }

    public String getId() {
        return id;
    }

    public String getAd_id() {
        return ad_id;
    }

    public String getUser_id() {
        return user_id;
    }

    public String getBid_type() {
        return bid_type;
    }

    public String getWork_sector() {
        return work_sector;
    }

    public String getWork_city() {
        return work_city;
    }

    public String getCity_name() {
        return city_name;
    }

    public String getIs_paid() {
        return is_paid;
    }

    public String getCategory_id() {
        return category_id;
    }

    public String getSub_category_id() {
        return sub_category_id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getAddress() {
        return address;
    }

    public String getLat() {
        return lat;
    }

    public String getLng() {
        return lng;
    }

    public String getName() {
        return name;
    }

    public String getSurname() {
        return surname;
    }

    public String getUser_uuid() {
        return user_uuid;
    }

    public String getUser_name() {
        return user_name;
    }

    public String getUser_surname() {
        return user_surname;
    }

    public String getUsername() {
        return username;
    }

    public String getPhone() {
        return phone;
    }

    public String getReason() {
        return reason;
    }

    public String getStatus_id() {
        return status_id;
    }

    public String getIs_active() {
        return is_active;
    }

    public String getShow_info() {
        return show_info;
    }

    public String getShow_call() {
        return show_call;
    }

    public String getShow_whatsapp() {
        return show_whatsapp;
    }

    public String getShow_chat() {
        return show_chat;
    }

    public String getView_count() {
        return view_count;
    }

    public String getCreated_at() {
        return created_at;
    }

    public String getUpdate_at() {
        return update_at;
    }

    public String getCategory_name() {
        return category_name;
    }

    public String getCategory_arabic_name() {
        return category_arabic_name;
    }

    public String getSub_category_name() {
        return sub_category_name;
    }

    public String getArabic_sub_category_name() {
        return arabic_sub_category_name;
    }

    public String getStatus_name() {
        return status_name;
    }

    public String getArabic_status_name() {
        return arabic_status_name;
    }

    public String getStatus_color() {
        return status_color;
    }

    public String getImage_path() {
        return image_path;
    }

    public String getInterested() {
        return interested;
    }

    public void setInterested(String interested) {
        this.interested = interested;
    }

    public ArrayList<WorkshopAdImagesModel> getImages() {
        return images;
    }

    public ArrayList<VendorStatusModel> getStatus() {
        return status;
    }

    public ArrayList<QuotationsModel> getQuotations() {
        return quotations;
    }

    public class QuotationsModel{
        private String id;
        private String initial_price;
        private String final_price;
        private String document;
        private String message;
        private String status;
        private String locked;
        private String date;
        private String time;
        private AddedBy added_by;
        private ArrayList<ChatModel> chats;

        public QuotationsModel(String id, String initial_price, String final_price, String document, String message, String status, String locked, String date, String time, AddedBy added_by, ArrayList<ChatModel> chats) {
            this.id = id;
            this.initial_price = initial_price;
            this.final_price = final_price;
            this.document = document;
            this.message = message;
            this.status = status;
            this.locked = locked;
            this.date = date;
            this.time = time;
            this.added_by = added_by;
            this.chats = chats;
        }

        public String getId() {
            return id;
        }

        public String getInitial_price() {
            return initial_price;
        }

        public String getFinal_price() {
            return final_price;
        }

        public String getDocument() {
            return document;
        }

        public String getMessage() {
            return message;
        }

        public String getStatus() {
            return status;
        }

        public void setLocked(String locked) {
            this.locked = locked;
        }

        public String getLocked() {
            return locked;
        }

        public String getDate() {
            return date;
        }

        public String getTime() {
            return time;
        }

        public AddedBy getAdded_by() {
            return added_by;
        }

        public ArrayList<ChatModel> getChats() {
            return chats;
        }
    }


    public class ChatModel{
        private String id;
        private String message;
        private String document;
        private String price;
        private String date;
        private String time;
        private AddedBy added_by;

        public ChatModel(String id, String message, String document, String price, String date, String time, AddedBy added_by) {
            this.id = id;
            this.message = message;
            this.document = document;
            this.price = price;
            this.date = date;
            this.time = time;
            this.added_by = added_by;
        }

        public String getId() {
            return id;
        }

        public String getMessage() {
            return message;
        }

        public String getDocument() {
            return document;
        }

        public String getPrice() {
            return price;
        }

        public String getDate() {
            return date;
        }

        public String getTime() {
            return time;
        }

        public AddedBy getAdded_by() {
            return added_by;
        }
    }

    public class AddedBy{
        private String id;
        private String name;
        private String user_type;
        private String phone;
        private String whatsapp;
        private String email;

        public String getId() {
            return id;
        }

        public String getName() {
            return name;
        }

        public String getUser_type() {
            return user_type;
        }

        public String getPhone() {
            return phone;
        }

        public String getWhatsapp() {
            return whatsapp;
        }

        public String getEmail() {
            return email;
        }
    }
}
