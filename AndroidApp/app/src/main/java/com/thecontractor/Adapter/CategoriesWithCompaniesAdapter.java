package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.CategoriesWithCompaniesModel;
import com.thecontractor.R;

import java.util.List;


public class CategoriesWithCompaniesAdapter extends RecyclerView.Adapter<CategoriesWithCompaniesAdapter.ViewHolder>  {

    private List<CategoriesWithCompaniesModel> list;
    private Context mContext;
    String selectedLanguage;

    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView categoriesTitle;

        RecyclerView rvCompanies;
        LinearLayoutManager linearLayoutManager ;

        public ViewHolder(final View view) {
            super(view);

            categoriesTitle = (TextView) view.findViewById(R.id.categoriesTitle);

            rvCompanies = (RecyclerView) view.findViewById(R.id.rvCompanies);
            linearLayoutManager = new LinearLayoutManager(mContext ,  LinearLayoutManager.VERTICAL , false);
            rvCompanies.setLayoutManager(linearLayoutManager);


        }
    }


    public CategoriesWithCompaniesAdapter(Context context, List<CategoriesWithCompaniesModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.categories_with_companies_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        CategoriesWithCompaniesModel model = list.get(position);


        if(selectedLanguage.equals("en"))
        {
            holder.categoriesTitle.setText(model.getCategory_name() + " "+ mContext.getResources().getString(R.string.companies));
        }else
        {
            holder.categoriesTitle.setText(model.getCategory_arabic_name() + " "+ mContext.getResources().getString(R.string.companies));
        }



        CompaniesAdapter companiesAdapter = new CompaniesAdapter(mContext , model.getCompanies() , selectedLanguage);
        holder.rvCompanies.setAdapter(companiesAdapter);

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

