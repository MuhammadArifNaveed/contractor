package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.VendorJobAppliesListingModel;
import com.thecontractor.Model.VendorJobAppliesListingModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorApplicantDetail;
import com.thecontractor.VendorActivities.VendorAppliesDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorJobAppliesAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<VendorJobAppliesListingModel> list;
    private Context mContext;
    private String selectedLanguage;
    DatabaseHandler databaseHandler;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView applicantImage;
        TextView applicantName;
        TextView dateTime;
        TextView viewCV;


        public ItemVH(final View view) {
            super(view);

            applicantImage = (ImageView) view.findViewById(R.id.applicantImage);
            applicantName = (TextView) view.findViewById(R.id.applicantName);
            dateTime = (TextView) view.findViewById(R.id.dateTime);
            viewCV = (TextView) view.findViewById(R.id.viewCV);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    VendorJobAppliesListingModel vendorJobAppliesListingModel = list.get(pos);

                    Intent intent = new Intent(mContext , VendorAppliesDetail.class);
                    Bundle b = new Bundle();
                    b.putParcelable("vendorJobAppliesListingModel", vendorJobAppliesListingModel);
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


    public VendorJobAppliesAdapter(Context context, List<VendorJobAppliesListingModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        databaseHandler = new DatabaseHandler(context);

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_job_applies_custom_row, parent, false);
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

        VendorJobAppliesListingModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                Glide.with(mContext)
                        .load(ApiUrls.PROFILE_IMAGE_URL+model.getUsers_user_image())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.applicantImage);

                itemVH.dateTime.setText(parseDateToddMMyyyy(model.getApplied_at()));

                if(selectedLanguage.equals("en"))
                {
                    itemVH.applicantName.setText(model.getUsers_user_name() + " " + model.getUsers_user_sur_name());
                }else
                {
                    itemVH.applicantName.setText(model.getUsers_user_name() + " " + model.getUsers_user_sur_name());
                }


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

    public void add(VendorJobAppliesListingModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<VendorJobAppliesListingModel> moveResults) {
        for (VendorJobAppliesListingModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new VendorJobAppliesListingModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        VendorJobAppliesListingModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public VendorJobAppliesListingModel getItem(int position) {
        return list.get(position);
    }

    private void updateValueIntent() {
        Intent updates = new Intent("update");
        updates.putExtra("type", "update_value");
        mContext.sendBroadcast(updates);
    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
        String outputPattern = "dd-MMM-yyyy";
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

