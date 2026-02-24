package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.cardview.widget.CardView;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.VendorEnquiryModel;
import com.thecontractor.Model.VendorQuotationModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorQuotationDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class VendorQuotationAdapter extends RecyclerView.Adapter<VendorQuotationAdapter.ViewHolder>  {

    private List<VendorQuotationModel> list;
    private Context mContext;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        CardView vendorEnquiryCard;
        TextView quotationNumber;
        TextView createdAt;
        TextView status;


        public ViewHolder(final View view) {
            super(view);


            vendorEnquiryCard = (CardView) view.findViewById(R.id.vendorEnquiryCard);

            quotationNumber = (TextView) view.findViewById(R.id.quotationNumber);
            createdAt = (TextView) view.findViewById(R.id.createdAt);
            status = (TextView) view.findViewById(R.id.status);



            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    VendorQuotationModel vendorQuotationModel = list.get(pos);
                    Intent intent = new Intent(mContext , VendorQuotationDetail.class);
                    Bundle b = new Bundle();
                    b.putString("id", vendorQuotationModel.getId());
                    intent.putExtras(b);
                    mContext.startActivity(intent);
                }
            });

        }
    }


    public VendorQuotationAdapter(Context context, List<VendorQuotationModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.vendor_quotation_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        VendorQuotationModel model = list.get(position);




        holder.quotationNumber.setText(model.getQuotation_number());
        holder.status.setText(model.getStatus_name());
        holder.createdAt.setText(parseDateToddMMyyyy(model.getCreated_at()));



        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(model.getColor())));
        ViewCompat.setBackground( holder.status,shapeDrawable);

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

