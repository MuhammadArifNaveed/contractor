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
import com.thecontractor.Model.VendorHiredFreelancersModel;
import com.thecontractor.Model.FreelancerSkillModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;


public class VendorHiredFreelancerAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<VendorHiredFreelancersModel> list;
    private Context mContext;
    private String selectedLanguage;
    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView freelancerImage;
        TextView freelancerName;
        TextView freelancerPicked;
        TextView freelancerTime;
        ChipGroup freelancerSkills;
        ChipGroup registeredDates;
        TextView registeredOnDate;
        TextView responseTime;
        TextView response;
        TextView status;


        public ItemVH(final View view) {
            super(view);

            freelancerImage = (ImageView) view.findViewById(R.id.freelancerImage);
            freelancerName = (TextView) view.findViewById(R.id.freelancerName);
            freelancerPicked = (TextView) view.findViewById(R.id.freelancerPicked);
            freelancerSkills = (ChipGroup) view.findViewById(R.id.freelancerSkills);
            registeredDates = (ChipGroup) view.findViewById(R.id.registeredDates);
            freelancerTime = (TextView) view.findViewById(R.id.freelancerTime);
            registeredOnDate = (TextView) view.findViewById(R.id.registeredOnDate);
            responseTime = (TextView) view.findViewById(R.id.responseTime);
            response = (TextView) view.findViewById(R.id.response);
            status = (TextView) view.findViewById(R.id.status);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    VendorHiredFreelancersModel vendorHiredFreelancersModel = list.get(pos);

                    Intent intent = new Intent(mContext , AvailableJobsDetails.class);
                    Bundle b = new Bundle();
                    b.putString("id", vendorHiredFreelancersModel.getDetails_id());
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


    public VendorHiredFreelancerAdapter(Context context, List<VendorHiredFreelancersModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_hired_freelancer_custom_row, parent, false);
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

        VendorHiredFreelancersModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                Glide.with(mContext)
                        .load(ApiUrls.PROFILE_IMAGE_URL+model.getImage())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.freelancerImage);


                if(selectedLanguage.equals("en"))
                {
                    itemVH.freelancerName.setText(model.getName());
                }else
                {
                    itemVH.freelancerName.setText(model.getName());
                }

                if(model.getPicked().equals("0")){
                    itemVH.freelancerPicked.setText("(Not Picked)");
                }else {
                    itemVH.freelancerPicked.setText("(Picked)");
                }

                if(model.getHourly().equals("0")){
                    itemVH.freelancerTime.setText("Full Day (" +parseTime(model.getFrom_time()) + " to " + parseTime(model.getTo_time())+")");
                }else {
                    itemVH.freelancerTime.setText("Hours (" +parseTime(model.getFrom_time()) + " to " + parseTime(model.getTo_time())+")");
                }


                itemVH.registeredOnDate.setText(parseDateToddMMyyyy(model.getCreated_at()));
                displaySkillsChips(model.getSkills() , itemVH.freelancerSkills);
                displayDatesChips(model.getDates() , itemVH.registeredDates);


                if(model.getStatus().equals("0") && model.getExpired().equals("1")){
                    itemVH.responseTime.setText("Time Over");
                }else if(!model.getStatus().equals("0") && model.getExpired().equals("1")){
                    itemVH.responseTime.setText("Time Over or Rejected");
                }else if(model.getStatus().equals("1") && model.getExpired().equals("0")){
                    itemVH.responseTime.setText("Accepted");
                }else if(model.getStatus().equals("2") && model.getExpired().equals("0")){
                    itemVH.responseTime.setText("Rejected");
                }else if(model.getStatus().equals("3") && model.getExpired().equals("0")){
                    itemVH.responseTime.setText("Completed");
                }else{
                    startCountdown(model.getCreated_at() , itemVH.responseTime);
                }


                if(model.getStatus().equals("0")){
                    itemVH.response.setText("No Response");
                }else if(model.getStatus().equals("1")){
                    itemVH.response.setText("Order Accepted");
                }else if(model.getStatus().equals("2")){
                    itemVH.response.setText("Order Rejected");
                }else if(model.getStatus().equals("3")){
                    itemVH.response.setText("Order Completed");
                }


                if(model.getStatus().equals("0") && model.getExpired().equals("1")){
                    itemVH.status.setText("Expired");
                }else if(model.getStatus().equals("0") && model.getExpired().equals("0")){
                    itemVH.status.setText("Pending");
                }else if(model.getStatus().equals("1")){
                    itemVH.status.setText("Accepted");
                }else if(model.getStatus().equals("2")){
                    itemVH.status.setText("Rejected");
                }else if(model.getStatus().equals("3")){
                    itemVH.status.setText("Completed");
                }





                break;
            case LOADING:
//                 Do nothing
                break;
        }




    }


    private void displaySkillsChips(ArrayList<FreelancerSkillModel> skills, ChipGroup freelancerSkills) {
        freelancerSkills.removeAllViews();
        for (FreelancerSkillModel item : skills) {
            final Chip chip = new Chip(mContext);
            chip.setText(item.getSkill_title());
            chip.setChipBackgroundColorResource(R.color.appColor);

            // Optional: Customize the chip appearance and behavior
            chip.setCloseIconVisible(false); // Makes a close icon visible
            chip.setClickable(false);
            chip.setCheckable(false); // Can be set to true for filter/choice chips

            // Add the chip to the ChipGroup
            freelancerSkills.addView(chip);
        }
    }

    private void displayDatesChips(ArrayList<VendorHiredFreelancersModel.DateModel> dates, ChipGroup freelancerSkills) {
        freelancerSkills.removeAllViews();
        for (VendorHiredFreelancersModel.DateModel item : dates) {
            final Chip chip = new Chip(mContext);
            chip.setText(parseDateToddMMyyyy(item.getDate()));

            // Optional: Customize the chip appearance and behavior
            chip.setCloseIconVisible(false); // Makes a close icon visible
            chip.setClickable(false);
            chip.setCheckable(false); // Can be set to true for filter/choice chips

            // Add the chip to the ChipGroup
            freelancerSkills.addView(chip);
        }
    }

    private void startCountdown(String dateTimeString, TextView responseTime) {

        try {
            // Parse given time AS DUBAI TIME
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
            sdf.setTimeZone(TimeZone.getTimeZone("Asia/Dubai"));  // IMPORTANT
            Date startDateDubai = sdf.parse(dateTimeString);

            long startMillis = startDateDubai.getTime();
            long endMillis = startMillis + (15 * 60 * 1000); // + 15 min

            // Get current Dubai time
            Calendar dubaiCalendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Dubai"));
            long currentMillis = dubaiCalendar.getTimeInMillis();

            long timeLeft = endMillis - currentMillis;

            Log.e("tag", "Given Dubai Time: " + dateTimeString);
            Log.e("tag", "Current Dubai Time: " + sdf.format(dubaiCalendar.getTime()));
            Log.e("tag", "Milliseconds left: " + timeLeft);

            if (timeLeft <= 0) {
                responseTime.setText("Time Over");
                Log.e("tag", "Time expired!");
                return;
            }

            new CountDownTimer(timeLeft, 1000) {

                @Override
                public void onTick(long millisUntilFinished) {
                    long seconds = millisUntilFinished / 1000;
                    long min = seconds / 60;
                    long sec = seconds % 60;

                    responseTime.setText(String.format(Locale.getDefault(), "%02d:%02d", min, sec));
                }

                @Override
                public void onFinish() {
                    responseTime.setText("Time Over");
                    Log.e("tag", "15min Time expired!");
                }
            }.start();

        } catch (Exception e) {
            e.printStackTrace();
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

    public void add(VendorHiredFreelancersModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<VendorHiredFreelancersModel> moveResults) {
        for (VendorHiredFreelancersModel result : moveResults) {
            add(result);
        }
    }


    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new VendorHiredFreelancersModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        VendorHiredFreelancersModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public VendorHiredFreelancersModel getItem(int position) {
        return list.get(position);
    }

    private void updateValueIntent() {
        Intent updates = new Intent("update");
        updates.putExtra("type", "update_value");
        mContext.sendBroadcast(updates);
    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd";
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

    public String parseTime(String time) {
        String inputPattern = "HH:mm:ss";
        String outputPattern = "h:mm a";
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

