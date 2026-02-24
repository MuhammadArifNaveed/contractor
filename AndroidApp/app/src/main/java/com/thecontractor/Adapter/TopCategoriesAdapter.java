package com.thecontractor.Adapter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.CompaniesByCategory;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.R;
import com.thecontractor.SubCategories;

import java.util.List;


public class TopCategoriesAdapter extends RecyclerView.Adapter<TopCategoriesAdapter.ViewHolder>  {

    private List<CategoriesModel> list;
    private Context mContext;
    private String selectedLanguage;
    int rowIndex = -1;



    public class ViewHolder extends RecyclerView.ViewHolder {

        LinearLayout topCategoriesLayout;
        TextView categoriesTitle;



        public ViewHolder(final View view) {
            super(view);

            topCategoriesLayout = (LinearLayout) view.findViewById(R.id.topCategoriesLayout);
            categoriesTitle = (TextView) view.findViewById(R.id.categoriesTitle);



            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    rowIndex = pos;

                    CategoriesModel categoriesModel = list.get(pos);
                    //Intent intent = new Intent(mContext , SubCategories.class);
                    Intent intent = new Intent(mContext , CompaniesByCategory.class);
                    Bundle b = new Bundle();
                    b.putParcelable("categoriesModel", categoriesModel);
                    intent.putExtras(b);
                    ((Activity) mContext).startActivityForResult(intent,500);
                    //mContext.startActivity(intent);
                    notifyDataSetChanged();

                }
            });


        }
    }


    public TopCategoriesAdapter(Context context, List<CategoriesModel> list ,String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    public void setItems(List<CategoriesModel> list) {
        this.list.clear();
        this.list = list;
        notifyDataSetChanged();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.top_categories_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        CategoriesModel model = list.get(position);

        if(selectedLanguage.equals("en"))
        {
            holder.categoriesTitle.setText(model.getName());
        }else
        {
            holder.categoriesTitle.setText(model.getArabic_name());
        }

        if(position == rowIndex)
        {
            holder.topCategoriesLayout.setBackground(ContextCompat.getDrawable(mContext, R.drawable.top_category_button_bacground));
            holder.categoriesTitle.setTextColor(ContextCompat.getColor(mContext, R.color.white));
        }
        else
        {
            holder.topCategoriesLayout.setBackground(ContextCompat.getDrawable(mContext, R.drawable.outline_button_bacground));
            holder.categoriesTitle.setTextColor(ContextCompat.getColor(mContext, R.color.black));
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


}

