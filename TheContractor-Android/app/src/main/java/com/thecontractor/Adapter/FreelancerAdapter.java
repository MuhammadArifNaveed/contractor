package com.thecontractor.Adapter;

import static android.view.View.GONE;

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
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.thecontractor.AvailableJobsDetails;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Database.FreelancerDatabaseHelper;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SelectedFreelancerDatePicker;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.FreelancerSkillModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


public class FreelancerAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<FreelancerListModel> list;
    private Context mContext;
    private String selectedLanguage;
    FreelancerDatabaseHelper freelancerDatabaseHelper;
    private SelectFreelancer selectFreelancer;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;
    private String commissionRate;
    private String userId;


    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView freelancerImage;
        TextView freelancerName;
        TextView freelancerCategory;
        TextView freelancerRateHR;
        ChipGroup freelancerSkills;
        TextView freelancerAreaCity;
        TextView freelancerTime;
        TextView freelancerMemberSince;
        TextView availableHourly;
        Button selectOrRemoveBtn;


        public ItemVH(final View view) {
            super(view);

            freelancerImage = (ImageView) view.findViewById(R.id.freelancerImage);
            freelancerName = (TextView) view.findViewById(R.id.freelancerName);
            freelancerRateHR = (TextView) view.findViewById(R.id.freelancerRateHR);
            freelancerSkills = (ChipGroup) view.findViewById(R.id.freelancerSkills);
            freelancerAreaCity = (TextView) view.findViewById(R.id.freelancerAreaCity);
            freelancerCategory = (TextView) view.findViewById(R.id.freelancerCategory);
            freelancerTime = (TextView) view.findViewById(R.id.freelancerTime);
            freelancerMemberSince = (TextView) view.findViewById(R.id.freelancerMemberSince);
            availableHourly = (TextView) view.findViewById(R.id.availableHourly);
            selectOrRemoveBtn = (Button) view.findViewById(R.id.selectOrRemoveBtn);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    FreelancerListModel freelancerListModel = list.get(pos);

                    Intent intent = new Intent(mContext , AvailableJobsDetails.class);
                    Bundle b = new Bundle();
                    b.putParcelable("freelancerListModel", freelancerListModel);
                    intent.putExtras(b);
                    //mContext.startActivity(intent);

                }

            });

            selectOrRemoveBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(userId == null || userId.isEmpty()){
                        return;
                    }

                    int pos = getAdapterPosition();
                    FreelancerListModel freelancerListModel = list.get(pos);

                    if(selectOrRemoveBtn.getText().toString().equals(mContext.getResources().getString(R.string.remove_freelancer)))
                    {
                        int result = freelancerDatabaseHelper.deleteFreelancer(list.get(pos).getId());
                        if (result > 0) {
                            selectOrRemoveBtn.setText(mContext.getResources().getString(R.string.select_freelancer));
                            selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(mContext, R.drawable.button_bacground));
                            selectOrRemoveBtn.setTextColor(ContextCompat.getColor(mContext, R.color.black));
                            selectFreelancer.selectedFreelancer(freelancerListModel , "if");

                        } else {
                            Toast.makeText(mContext, "Error: Freelancer not found.", Toast.LENGTH_SHORT).show();
                        }

                    }else {
                        selectFreelancer.selectedFreelancer(freelancerListModel , "else");
                    }

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


    public FreelancerAdapter(Context context, List<FreelancerListModel> list , String selectedLanguage , String userId , SelectFreelancer selectFreelancer) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.userId = userId;
        this.selectFreelancer = selectFreelancer;
        freelancerDatabaseHelper = new FreelancerDatabaseHelper(context);

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.freelancer_custom_row, parent, false);
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

        FreelancerListModel model = list.get(position);

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
                    itemVH.freelancerCategory.setText(model.getJob_category_title());
                    itemVH.freelancerRateHR.setText(String.format("%.2f" , new SelectedFreelancerDatePicker().calculateHourlyRatePercentage(model.getHourly_rate() , commissionRate)) + "/hr");
                    itemVH.freelancerAreaCity.setText(model.getArea_name() + " , " +model.getCity_name());
                    itemVH.freelancerTime.setText(parseTime(model.getFrom_time()) + " to " + parseTime(model.getTo_time()));
                    itemVH.freelancerMemberSince.setText("Member since " + parseDateToddMMyyyy(model.getCreated_at()));



                }else
                {
                    itemVH.freelancerName.setText(model.getName());
                    itemVH.freelancerCategory.setText(model.getJob_category_title());
                    itemVH.freelancerRateHR.setText(String.format("%.2f" , new SelectedFreelancerDatePicker().calculateHourlyRatePercentage(model.getHourly_rate() , commissionRate)) + "/hr");
                    itemVH.freelancerAreaCity.setText(model.getArea_name() + " , " +model.getCity_name());
                    itemVH.freelancerTime.setText(parseTime(model.getFrom_time()) + " to " + parseTime(model.getTo_time()));
                    itemVH.freelancerMemberSince.setText("Member since " + parseDateToddMMyyyy(model.getCreated_at()));

                }

                if(model.getAvailable_per_hour().equals("0")){
                    itemVH.availableHourly.setVisibility(GONE);
                }

                displayChips(model.getSkills() , itemVH.freelancerSkills);

                if(userId == null || userId.isEmpty()){
                    itemVH.selectOrRemoveBtn.setText(R.string.please_login_to_hire);
                }else {

                    if (freelancerDatabaseHelper.checkFreelancerExists(model.getId())) {
                        itemVH.selectOrRemoveBtn.setText(mContext.getResources().getString(R.string.remove_freelancer));
                        itemVH.selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(mContext, R.drawable.red_button_bacground));
                        itemVH.selectOrRemoveBtn.setTextColor(ContextCompat.getColor(mContext, R.color.white));

                    }
                    else
                    {
                        itemVH.selectOrRemoveBtn.setText(mContext.getResources().getString(R.string.select_freelancer));
                        itemVH.selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(mContext, R.drawable.button_bacground));
                        itemVH.selectOrRemoveBtn.setTextColor(ContextCompat.getColor(mContext, R.color.black));

                    }
                }




                break;
            case LOADING:
//                 Do nothing
                break;
        }




    }


    private void displayChips(ArrayList<FreelancerSkillModel> skills, ChipGroup freelancerSkills) {
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

    public void add(FreelancerListModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<FreelancerListModel> moveResults) {
        for (FreelancerListModel result : moveResults) {
            add(result);
        }
    }


    public void getCommissionRate(String commissionRate) {
        this.commissionRate = commissionRate;
    }


    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new FreelancerListModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        FreelancerListModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public FreelancerListModel getItem(int position) {
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


    public interface SelectFreelancer
    {
        void selectedFreelancer(FreelancerListModel freelancerListModel , String from);
    }

}

