package com.thecontractor.Adapter;

import android.app.Activity;
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

import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.ComplaintDetail;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.Model.ComplaintModel;
import com.thecontractor.Model.EnquiryModel;
import com.thecontractor.R;
import com.thecontractor.SubCategories;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class ComplaintsAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<ComplaintModel> list;
    private Context mContext;
    private String selectedLanguage;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;

    public class ItemVH extends RecyclerView.ViewHolder {

        ImageView companyImage;
        TextView companyName;
        TextView companyCategory;
        TextView complaintNo;
        TextView status;


        public ItemVH(final View view) {
            super(view);

            companyImage = (ImageView) view.findViewById(R.id.companyImage);
            companyName = (TextView) view.findViewById(R.id.companyName);
            companyCategory = (TextView) view.findViewById(R.id.companyCategory);
            complaintNo = (TextView) view.findViewById(R.id.complaintNo);


            status = (TextView) view.findViewById(R.id.status);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    ComplaintModel complaintModel = list.get(pos);
                    Intent intent = new Intent(mContext , ComplaintDetail.class);
                    Bundle b = new Bundle();
                    b.putString("id", complaintModel.getId());
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



    public ComplaintsAdapter(Context context, List<ComplaintModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {



        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.complaints_custom_row, parent, false);
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

        ComplaintModel model = list.get(position);


        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;


                Glide.with(mContext)
                        .load(ApiUrls.COMPANIES_IMAGE_URL+model.getCompany_logo())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.companyImage);

                itemVH.complaintNo.setText(mContext.getResources().getString(R.string.complaint_no)+" : "+model.getComplaint_id());

                if(selectedLanguage.equals("en"))
                {
                    itemVH.companyName.setText(model.getCompany_name());
                    itemVH.companyCategory.setText(model.getCompany_category());
                    itemVH.status.setText(model.getStatus_name());

                }else
                {

                    itemVH.companyName.setText(model.getCompany_arabic_address());
                    itemVH.companyCategory.setText(model.getCategory_arabic_name());
                    itemVH.status.setText(model.getStatus_arabic_name());

                }




                ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                        .toBuilder()
                        .setAllCorners(CornerFamily.ROUNDED,5)
                        .build();

                MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
                shapeDrawable.setPadding(5 , 5 , 5 , 5);

                shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(model.getStatus_color())));
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

    public void add(ComplaintModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<ComplaintModel> moveResults) {
        for (ComplaintModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new ComplaintModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        ComplaintModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public ComplaintModel getItem(int position) {
        return list.get(position);
    }


}

