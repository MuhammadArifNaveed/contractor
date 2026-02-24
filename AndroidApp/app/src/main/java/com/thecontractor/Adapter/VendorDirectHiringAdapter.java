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
import com.thecontractor.Model.VendorDirectHiringModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorApplicantDetail;
import com.thecontractor.VendorActivities.VendorDirectHiringDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorDirectHiringAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<VendorDirectHiringModel> list;
    private Context mContext;
    private String selectedLanguage;
    DatabaseHandler databaseHandler;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView applicantImage;
        TextView applicantName;
        TextView categoriesName;
        TextView dateTime;
        TextView viewCV;


        public ItemVH(final View view) {
            super(view);

            applicantImage = (ImageView) view.findViewById(R.id.applicantImage);
            applicantName = (TextView) view.findViewById(R.id.applicantName);
            dateTime = (TextView) view.findViewById(R.id.dateTime);
            categoriesName = (TextView) view.findViewById(R.id.categoriesName);
            viewCV = (TextView) view.findViewById(R.id.viewCV);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    VendorDirectHiringModel vendorDirectHiringModel = list.get(pos);

                    Intent intent = new Intent(mContext , VendorDirectHiringDetail.class);
                    Bundle b = new Bundle();
                    b.putParcelable("vendorDirectHiringModel", vendorDirectHiringModel);
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


    public VendorDirectHiringAdapter(Context context, List<VendorDirectHiringModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        databaseHandler = new DatabaseHandler(context);

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_direct_hiring_custom_row, parent, false);
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

        VendorDirectHiringModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                Glide.with(mContext)
                        .load(ApiUrls.PROFILE_IMAGE_URL+model.getImage())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.applicantImage);

                itemVH.dateTime.setText(parseDateToddMMyyyy(model.getCreated_at()));

                if(selectedLanguage.equals("en"))
                {
                    itemVH.applicantName.setText(model.getName() + " " + model.getSurname());
                    itemVH.categoriesName.setText(model.getCategory_title());


                }else
                {
                    itemVH.applicantName.setText(model.getName() + " " + model.getSurname());
                    itemVH.categoriesName.setText(model.getCategory_arabic_title());

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

    public void add(VendorDirectHiringModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<VendorDirectHiringModel> moveResults) {
        for (VendorDirectHiringModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new VendorDirectHiringModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        VendorDirectHiringModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public VendorDirectHiringModel getItem(int position) {
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

