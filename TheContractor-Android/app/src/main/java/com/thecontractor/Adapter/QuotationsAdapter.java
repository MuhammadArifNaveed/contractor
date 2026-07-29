package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.Model.QuotationModel;
import com.thecontractor.Model.QuotationModel;
import com.thecontractor.QuotationsDetails;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class QuotationsAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<QuotationModel> list;
    private Context mContext;
    private String selectedLanguage;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;

    public class ItemVH extends RecyclerView.ViewHolder {


        TextView category;
        TextView subCategory;
        TextView quotationNO;
        TextView createdAt;
        TextView quotationStatus;


        public ItemVH(final View view) {
            super(view);

            category = (TextView) view.findViewById(R.id.category);
            subCategory = (TextView) view.findViewById(R.id.subCategory);
            quotationNO = (TextView) view.findViewById(R.id.quotationNO);
            createdAt = (TextView) view.findViewById(R.id.createdAt);
            quotationStatus = (TextView) view.findViewById(R.id.quotationStatus);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();
                    QuotationModel quotationModel = list.get(pos);

                    Intent intent = new Intent(mContext , QuotationsDetails.class);
                    Bundle b = new Bundle();
                    b.putString("id", quotationModel.getId());
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



    public QuotationsAdapter(Context context, List<QuotationModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {



        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.quotation_custom_row, parent, false);
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

        QuotationModel model = list.get(position);


        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                itemVH.createdAt.setText(parseDateToddMMyyyy(model.getCreated_at()));

                if(selectedLanguage.equals("en"))
                {
                    itemVH.category.setText(model.getCate_name());
                    itemVH.subCategory.setText(model.getSub_cat_name());
                    itemVH.quotationStatus.setText(model.getStatus_name());
                }else
                {

                    itemVH.category.setText(model.getCategory_arabic_name());
                    itemVH.subCategory.setText(model.getSub_category_arabic_name());
                    itemVH.quotationStatus.setText(model.getStatus_arabic_name());
                }


                itemVH.quotationNO.setText(model.getQuotation_number());


                ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                        .toBuilder()
                        .setAllCorners(CornerFamily.ROUNDED,5)
                        .build();

                MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
                shapeDrawable.setPadding(10 , 5 , 10 , 5);

                shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(model.getColor())));
                ViewCompat.setBackground(itemVH.quotationStatus,shapeDrawable);


                break;
            case LOADING:
//                 Do nothing
                break;
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
        return list == null ? 0 : list.size();

    }


    @Override
    public int getItemViewType(int position) {
        return (position == list.size() - 1 && isLoadingAdded) ? LOADING : ITEM;
    }

    public void add(QuotationModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<QuotationModel> moveResults) {
        for (QuotationModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new QuotationModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        QuotationModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public QuotationModel getItem(int position) {
        return list.get(position);
    }



}

