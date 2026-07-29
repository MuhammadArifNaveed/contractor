package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.VendorMyMembershipModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorMyMembershipDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorMyMembershipAdapter extends RecyclerView.Adapter<VendorMyMembershipAdapter.ViewHolder>  {

    private List<VendorMyMembershipModel> list;
    private Context mContext;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {


        TextView membershipTitle;
        TextView membershipNo;
        TextView membershipPrice;
        TextView membershipBuyDateTime;
        TextView membershipStatus;


        public ViewHolder(final View view) {
            super(view);

            membershipTitle = (TextView) view.findViewById(R.id.membershipTitle);
            membershipNo = (TextView) view.findViewById(R.id.membershipNo);
            membershipPrice = (TextView) view.findViewById(R.id.membershipPrice);
            membershipBuyDateTime = (TextView) view.findViewById(R.id.membershipBuyDateTime);
            membershipStatus = (TextView) view.findViewById(R.id.membershipStatus);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    VendorMyMembershipModel vendorMyMembershipModel = list.get(pos);

                    Intent intent = new Intent(mContext , VendorMyMembershipDetail.class);
                    Bundle b = new Bundle();
                    b.putString("id" , vendorMyMembershipModel.getId());
                    intent.putExtras(b);
                    mContext.startActivity(intent);

                }

            });



        }
    }


    public VendorMyMembershipAdapter(Context context, List<VendorMyMembershipModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.my_membership_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        VendorMyMembershipModel model = list.get(position);

        holder.membershipBuyDateTime.setText(parseDateToddMMyyyy(model.getCreated_at()));
        holder.membershipTitle.setText(model.getMembership_title());
        holder.membershipNo.setText(model.getMembership_number());
        holder.membershipStatus.setText(model.getS_name());
   


        holder.membershipPrice.setText(mContext.getResources().getString(R.string.currency) + " " + model.getMembership_price());


        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(model.getColor())));
        ViewCompat.setBackground( holder.membershipStatus,shapeDrawable);


    }



    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
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

