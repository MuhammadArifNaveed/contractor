package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Companies;
import com.thecontractor.Model.CompanyDetailSubCategoriesModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class CompanyDetailSubCategoriesAdapter extends RecyclerView.Adapter<CompanyDetailSubCategoriesAdapter.ViewHolder>  {

    private List<CompanyDetailSubCategoriesModel> list;
    private Context mContext;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView subCategoriesTitle;



        public ViewHolder(final View view) {
            super(view);

            subCategoriesTitle = (TextView) view.findViewById(R.id.subCategoriesTitle);


        }
    }


    public CompanyDetailSubCategoriesAdapter(Context context, List<CompanyDetailSubCategoriesModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.company_detail_sub_categories_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        CompanyDetailSubCategoriesModel model = list.get(position);

        if(selectedLanguage.equals("en"))
        {
            holder.subCategoriesTitle.setText(model.getName());


        }else
        {
            holder.subCategoriesTitle.setText(model.getArabic_name());

        }



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



    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "HH:mm:ss";
        String outputPattern = "h:mm a";
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

}

