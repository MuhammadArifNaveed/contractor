package com.thecontractor.Adapter;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.VendorJobListingModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorJobDetail;
import com.thecontractor.VendorActivities.VendorPostJob;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorJobListingAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<VendorJobListingModel> list;
    private Context mContext;
    private String selectedLanguage;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;
    private DeleteJobInterface deleteJobInterface;
    public class ItemVH extends RecyclerView.ViewHolder {

        TextView jobTitle;
        TextView jobType;
        TextView postedDate;
        TextView status;
        TextView deleteJob;
        TextView editJob;


        public ItemVH(final View view) {
            super(view);

            jobTitle = (TextView) view.findViewById(R.id.jobTitle);
            jobType = (TextView) view.findViewById(R.id.jobType);
            postedDate = (TextView) view.findViewById(R.id.postedDate);
            status = (TextView) view.findViewById(R.id.status);
            deleteJob = (TextView) view.findViewById(R.id.deleteJob);
            editJob = (TextView) view.findViewById(R.id.editJob);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    VendorJobListingModel vendorJobListingModel = list.get(pos);
                    Intent intent = new Intent(mContext , VendorJobDetail.class);
                    Bundle b = new Bundle();
                    b.putString("jodId" , vendorJobListingModel.getId());
                    b.putString("jodUUId" , vendorJobListingModel.getJob_uuid());
                    intent.putExtras(b);
                    mContext.startActivity(intent);
                }
            });


            editJob.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    VendorJobListingModel vendorJobListingModel = list.get(pos);
                    Intent intent = new Intent(mContext , VendorPostJob.class);
                    Bundle b = new Bundle();
                    b.putString("from" , "update");
                    b.putParcelable("vendorJobListingModel", vendorJobListingModel);
                    intent.putExtras(b);
                    mContext.startActivity(intent);
                }
            });


            deleteJob.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    VendorJobListingModel vendorJobListingModel = list.get(pos);

                    deleteJobInterface.selectedJobForDelete(pos , vendorJobListingModel.getId());

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



    public VendorJobListingAdapter(Context context, List<VendorJobListingModel> list , String selectedLanguage , DeleteJobInterface deleteJobInterface) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.deleteJobInterface = deleteJobInterface;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {



        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_job_listing_custom_row, parent, false);
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

        VendorJobListingModel model = list.get(position);


        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;


                itemVH.postedDate.setText(parseDateToddMMyyyy(model.getCreated_at()));

                if(selectedLanguage.equals("en"))
                {
                    itemVH.jobTitle.setText(model.getTitle());
                    itemVH.jobType.setText(model.getJob_type());

                    if(model.getApproved().equals("0")){
                        itemVH.status.setText("Pending");

                    }else {
                        itemVH.status.setText("Approved");
                    }

                }else
                {
                    itemVH.jobTitle.setText(model.getArabic_title());
                    itemVH.jobType.setText(model.getJob_type());

                    if(model.getApproved().equals("0")){
                        itemVH.status.setText("Pending");

                    }else {
                        itemVH.status.setText("Approved");
                    }
                }

                if(!model.getApplication_count().equals("0")){
                    itemVH.deleteJob.setVisibility(GONE);
                }




                ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                        .toBuilder()
                        .setAllCorners(CornerFamily.ROUNDED,5)
                        .build();

                MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
                shapeDrawable.setPadding(5 , 5 , 5 , 5);

                shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor("#D0BDBDBD")));
                ViewCompat.setBackground(itemVH.status,shapeDrawable);


                break;
            case LOADING:
//                 Do nothing
                break;
        }



    }



    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
        String outputPattern = "yyyy-dd-MM";
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

    public void add(VendorJobListingModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<VendorJobListingModel> moveResults) {
        for (VendorJobListingModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new VendorJobListingModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        VendorJobListingModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public VendorJobListingModel getItem(int position) {
        return list.get(position);
    }

    public interface DeleteJobInterface
    {
        void selectedJobForDelete(int pos , String id);
    }
}

