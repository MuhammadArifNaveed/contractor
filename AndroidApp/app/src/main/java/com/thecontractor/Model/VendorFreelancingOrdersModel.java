package com.thecontractor.Model;

import java.util.ArrayList;

public class VendorFreelancingOrdersModel {

    private OrderModel order;
    private RequesterModel requester;

    public OrderModel getOrder() {
        return order;
    }

    public RequesterModel getRequester() {
        return requester;
    }

    public class OrderModel {
        private String id;
        private String hourly;
        private String hourly_rate;
        private String from_time;
        private String to_time;
        private String amount;
        private String comission_rate;
        private String company_comission;
        private String transportation_charges;
        private String discount;
        private String picked;
        private String dates;
        private String status;
        private String expired;
        private String refunded;
        private String created_at;
        private String freelancer_id;
        private String freelancer_name;
        private String freelancer_email;
        private String freelancer_phone;
        private String image;
        private String payment_status;
        private String details_id;

        public OrderModel(String id, String hourly, String hourly_rate, String from_time, String to_time, String amount, String comission_rate, String company_comission, String transportation_charges, String discount, String picked, String dates, String status, String expired, String refunded, String created_at, String freelancer_id, String freelancer_name, String freelancer_email, String freelancer_phone, String image, String payment_status, String details_id) {
            this.id = id;
            this.hourly = hourly;
            this.hourly_rate = hourly_rate;
            this.from_time = from_time;
            this.to_time = to_time;
            this.amount = amount;
            this.comission_rate = comission_rate;
            this.company_comission = company_comission;
            this.transportation_charges = transportation_charges;
            this.discount = discount;
            this.picked = picked;
            this.dates = dates;
            this.status = status;
            this.expired = expired;
            this.refunded = refunded;
            this.created_at = created_at;
            this.freelancer_id = freelancer_id;
            this.freelancer_name = freelancer_name;
            this.freelancer_email = freelancer_email;
            this.freelancer_phone = freelancer_phone;
            this.image = image;
            this.payment_status = payment_status;
            this.details_id = details_id;
        }

        public String getId() {
            return id;
        }

        public String getHourly() {
            return hourly;
        }

        public String getHourly_rate() {
            return hourly_rate;
        }

        public String getFrom_time() {
            return from_time;
        }

        public String getTo_time() {
            return to_time;
        }

        public String getAmount() {
            return amount;
        }

        public String getComission_rate() {
            return comission_rate;
        }

        public String getCompany_comission() {
            return company_comission;
        }

        public String getTransportation_charges() {
            return transportation_charges;
        }

        public String getDiscount() {
            return discount;
        }

        public String getPicked() {
            return picked;
        }

        public String getDates() {
            return dates;
        }

        public String getStatus() {
            return status;
        }

        public String getExpired() {
            return expired;
        }

        public String getRefunded() {
            return refunded;
        }

        public String getCreated_at() {
            return created_at;
        }

        public String getFreelancer_id() {
            return freelancer_id;
        }

        public String getFreelancer_name() {
            return freelancer_name;
        }

        public String getFreelancer_email() {
            return freelancer_email;
        }

        public String getFreelancer_phone() {
            return freelancer_phone;
        }

        public String getImage() {
            return image;
        }

        public String getPayment_status() {
            return payment_status;
        }

        public String getDetails_id() {
            return details_id;
        }
    }

    public class RequesterModel {
        private String name;
        private String email;
        private String phone;
        private String whatsapp;
        private String address;
        private String type;

        public RequesterModel(String name, String email, String phone, String whatsapp, String address, String type) {
            this.name = name;
            this.email = email;
            this.phone = phone;
            this.whatsapp = whatsapp;
            this.address = address;
            this.type = type;
        }

        public String getName() {
            return name;
        }

        public String getEmail() {
            return email;
        }

        public String getPhone() {
            return phone;
        }

        public String getWhatsapp() {
            return whatsapp;
        }

        public String getAddress() {
            return address;
        }

        public String getType() {
            return type;
        }
    }
}
