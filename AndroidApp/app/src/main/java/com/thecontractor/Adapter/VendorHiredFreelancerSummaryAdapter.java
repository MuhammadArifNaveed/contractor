package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.VendorHiredFreelancersSummaryModel;
import com.thecontractor.Model.VendorHiredFreelancersSummaryModel;
import com.thecontractor.QuotationsDetails;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorHiredFreelancers;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorHiredFreelancerSummaryAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<VendorHiredFreelancersSummaryModel> list;
    private Context mContext;
    private String selectedLanguage;
    private String from;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;

    public class ItemVH extends RecyclerView.ViewHolder {


        TextView totalFreelancers;
        TextView amountPaid;
        TextView registeredDate;
        TextView viewDetail;


        public ItemVH(final View view) {
            super(view);

            totalFreelancers = (TextView) view.findViewById(R.id.totalFreelancers);
            amountPaid = (TextView) view.findViewById(R.id.amountPaid);
            registeredDate = (TextView) view.findViewById(R.id.registeredDate);
            viewDetail = (TextView) view.findViewById(R.id.viewDetail);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    VendorHiredFreelancersSummaryModel vendorHiredFreelancersSummaryModel = list.get(pos);

                    Intent intent = new Intent(mContext , VendorHiredFreelancers.class);
                    Bundle b = new Bundle();
                    b.putString("batchId", vendorHiredFreelancersSummaryModel.getId());
                    b.putString("from", from);
                    intent.putExtras(b);
                    mContext.startActivity(intent);

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



    public VendorHiredFreelancerSummaryAdapter(Context context, List<VendorHiredFreelancersSummaryModel> list , String selectedLanguage, String from) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.from = from;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {



        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_hired_freelancer_summary_custom_row, parent, false);
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

        VendorHiredFreelancersSummaryModel model = list.get(position);


        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                itemVH.registeredDate.setText(parseDateToddMMyyyy(model.getCreate_at()));

                if(selectedLanguage.equals("en"))
                {
                    itemVH.totalFreelancers.setText(model.getTotal());
                    itemVH.amountPaid.setText(model.getPayment_amount());
                }else
                {
                    itemVH.totalFreelancers.setText(model.getTotal());
                    itemVH.amountPaid.setText(model.getPayment_amount());
                }



                break;
            case LOADING:
//                 Do nothing
                break;
        }





    }



    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd HH:mm:ss";
        String outputPattern = "dd MMM yyyy";
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
    @Override
    public int getItemCount() {
        return list == null ? 0 : list.size();

    }


    @Override
    public int getItemViewType(int position) {
        return (position == list.size() - 1 && isLoadingAdded) ? LOADING : ITEM;
    }

    public void add(VendorHiredFreelancersSummaryModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<VendorHiredFreelancersSummaryModel> moveResults) {
        for (VendorHiredFreelancersSummaryModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new VendorHiredFreelancersSummaryModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        VendorHiredFreelancersSummaryModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public VendorHiredFreelancersSummaryModel getItem(int position) {
        return list.get(position);
    }



}

