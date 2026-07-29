package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.thecontractor.CompanyDetails;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.R;

import java.util.HashMap;
import java.util.List;


public class TitaniumCompaniesAdapter extends RecyclerView.Adapter<TitaniumCompaniesAdapter.ViewHolder>  {

    private List<CompaniesModel> list;
    private Context mContext;



    public class ViewHolder extends RecyclerView.ViewHolder {

        ImageView companyImage;
        TextView companyName;
        TextView categoriesName;
        TextView companyTotalRatingCount;
        ImageView verified;
        RatingBar ratingBar;
        Button selectOrRemoveBtn;


        public ViewHolder(final View view) {
            super(view);

            companyImage = (ImageView) view.findViewById(R.id.companyImage);
            companyName = (TextView) view.findViewById(R.id.companyName);
            categoriesName = (TextView) view.findViewById(R.id.categoriesName);
            companyTotalRatingCount = (TextView) view.findViewById(R.id.companyTotalRatingCount);
            verified = (ImageView) view.findViewById(R.id.verified);
            ratingBar = (RatingBar) view.findViewById(R.id.ratingBar);
            selectOrRemoveBtn = (Button) view.findViewById(R.id.selectOrRemoveBtn);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    CompaniesModel companyModel = list.get(pos);

                    Intent intent = new Intent(mContext, CompanyDetails.class);
                    Bundle b = new Bundle();
                    b.putString("companyId", companyModel.getId());
                    b.putString("averageRating", companyModel.getAvg_rating());
                    b.putString("companyReviewCount", companyModel.getReview_count());
                    intent.putExtras(b);
                    mContext.startActivity(intent);

                }

            });

        }
    }


    public TitaniumCompaniesAdapter(Context context, List<CompaniesModel> list) {
        this.list = list;
        this.mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.titanium_companies_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        CompaniesModel model = list.get(position);

        Glide.with(mContext)
                .load(ApiUrls.COMPANIES_IMAGE_URL+model.getCompany_logo())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(holder.companyImage);


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

