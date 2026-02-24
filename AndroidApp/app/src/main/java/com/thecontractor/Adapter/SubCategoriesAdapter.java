package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.thecontractor.Companies;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


public class SubCategoriesAdapter extends RecyclerView.Adapter<SubCategoriesAdapter.ViewHolder>  {

    private List<SubCategoriesModel> list;
    private Context mContext;
    private String from;
    int rowIndex = -1;
    private SubCategoryIdInterface subCategoryIdInterface;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        LinearLayout subCategoriesLayout;
        TextView subCategoriesTitle;



        public ViewHolder(final View view) {
            super(view);

            subCategoriesLayout = (LinearLayout) view.findViewById(R.id.subCategoriesLayout);
            subCategoriesTitle = (TextView) view.findViewById(R.id.subCategoriesTitle);

            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();
                    rowIndex = pos;

                    if(from.equals("true"))
                    {
                        Intent intent = new Intent(mContext , Companies.class);
                        intent.putExtra("categoryId" , list.get(pos).getCategory_id());
                        intent.putExtra("subCategoryId" , list.get(pos).getId());
                        intent.putExtra("subCategoryName" , list.get(pos).getName());
                        mContext.startActivity(intent);
                    }

                    subCategoryIdInterface.selectedSubCategoryId(list.get(pos).getId());

                    notifyDataSetChanged();
                }
            });
        }
    }


    public SubCategoriesAdapter(Context context, List<SubCategoriesModel> list , String from , SubCategoryIdInterface subCategoryIdInterface , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.from = from;
        this.subCategoryIdInterface = subCategoryIdInterface;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.sub_categories_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        SubCategoriesModel model = list.get(position);

        if(selectedLanguage.equals("en"))
        {
            holder.subCategoriesTitle.setText(model.getName());
        }else
        {
            holder.subCategoriesTitle.setText(model.getArabic_name());
        }


        if(position == rowIndex)
        {
            holder.subCategoriesLayout.setBackground(ContextCompat.getDrawable(mContext, R.drawable.green_button_sub_categories_bacground));
            holder.subCategoriesTitle.setTextColor(ContextCompat.getColor(mContext, R.color.white));
        }
        else
        {
            holder.subCategoriesLayout.setBackground(ContextCompat.getDrawable(mContext, R.drawable.outline_button_sub_categories_bacground));
            holder.subCategoriesTitle.setTextColor(ContextCompat.getColor(mContext, R.color.black));
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


    public interface SubCategoryIdInterface
    {
        void selectedSubCategoryId(String id);
    }

}

