package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RatingBar;
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.ReviewsModel;
import com.thecontractor.Model.VendorEnquiryModel;
import com.thecontractor.Model.VendorRatingModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorEnquiryDetail;
import com.thecontractor.VendorActivities.VendorRatingDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorRatingAdapter extends RecyclerView.Adapter<VendorRatingAdapter.ViewHolder>  {

    private List<VendorRatingModel> list;
    private Context mContext;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView reviewerName;
        TextView ratingStatus;
        TextView reviewDate;
        RatingBar reviewRate;


        public ViewHolder(final View view) {
            super(view);

            reviewerName = (TextView) view.findViewById(R.id.reviewerName);
            ratingStatus = (TextView) view.findViewById(R.id.ratingStatus);
            reviewDate = (TextView) view.findViewById(R.id.reviewDate);
            reviewRate = (RatingBar) view.findViewById(R.id.reviewRate);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    VendorRatingModel vendorRatingModel = list.get(pos);
                    Intent intent = new Intent(mContext , VendorRatingDetail.class);
                    Bundle b = new Bundle();
                    b.putParcelable("vendorRatingModel", vendorRatingModel);
                    intent.putExtras(b);
                    mContext.startActivity(intent);
                }
            });

        }
    }


    public VendorRatingAdapter(Context context, List<VendorRatingModel> list) {
        this.list = list;
        this.mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_rating_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        VendorRatingModel model = list.get(position);



        holder.reviewerName.setText(model.getName() + " " + model.getSurname());
        holder.ratingStatus.setText(model.getS_name());
        holder.reviewDate.setText(parseDateToddMMyyyy(model.getCreated_at()));


        if(model.getRating() != null)
        {
            holder.reviewRate.setRating(Float.parseFloat(model.getRating()));
        }
        else
        {
            holder.reviewRate.setRating(0);
        }


        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(model.getColor())));
        ViewCompat.setBackground( holder.ratingStatus,shapeDrawable);

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

