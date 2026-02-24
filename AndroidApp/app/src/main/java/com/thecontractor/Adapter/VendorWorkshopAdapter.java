package com.thecontractor.Adapter;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
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
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.WorkshopAdModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorMembership;
import com.thecontractor.VendorActivities.VendorMyMembership;
import com.thecontractor.VendorActivities.VendorWorkshopDetail;
import com.thecontractor.WorkshopAdDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;


public class VendorWorkshopAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>  {

    private List<WorkshopAdModel> list;
    private Context mContext;
    private String selectedLanguage;
    private String viewMembership;

    private static final int ITEM = 0;
    private static final int LOADING = 1;
    private boolean isLoadingAdded = false;

    public class ItemVH extends RecyclerView.ViewHolder {


        ImageView workShopImage;
        TextView workshopAdUserName;
        TextView workshopAdDateTime;
        TextView workshopAdTitle;
        TextView workshopAdDescription;
        TextView workshopAdCategory;
        TextView workshopAdSubCategory;


        public ItemVH(final View view) {
            super(view);

            workShopImage = (ImageView) view.findViewById(R.id.workShopImage);
            workshopAdUserName = (TextView) view.findViewById(R.id.workshopAdUserName);
            workshopAdDateTime = (TextView) view.findViewById(R.id.workshopAdDateTime);
            workshopAdTitle = (TextView) view.findViewById(R.id.workshopAdTitle);
            workshopAdDescription = (TextView) view.findViewById(R.id.workshopAdDescription);
            workshopAdCategory = (TextView) view.findViewById(R.id.workshopAdCategory);
            workshopAdSubCategory = (TextView) view.findViewById(R.id.workshopAdSubCategory);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    Log.e("tag" , "view is : "+viewMembership);

                    if(viewMembership.equals("false"))
                    {
                        buyWorkshopMemberShipDialog();
                    }else
                    {
                        int pos = getAdapterPosition();
                        WorkshopAdModel workshopAdModel = list.get(pos);

                        Intent intent = new Intent(mContext , VendorWorkshopDetail.class);
                        Bundle b = new Bundle();
                        b.putString("id", workshopAdModel.getId());
                        intent.putExtras(b);
                        mContext.startActivity(intent);
                    }
                }

            });



        }
    }

    public void buyWorkshopMemberShipDialog()
    {
        Dialog dialog = new Dialog(mContext);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.workshop_not_buy_membership_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        Button buyNow = dialog.findViewById(R.id.buyNow);
        Button close = dialog.findViewById(R.id.close);

        buyNow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                dialog.dismiss();

                Intent intent = new Intent(mContext , VendorMyMembership.class);
                mContext.startActivity(intent);

            }
        });


        close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                dialog.dismiss();

            }
        });



    }


    protected class LoadingVH extends RecyclerView.ViewHolder {
        ProgressBar load_more_progress;
        public LoadingVH(View itemView) {
            super(itemView);
            load_more_progress = (ProgressBar) itemView.findViewById(R.id.load_more_progress);
        }
    }





    public VendorWorkshopAdapter(Context context, List<WorkshopAdModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {



        if (viewType == ITEM) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_workshop_ad_custom_row, parent, false);
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

        WorkshopAdModel model = list.get(position);


        switch (getItemViewType(position)) {
            case ITEM:
                final ItemVH itemVH = (ItemVH) holder;


                Glide.with(mContext)
                        .load(ApiUrls.WORKSHOP_IMAGE_URL+model.getImage_path())
                        .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                        .into(itemVH.workShopImage);

                itemVH.workshopAdUserName.setText(model.getName() + " " + model.getSurname());
                itemVH.workshopAdDateTime.setText(covertTimeToTextTe(model.getCreated_at()));
                itemVH.workshopAdTitle.setText(model.getTitle());
                itemVH.workshopAdDescription.setText(model.getDescription());



                if(selectedLanguage.equals("en"))
                {
                    itemVH.workshopAdCategory.setText(model.getCategory_name());
                    itemVH.workshopAdSubCategory.setText(model.getSub_category_name());

                }else
                {
                    itemVH.workshopAdCategory.setText(model.getCategory_arabic_name());
                    itemVH.workshopAdSubCategory.setText(model.getArabic_sub_category_name());
                }





                break;
            case LOADING:
//                 Do nothing
                break;
        }





    }

    public String covertTimeToTextTe(String dataDate) {

        String convertTime = null;
        String suffix = "ago";

        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
            Date pasTime = dateFormat.parse(dataDate);

            Date nowTime = new Date();

            long dateDiff = nowTime.getTime() - pasTime.getTime();

            long second = TimeUnit.MILLISECONDS.toSeconds(dateDiff);
            long minute = TimeUnit.MILLISECONDS.toMinutes(dateDiff);
            long hour = TimeUnit.MILLISECONDS.toHours(dateDiff);
            long day = TimeUnit.MILLISECONDS.toDays(dateDiff);

            if (second < 60) {
                if (second == 1) {
                    convertTime = second + " second " + suffix;
                } else {
                    convertTime = second + " seconds " + suffix;
                }
            } else if (minute < 60) {
                if (minute == 1) {
                    convertTime = minute + " minute " + suffix;
                } else {
                    convertTime = minute + " minutes " + suffix;
                }
            } else if (hour < 24) {
                if (hour == 1) {
                    convertTime = hour + " hour " + suffix;
                } else {
                    convertTime = hour + " hours " + suffix;
                }
            } else if (day >= 7) {
                if (day >= 365) {
                    long tempYear = day / 365;
                    if (tempYear == 1) {
                        convertTime = tempYear + " year " + suffix;
                    } else {
                        convertTime = tempYear + " years " + suffix;
                    }
                } else if (day >= 30) {
                    long tempMonth = day / 30;
                    if (tempMonth == 1) {
                        convertTime = (day / 30) + " month " + suffix;
                    } else {
                        convertTime = (day / 30) + " months " + suffix;
                    }
                } else {
                    long tempWeek = day / 7;
                    if (tempWeek == 1) {
                        convertTime = (day / 7) + " week " + suffix;
                    } else {
                        convertTime = (day / 7) + " weeks " + suffix;
                    }
                }
            } else {
                if (day == 1) {
                    convertTime = day + " day " + suffix;
                } else {
                    convertTime = day + " days " + suffix;
                }
            }

        } catch (ParseException e) {
            e.printStackTrace();
            Log.e("TimeAgo", e.getMessage() + "");
        }
        return convertTime;
    }

    public String covertTimeToText(String dataDate) {

        String convTime = null;

        String prefix = "";
        String suffix = "Ago";

        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-dd-MM HH:mm:ss");
            Date pasTime = dateFormat.parse(dataDate);

            Date nowTime = new Date();

            long dateDiff = nowTime.getTime() - pasTime.getTime();

            long second = TimeUnit.MILLISECONDS.toSeconds(dateDiff);
            long minute = TimeUnit.MILLISECONDS.toMinutes(dateDiff);
            long hour   = TimeUnit.MILLISECONDS.toHours(dateDiff);
            long day  = TimeUnit.MILLISECONDS.toDays(dateDiff);

            if (second < 60) {
                convTime = second + " Seconds " + suffix;
            } else if (minute < 60) {
                convTime = minute + " Minutes "+suffix;
            } else if (hour < 24) {
                convTime = hour + " Hours "+suffix;
            } else if (day >= 7) {
                if (day > 360) {
                    convTime = (day / 360) + " Years " + suffix;
                } else if (day > 30) {
                    convTime = (day / 30) + " Months " + suffix;
                } else {
                    convTime = (day / 7) + " Week " + suffix;
                }
            } else if (day < 7) {
                convTime = day+" Days "+suffix;
            }

        } catch (ParseException e) {
            e.printStackTrace();
            Log.e("tag" , "ConvTimeE : " + e.getMessage());
        }

        return convTime;
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

    public void add(WorkshopAdModel r) {
        list.add(r);


        notifyItemInserted(list.size() - 1);
    }

    public void addAll(List<WorkshopAdModel> moveResults , String view) {
        this.viewMembership = view;
        for (WorkshopAdModel result : moveResults) {
            add(result);
        }
    }

    public void addLoadingFooter() {
        isLoadingAdded = true;
        add(new WorkshopAdModel());
    }

    public void removeLoadingFooter() {
        isLoadingAdded = false;

        int position = list.size() - 1;
        WorkshopAdModel result = getItem(position);

        if (result != null) {
            list.remove(position);
            notifyItemRemoved(position);
        }
    }

    public WorkshopAdModel getItem(int position) {
        return list.get(position);
    }



}

