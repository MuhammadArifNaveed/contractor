package com.thecontractor.Adapter;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.WorkshopAdModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorInterestedWorkshopDetail;
import com.thecontractor.WorkshopAdDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorInterestedWorkshopAdAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<WorkshopAdModel> list;
    private Context mContext;
    private String selectedLanguage;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {


        TextView name;
        TextView workshopSector;
        TextView workshopCity;
        TextView workshopAdTitle;
        TextView workshopAdDes;
        TextView workshopAdDateTime;
        TextView workshopAdId;
        TextView markInterested;
        RecyclerView quotationImagesRecyclerView;
        GridLayoutManager gridLayoutManager ;
        WorkshopAdImagesAdapter workshopAdImagesAdapter;



        public ItemVH(final View view) {
            super(view);

            name = (TextView) view.findViewById(R.id.name);
            workshopSector = (TextView) view.findViewById(R.id.workshopSector);
            workshopCity = (TextView) view.findViewById(R.id.workshopCity);
            workshopAdTitle = (TextView) view.findViewById(R.id.workshopAdTitle);
            workshopAdDes = (TextView) view.findViewById(R.id.workshopAdDes);
            workshopAdDateTime = (TextView) view.findViewById(R.id.workshopAdDateTime);
            workshopAdId = (TextView) view.findViewById(R.id.workshopAdId);
            markInterested = (TextView) view.findViewById(R.id.markInterested);
            workshopAdImagesAdapter = new WorkshopAdImagesAdapter(mContext);

            quotationImagesRecyclerView = view.findViewById(R.id.quotationImagesRecyclerView);
            gridLayoutManager = new GridLayoutManager(mContext , 5 ,  GridLayoutManager.VERTICAL , false);
            quotationImagesRecyclerView.setLayoutManager(gridLayoutManager);
            quotationImagesRecyclerView.setAdapter(workshopAdImagesAdapter);

            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    WorkshopAdModel workshopAdModel = list.get(pos);

                    Intent intent = new Intent(mContext , VendorInterestedWorkshopDetail.class);
                    Bundle b = new Bundle();
                    b.putString("id", workshopAdModel.getId());
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


    public VendorInterestedWorkshopAdAdapter(Context context, List<WorkshopAdModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {



        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.interested_workshop_ad_custom_row, parent, false);
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

        WorkshopAdModel model = list.get(position);


        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                if(model.getName().isEmpty() && model.getSurname().isEmpty()){
                    itemVH.name.setVisibility(GONE);
                }else{
                    itemVH.name.setText(model.getName() + " " + model.getSurname());
                    itemVH.name.setVisibility(VISIBLE);
                }

                itemVH.workshopSector.setText(model.getWork_sector());
                itemVH.workshopCity.setText(model.getCity_name());
                itemVH.workshopAdTitle.setText(model.getTitle());
                itemVH.workshopAdDes.setText(model.getDescription());
                itemVH.workshopAdDateTime.setText(parseDateToddMMyyyy(model.getCreated_at()));
                itemVH.workshopAdId.setText(model.getAd_id());
                itemVH.workshopAdImagesAdapter.setData(model.getImages());


                break;
            case LOADING:
//                 Do nothing
                break;
        }





    }



    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd HH:mm:ss";
        String outputPattern = "yyyy-dd-MM h:mm a";
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

    public void add(WorkshopAdModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<WorkshopAdModel> moveResults) {
        for (WorkshopAdModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new WorkshopAdModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        WorkshopAdModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public WorkshopAdModel getItem(int position) {
        return list.get(position);
    }



}

