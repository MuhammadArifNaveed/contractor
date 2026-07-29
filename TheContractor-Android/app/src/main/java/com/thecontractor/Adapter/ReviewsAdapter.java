package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;
import com.thecontractor.Model.ReviewsModel;
import com.thecontractor.Model.ReviewsModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class ReviewsAdapter extends RecyclerView.Adapter<ReviewsAdapter.ViewHolder>  {

    private List<ReviewsModel> list;
    private Context mContext;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView reviewerName;
        TextView review;
        TextView reviewDate;
        TextView rating;
        RatingBar reviewRate;


        public ViewHolder(final View view) {
            super(view);

            reviewerName = (TextView) view.findViewById(R.id.reviewerName);
            review = (TextView) view.findViewById(R.id.review);
            reviewDate = (TextView) view.findViewById(R.id.reviewDate);
            rating = (TextView) view.findViewById(R.id.rating);
            reviewRate = (RatingBar) view.findViewById(R.id.reviewRate);




        }
    }


    public ReviewsAdapter(Context context, List<ReviewsModel> list) {
        this.list = list;
        this.mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.reviews_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        ReviewsModel model = list.get(position);



        holder.reviewerName.setText(model.getName() + " " + model.getSurname());
        holder.review.setText(model.getReview());
        holder.reviewDate.setText(parseDateToddMMyyyy(model.getCreated_at()));
        holder.rating.setText("("+model.getRating()+")");


        if(model.getRating() != null)
        {
            holder.reviewRate.setRating(Float.parseFloat(model.getRating()));
        }
        else
        {
            holder.reviewRate.setRating(0);
        }


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

