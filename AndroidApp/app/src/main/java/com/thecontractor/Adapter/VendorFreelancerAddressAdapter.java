package com.thecontractor.Adapter;

import static android.view.View.GONE;

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
import android.widget.RadioButton;
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.FreelancerAddressModel;
import com.thecontractor.Model.FreelancerAddressModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorJobDetail;
import com.thecontractor.VendorActivities.VendorPostJob;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorFreelancerAddressAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<FreelancerAddressModel> list;
    private Context mContext;
    private String selectedLanguage;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;
    private FreelancerAddressInterface freelancerAddressInterface;
    private int selectedPosition = -1;


    public class ItemVH extends RecyclerView.ViewHolder {

        TextView address;
        TextView mapAddress;
        RadioButton currentAddress;
        ImageView deleteAddress;


        public ItemVH(final View view) {
            super(view);

            address = (TextView) view.findViewById(R.id.address);
            mapAddress = (TextView) view.findViewById(R.id.mapAddress);
            currentAddress = (RadioButton) view.findViewById(R.id.currentAddress);
            deleteAddress = (ImageView) view.findViewById(R.id.deleteAddress);


            currentAddress.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();
                    FreelancerAddressModel freelancerAddressModel = list.get(pos);
                    freelancerAddressInterface.selectedCurrentAddress(pos , freelancerAddressModel.getId());

                    selectedPosition = pos;
                    notifyDataSetChanged();
                }
            });


            deleteAddress.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    FreelancerAddressModel freelancerAddressModel = list.get(pos);

                    freelancerAddressInterface.selectedDeleteAddress(pos , freelancerAddressModel.getId());

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



    public VendorFreelancerAddressAdapter(Context context, List<FreelancerAddressModel> list , String selectedLanguage , FreelancerAddressInterface freelancerAddressInterface) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.freelancerAddressInterface = freelancerAddressInterface;

        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).getStatus().equals("1")) {
                selectedPosition = i;
                freelancerAddressInterface.selectedCurrentAddress(i , list.get(i).getId());
                break;
            }
        }
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {



        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_freelancer_address_custom_row, parent, false);
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

        FreelancerAddressModel model = list.get(position);


        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                itemVH.currentAddress.setChecked(position == selectedPosition);

                if(selectedLanguage.equals("en"))
                {
                    itemVH.address.setText(model.getAddress());
                    itemVH.mapAddress.setText(model.getPick_up_address());

                }else
                {
                    itemVH.address.setText(model.getAddress());
                    itemVH.mapAddress.setText(model.getPick_up_address());
                }
                


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

    public void add(FreelancerAddressModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<FreelancerAddressModel> moveResults) {
        for (FreelancerAddressModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new FreelancerAddressModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        FreelancerAddressModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public FreelancerAddressModel getItem(int position) {
        return list.get(position);
    }


    public interface FreelancerAddressInterface
    {
        void selectedCurrentAddress(int pos , String id);
        void selectedDeleteAddress(int pos , String id);
    }
}

