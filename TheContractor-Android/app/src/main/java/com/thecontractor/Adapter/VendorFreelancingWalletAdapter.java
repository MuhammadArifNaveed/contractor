package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.thecontractor.AvailableJobsDetails;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.FreelancerSkillModel;
import com.thecontractor.Model.VendorFreelancingWalletModel;
import com.thecontractor.Model.VendorFreelancingWalletModel.TransactionsModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;


public class VendorFreelancingWalletAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<VendorFreelancingWalletModel.TransactionsModel> list;
    private Context mContext;
    private String selectedLanguage;
    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {
        
        TextView transactionID;
        TextView amount;
        TextView createdAt;
       


        public ItemVH(final View view) {
            super(view);

            transactionID = (TextView) view.findViewById(R.id.transactionID);
            amount = (TextView) view.findViewById(R.id.amount);
            createdAt = (TextView) view.findViewById(R.id.createdAt);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    VendorFreelancingWalletModel.TransactionsModel transactionsModel = list.get(pos);

                    Intent intent = new Intent(mContext , AvailableJobsDetails.class);
                    Bundle b = new Bundle();
                    b.putString("id", transactionsModel.getId());
                    intent.putExtras(b);
                    //mContext.startActivity(intent);

                }

            });

        }
    }


    protected class LoadingVH extends RecyclerView.ViewHolder {
        ProgressBar load_more_progress;
        public LoadingVH(View itemView) {
            super(itemView);
            load_more_progress = (ProgressBar) itemView.findViewById(R.id.load_more_progress);
        }
    }


    public VendorFreelancingWalletAdapter(Context context, List<VendorFreelancingWalletModel.TransactionsModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_freelancing__wallet_custom_row, parent, false);
            return new ItemVH(itemView);
        }else if(viewType == LOADING) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.load_more_item_progress, parent, false);
            return new LoadingVH(itemView);
        }
        else
        {
            return null;
        }




    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {

        VendorFreelancingWalletModel.TransactionsModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;



                if(selectedLanguage.equals("en")) {
                }else {
                }

                itemVH.transactionID.setText(model.getUuid());
                itemVH.amount.setText(model.getAmount() + " " + mContext.getResources().getString(R.string.currency) + " (" + model.getType()+")");
                itemVH.createdAt.setText(parseDateToddMMyyyy(model.getCreated_at()));






                break;
            case LOADING:
//                 Do nothing
                break;
        }




    }




    @Override
    public int getItemCount() {
        return list == null ? 0 : list.size();

    }

//    @Override
//    public long getItemId(int position) {
//        return position;
//    }

    @Override
    public int getItemViewType(int position) {
        return (position == list.size() - 1 && isLoadingAdded) ? LOADING : ITEM;
    }

    public void add(VendorFreelancingWalletModel.TransactionsModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<VendorFreelancingWalletModel.TransactionsModel> moveResults) {
        for (VendorFreelancingWalletModel.TransactionsModel result : moveResults) {
            add(result);
        }
    }


    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new VendorFreelancingWalletModel.TransactionsModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        VendorFreelancingWalletModel.TransactionsModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public VendorFreelancingWalletModel.TransactionsModel getItem(int position) {
        return list.get(position);
    }

    private void updateValueIntent() {
        Intent updates = new Intent("update");
        updates.putExtra("type", "update_value");
        mContext.sendBroadcast(updates);
    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd HH:mm:ss";
        String outputPattern = "dd-MM-yyyy h:mm a";
        SimpleDateFormat inputFormat = new SimpleDateFormat(inputPattern);
        SimpleDateFormat outputFormat = new SimpleDateFormat(outputPattern);

        Date date = null;
        String str = null;

        try {
            date = inputFormat.parse(time);
            str = outputFormat.format(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return str;
    }


}

