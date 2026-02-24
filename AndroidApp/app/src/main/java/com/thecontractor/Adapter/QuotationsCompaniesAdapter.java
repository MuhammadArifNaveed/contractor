package com.thecontractor.Adapter;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.QuotationsCompanyModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class QuotationsCompaniesAdapter extends RecyclerView.Adapter<QuotationsCompaniesAdapter.ViewHolder>  {

    private List<QuotationsCompanyModel> list;
    private Context mContext;
    private String selectedLanguage;
    private QuotationIdInterface quotationIdInterface;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView companyName;
        TextView categoryName;
        TextView status;
        TextView downloadFile;


        public ViewHolder(final View view) {
            super(view);

            companyName = (TextView) view.findViewById(R.id.companyName);
            categoryName = (TextView) view.findViewById(R.id.categoryName);

            status = (TextView) view.findViewById(R.id.status);
            downloadFile = (TextView) view.findViewById(R.id.downloadFile);
            downloadFile.setVisibility(View.GONE);


            downloadFile.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    quotationIdInterface.selectedQuotationId(list.get(pos).getId() , downloadFile.getText().toString() , list.get(pos).getDocument_path());
                }
            });






        }
    }


    public QuotationsCompaniesAdapter(Context context, List<QuotationsCompanyModel> list , String selectedLanguage, QuotationIdInterface quotationIdInterface) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.quotationIdInterface = quotationIdInterface;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.quotations_companies_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        QuotationsCompanyModel model = list.get(position);



        if(selectedLanguage.equals("en"))
        {
            holder.companyName.setText(model.getCompany_name());
            holder.categoryName.setText(model.getCategory_name());
            holder.status.setText(model.getStatus_name());

        }else
        {
            holder.companyName.setText(model.getCompany_arabic_name());
            holder.categoryName.setText(model.getCategory_arabic_name());
            holder.status.setText(model.getStatus_arabic_name());
        }


        if(model.getStatus_id().equals("5"))
        {
            if(model.getPayment_id() == null || model.getPayment_id().equals(""))
            {
                holder.downloadFile.setText("Pay to Download");
                holder.downloadFile.setVisibility(View.VISIBLE);

            }else
            {
                holder.downloadFile.setText("Download");
                holder.downloadFile.setVisibility(View.VISIBLE);
            }
        }



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


    public interface QuotationIdInterface
    {
        void selectedQuotationId(String id , String text , String path);
    }

}


