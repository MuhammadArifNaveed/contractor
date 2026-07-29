package com.thecontractor.Adapter;

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
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.EnquiryDetail;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.EnquiryModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class EnquiriesAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<EnquiryModel> list;
    private Context mContext;
    private String selectedLanguage;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;

    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView companyImage;
        TextView companyName;
        TextView categoryName;
        TextView createdAt;
        TextView status;


        public ItemVH(final View view) {
            super(view);

            companyImage = (ImageView) view.findViewById(R.id.companyImage);
            companyName = (TextView) view.findViewById(R.id.companyName);
            categoryName = (TextView) view.findViewById(R.id.categoryName);
            createdAt = (TextView) view.findViewById(R.id.createdAt);

            status = (TextView) view.findViewById(R.id.status);



            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    EnquiryModel enquiryModel = list.get(pos);
                    Intent intent = new Intent(mContext , EnquiryDetail.class);
                    Bundle b = new Bundle();
                    b.putString("id", enquiryModel.getId());
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



    public EnquiriesAdapter(Context context, List<EnquiryModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.enquiry_custom_row, parent, false);
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

        EnquiryModel model = list.get(position);

        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;

                Glide.with(mContext)
                        .load(ApiUrls.COMPANIES_IMAGE_URL+model.getCompany_logo())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.companyImage);

                if(selectedLanguage.equals("en"))
                {
                    itemVH.companyName.setText(model.getCompany_name());
                    itemVH.categoryName.setText(model.getCategory_name());
                    itemVH.status.setText(model.getS_name());

                }else
                {
                    itemVH.companyName.setText(model.getCompany_arabic_name());
                    itemVH.categoryName.setText(model.getCategory_arabic_name());
                    itemVH.status.setText(model.getS_arabic_name());
                }


                itemVH.createdAt.setText(parseDateToddMMyyyy(model.getCreated_at()));



                ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                        .toBuilder()
                        .setAllCorners(CornerFamily.ROUNDED,5)
                        .build();

                MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
                shapeDrawable.setPadding(10 , 5 , 10 , 5);

                shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(model.getS_color())));
                ViewCompat.setBackground(itemVH.status,shapeDrawable);


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

    public void add(EnquiryModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<EnquiryModel> moveResults) {
        for (EnquiryModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new EnquiryModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        EnquiryModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public EnquiryModel getItem(int position) {
        return list.get(position);
    }




}

