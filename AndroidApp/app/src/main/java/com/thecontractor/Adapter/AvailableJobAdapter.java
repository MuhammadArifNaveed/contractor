package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.thecontractor.AvailableJobsDetails;
import com.thecontractor.CompanyDetails;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.AvailableJobListingModel;
import com.thecontractor.Model.AvailableJobListingModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;


public class AvailableJobAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<AvailableJobListingModel> list;
    private Context mContext;
    private String selectedLanguage;
    DatabaseHandler databaseHandler;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView companyImage;
        TextView companyName;
        TextView companyCategoriesName;
        TextView jobTitle;
        TextView jobType;
        TextView deadline;
        TextView jobCity;


        public ItemVH(final View view) {
            super(view);

            companyImage = (ImageView) view.findViewById(R.id.companyImage);
            companyName = (TextView) view.findViewById(R.id.companyName);
            jobTitle = (TextView) view.findViewById(R.id.jobTitle);
            jobType = (TextView) view.findViewById(R.id.jobType);
            deadline = (TextView) view.findViewById(R.id.deadline);
            companyCategoriesName = (TextView) view.findViewById(R.id.companyCategoriesName);
            jobCity = (TextView) view.findViewById(R.id.jobCity);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    AvailableJobListingModel availableJobListingModel = list.get(pos);

                    Intent intent = new Intent(mContext , AvailableJobsDetails.class);
                    Bundle b = new Bundle();
                    b.putParcelable("availableJobListingModel", availableJobListingModel);
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


    public AvailableJobAdapter(Context context, List<AvailableJobListingModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        databaseHandler = new DatabaseHandler(context);

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.available_job_custom_row, parent, false);
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

        AvailableJobListingModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                Glide.with(mContext)
                        .load(ApiUrls.COMPANIES_IMAGE_URL+model.getCompany_logo())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.companyImage);

                itemVH.deadline.setText(parseDateToddMMyyyy(model.getDeadline()));

                if(selectedLanguage.equals("en"))
                {
                    itemVH.companyName.setText(model.getCompany_name());
                    itemVH.companyCategoriesName.setText(model.getCategory_name());
                    itemVH.jobTitle.setText(model.getJob_title()  + " ( "+ model.getJob_category_title() + " )" );
                    itemVH.jobType.setText(model.getJob_type());
                    itemVH.jobCity.setText(model.getJob_location_name());


                }else
                {
                    itemVH.companyName.setText(model.getCompany_arabic_name());
                    itemVH.companyCategoriesName.setText(model.getCategory_name());
                    itemVH.jobTitle.setText(model.getJob_title() + " ( "+ model.getJob_category_title() + " )" );
                    itemVH.jobType.setText(model.getJob_type());
                    itemVH.jobCity.setText(model.getJob_location_name());

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

    public void add(AvailableJobListingModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<AvailableJobListingModel> moveResults) {
        for (AvailableJobListingModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new AvailableJobListingModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        AvailableJobListingModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public AvailableJobListingModel getItem(int position) {
        return list.get(position);
    }

    private void updateValueIntent() {
        Intent updates = new Intent("update");
        updates.putExtra("type", "update_value");
        mContext.sendBroadcast(updates);
    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd";
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

