package com.thecontractor.Adapter;

import android.app.Activity;
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
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.thecontractor.CompanyDetails;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.R;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;


public class CompaniesAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<CompaniesModel> list;
    private Context mContext;
    private String selectedLanguage;
    DatabaseHandler databaseHandler;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;


    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView companyImage;
        TextView companyName;
        TextView area;
        TextView city;
        TextView sinceEmployee;
        TextView categoriesName;
        TextView companyTotalRatingCount;
        ImageView verified;
        ImageView twentyFourSeven;
        ImageView trusted;
        ImageView vip;
        RatingBar ratingBar;
        Button selectOrRemoveBtn;


        public ItemVH(final View view) {
            super(view);

            companyImage = (ImageView) view.findViewById(R.id.companyImage);
            companyName = (TextView) view.findViewById(R.id.companyName);
            area = (TextView) view.findViewById(R.id.area);
            city = (TextView) view.findViewById(R.id.city);
            sinceEmployee = (TextView) view.findViewById(R.id.sinceEmployee);
            categoriesName = (TextView) view.findViewById(R.id.categoriesName);
            companyTotalRatingCount = (TextView) view.findViewById(R.id.companyTotalRatingCount);
            verified = (ImageView) view.findViewById(R.id.verified);
            twentyFourSeven = (ImageView) view.findViewById(R.id.twentyFourSeven);
            trusted = (ImageView) view.findViewById(R.id.trusted);
            vip = (ImageView) view.findViewById(R.id.vip);
            ratingBar = (RatingBar) view.findViewById(R.id.ratingBar);
            selectOrRemoveBtn = (Button) view.findViewById(R.id.selectOrRemoveBtn);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    CompaniesModel companyModel = list.get(pos);

                    Intent intent = new Intent(mContext , CompanyDetails.class);
                    Bundle b = new Bundle();
                    b.putString("companyId", companyModel.getId());
                    b.putString("averageRating", companyModel.getAvg_rating());
                    b.putString("companyReviewCount", companyModel.getReview_count());
                    intent.putExtras(b);
                    mContext.startActivity(intent);

                }

            });

            selectOrRemoveBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();


                    if(selectOrRemoveBtn.getText().toString().equals(mContext.getResources().getString(R.string.remove_company)))
                    {

                        databaseHandler.removeItemFromCart(list.get(pos).getId());
                        selectOrRemoveBtn.setText(mContext.getResources().getString(R.string.select_company));
                        selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(mContext, R.drawable.button_bacground));
                        selectOrRemoveBtn.setTextColor(ContextCompat.getColor(mContext, R.color.black));

                    }
                    else
                    {

                        Log.e("tag" , "cart count is : "+databaseHandler.getCartCount());


                        int usedLimit = SharedPrefManager.getInstance(mContext).getCartLimit() - SharedPrefManager.getInstance(mContext).getCartAvailableLimit();

                        if(databaseHandler.getCartCount() >= SharedPrefManager.getInstance(mContext).getCartAvailableLimit())
                        {
                            if(SharedPrefManager.getInstance(mContext).getCartAvailableLimit() == 0)
                            {
                                Toast.makeText(mContext, mContext.getResources().getString(R.string.your_today_enquiries_limit), Toast.LENGTH_SHORT).show();

                            }else {
                                Toast.makeText(mContext, mContext.getResources().getString(R.string.you_can_select) + SharedPrefManager.getInstance(mContext).getCartAvailableLimit() + mContext.getResources().getString(R.string.you_can_select_companies), Toast.LENGTH_SHORT).show();
                            }

                        }else
                        {
                            HashMap<String, String> map = new HashMap<>();
                            map.put("company_id",list.get(pos).getId());
                            map.put("company_name",list.get(pos).getCompany_name());
                            map.put("company_arabic_name",list.get(pos).getCompany_arabic_name());
                            map.put("company_image",list.get(pos).getCompany_logo());
                            map.put("company_categories",list.get(pos).getCategory_name());
                            map.put("company_arabic_categories",list.get(pos).getCategory_arabic_name());
                            map.put("company_review_count",list.get(pos).getReview_count());
                            map.put("company_rating",list.get(pos).getAvg_rating());
                            map.put("company_verified",list.get(pos).getIs_verified());


                            if(databaseHandler.setCart(map))
                            {
                                selectOrRemoveBtn.setText(mContext.getResources().getString(R.string.remove_company));
                                selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(mContext, R.drawable.red_button_bacground));
                                selectOrRemoveBtn.setTextColor(ContextCompat.getColor(mContext, R.color.white));

                            }
                            else
                            {
                                Toast.makeText(mContext, "Something wrong company not selected", Toast.LENGTH_SHORT).show();
                            }
                        }


                    }

                    //notifyDataSetChanged();
                    updateValueIntent();

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


    public CompaniesAdapter(Context context, List<CompaniesModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        databaseHandler = new DatabaseHandler(context);

    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.companies_custom_row, parent, false);
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

        CompaniesModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                Glide.with(mContext)
                        .load(ApiUrls.COMPANIES_IMAGE_URL+model.getCompany_logo())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.companyImage);

                String sinceNoOFEmployee = "";

                if(!model.getCompany_since().equals(""))
                {
                   sinceNoOFEmployee =  "Since: "+ model.getCompany_since() + " - ";
                }

                String s = sinceNoOFEmployee + "Employee: " + model.getCompany_employees();

                itemVH.sinceEmployee.setText(s);

                if(selectedLanguage.equals("en"))
                {
                    itemVH.companyName.setText(model.getCompany_name());
                    itemVH.categoriesName.setText(model.getCategory_name());
                    itemVH.area.setText(model.getArea_name());
                    itemVH.city.setText(model.getCity_name());

                }else
                {
                    itemVH.companyName.setText(model.getCompany_arabic_name());
                    itemVH.categoriesName.setText(model.getCategory_arabic_name());
                    itemVH.area.setText(model.getArea_arabic_name());
                    itemVH.city.setText(model.getCity_arabic_name());
                }

                itemVH.companyTotalRatingCount.setText("("+model.getReview_count()+")");

                if(model.getAvg_rating() != null)
                {
                    itemVH.ratingBar.setRating(Float.parseFloat(model.getAvg_rating()));
                }
                else
                {
                    itemVH.ratingBar.setRating(0);
                }

                if(model.getIs_verified().equals("1"))
                {
                    itemVH.verified.setVisibility(View.VISIBLE);
                }
                else
                {
                    itemVH.verified.setVisibility(View.GONE);
                }

                if(model.getCompany_for_24_hours().equals("1"))
                {
                    itemVH.twentyFourSeven.setVisibility(View.VISIBLE);
                }
                else
                {
                    itemVH.twentyFourSeven.setVisibility(View.GONE);
                }

                if(model.getIs_trusted() != null){
                    if(model.getIs_trusted().equals("1"))
                    {
                        itemVH.trusted.setVisibility(View.VISIBLE);
                    }
                    else
                    {
                        itemVH.trusted.setVisibility(View.GONE);
                    }
                }


                if(model.getIs_vip() != null) {

                    if(model.getIs_vip().equals("1"))
                    {
                        itemVH.vip.setVisibility(View.VISIBLE);
                    }
                    else
                    {
                        itemVH.vip.setVisibility(View.GONE);
                    }
                }



                if (databaseHandler.isInCart(model.getId())) {
                    itemVH.selectOrRemoveBtn.setText(mContext.getResources().getString(R.string.remove_company));
                    itemVH.selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(mContext, R.drawable.red_button_bacground));
                    itemVH.selectOrRemoveBtn.setTextColor(ContextCompat.getColor(mContext, R.color.white));

                }
                else
                {
                    itemVH.selectOrRemoveBtn.setText(mContext.getResources().getString(R.string.select_company));
                    itemVH.selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(mContext, R.drawable.button_bacground));
                    itemVH.selectOrRemoveBtn.setTextColor(ContextCompat.getColor(mContext, R.color.black));

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

    public void add(CompaniesModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<CompaniesModel> moveResults) {
        for (CompaniesModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new CompaniesModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        CompaniesModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public CompaniesModel getItem(int position) {
        return list.get(position);
    }

    private void updateValueIntent() {
        Intent updates = new Intent("update");
        updates.putExtra("type", "update_value");
        mContext.sendBroadcast(updates);
    }

}

