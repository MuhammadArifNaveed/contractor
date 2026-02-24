package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.VendorDashboardCountModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorParticularEnquiries;

import java.util.List;


public class VendorEnquiriesDashboardAdapter extends RecyclerView.Adapter<VendorEnquiriesDashboardAdapter.ViewHolder>  {

    private List<VendorDashboardCountModel> list;
    private Context mContext;
    String selectedLanguage;

    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView statusName;
        TextView statusCount;
        TextView seeAll;


        public ViewHolder(final View view) {
            super(view);

            statusName = (TextView) view.findViewById(R.id.statusName);
            statusCount = (TextView) view.findViewById(R.id.statusCount);
            seeAll = (TextView) view.findViewById(R.id.seeAll);

            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    VendorDashboardCountModel vendorDashboardCountModel = list.get(pos);
                    Intent intent = new Intent(mContext , VendorParticularEnquiries.class);
                    Bundle b = new Bundle();
                    b.putParcelable("vendorDashboardCountModel", vendorDashboardCountModel);
                    intent.putExtras(b);
                    mContext.startActivity(intent);
                }
            });


        }
    }


    public VendorEnquiriesDashboardAdapter(Context context, List<VendorDashboardCountModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_dashboard_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        VendorDashboardCountModel model = list.get(position);

        //holder.statusName.setText(model.getName() + " "+ mContext.getResources().getString(R.string.enquiries));
        holder.statusName.setText(model.getName());
        holder.statusCount.setText(model.getCount());



        

    }




    @Override
    public int getItemCount() {
        return list.size();
    }
    @Override

    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getItemViewType(int position) {
        return position;
    }


}

