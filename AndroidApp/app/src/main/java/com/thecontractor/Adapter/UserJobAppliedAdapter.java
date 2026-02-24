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
import com.thecontractor.AvailableJobsDetails;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.UserJobAppliesListingModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class UserJobAppliedAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<UserJobAppliesListingModel> list;
    private Context mContext;
    private String selectedLanguage;
    DatabaseHandler databaseHandler;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {

        TextView jobTitle;
        TextView jobType;
        TextView applyDate;
        TextView status;


        public ItemVH(final View view) {
            super(view);

            jobTitle = (TextView) view.findViewById(R.id.jobTitle);
            jobType = (TextView) view.findViewById(R.id.jobType);
            applyDate = (TextView) view.findViewById(R.id.applyDate);
            status = (TextView) view.findViewById(R.id.status);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    UserJobAppliesListingModel userJobAppliesListingModel = list.get(pos);

//                    Intent intent = new Intent(mContext , AvailableJobsDetails.class);
//                    Bundle b = new Bundle();
//                    b.putParcelable("userJobAppliesListingModel", userJobAppliesListingModel);
//                    intent.putExtras(b);
//                    mContext.startActivity(intent);

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


    public UserJobAppliedAdapter(Context context, List<UserJobAppliesListingModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        databaseHandler = new DatabaseHandler(context);

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.user_job_applied_custom_row, parent, false);
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

        UserJobAppliesListingModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;
                

                itemVH.applyDate.setText(parseDateToddMMyyyy(model.getApplied_at()));

                if(selectedLanguage.equals("en"))
                {
                    itemVH.jobTitle.setText(model.getTitle());
                    itemVH.jobType.setText(model.getJob_type());
                    itemVH.status.setText(model.getCurrent_status());


                }else
                {
                    itemVH.jobTitle.setText(model.getArabic_title());
                    itemVH.jobType.setText(model.getJob_type());
                    itemVH.status.setText(model.getCurrent_status());

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

    public void add(UserJobAppliesListingModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<UserJobAppliesListingModel> moveResults) {
        for (UserJobAppliesListingModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new UserJobAppliesListingModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        UserJobAppliesListingModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public UserJobAppliesListingModel getItem(int position) {
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

