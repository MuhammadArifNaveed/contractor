package com.thecontractor.Model;

import java.util.ArrayList;

public class VendorFreelancingWalletModel {
    private String deposit;
    private String refund;
    private String balance;
    private ArrayList<TransactionsModel> transactions;

    public String getDeposit() {
        return deposit;
    }

    public String getRefund() {
        return refund;
    }

    public String getBalance() {
        return balance;
    }

    public ArrayList<TransactionsModel> getTransactions() {
        return transactions;
    }

    public static class TransactionsModel{
        private String id;
        private String uuid;
        private String wallet_id;
        private String amount;
        private String type;
        private String created_at;

        public TransactionsModel() {
        }

        public TransactionsModel(String id, String uuid, String wallet_id, String amount, String type, String created_at) {
            this.id = id;
            this.uuid = uuid;
            this.wallet_id = wallet_id;
            this.amount = amount;
            this.type = type;
            this.created_at = created_at;
        }

        public String getId() {
            return id;
        }

        public String getUuid() {
            return uuid;
        }

        public String getWallet_id() {
            return wallet_id;
        }

        public String getAmount() {
            return amount;
        }

        public String getType() {
            return type;
        }

        public String getCreated_at() {
            return created_at;
        }
    }
}
