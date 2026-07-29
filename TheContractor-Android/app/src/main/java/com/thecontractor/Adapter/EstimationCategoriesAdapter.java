package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.EstimationCategoriesModel;
import com.thecontractor.Model.EstimationSubCategoriesModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.R;

import java.util.ArrayList;
import java.util.List;


public class EstimationCategoriesAdapter extends RecyclerView.Adapter<EstimationCategoriesAdapter.ViewHolder>  {

    private List<EstimationCategoriesModel> list;
    private Context mContext;
    int rowIndex = 0;
    private EstimationSubCategoriesInterface estimationSubCategoriesInterface;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView categoriesTitle;
        View categoriesTitleView;



        public ViewHolder(final View view) {
            super(view);

            categoriesTitle = (TextView) view.findViewById(R.id.categoriesTitle);
            categoriesTitleView = (View) view.findViewById(R.id.categoriesTitleView);



            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();
                    rowIndex = pos;

                    notifyDataSetChanged();

                }
            });


        }
    }


    public EstimationCategoriesAdapter(Context context, List<EstimationCategoriesModel> list , EstimationSubCategoriesInterface estimationSubCategoriesInterface , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.estimationSubCategoriesInterface = estimationSubCategoriesInterface;
        this.selectedLanguage = selectedLanguage;
    }

    public void setItems(List<EstimationCategoriesModel> list) {
        this.list.clear();
        this.list = list;
        notifyDataSetChanged();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.estimation_categories_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        EstimationCategoriesModel model = list.get(position);

        if(selectedLanguage.equals("en"))
        {
            holder.categoriesTitle.setText(model.getName());
        }else
        {
            holder.categoriesTitle.setText(model.getArabic_name());
        }


        if(position == rowIndex)
        {

            if(selectedLanguage.equals("en"))
            {
                estimationSubCategoriesInterface.selectedEstimationSubCategories(model.getSub_categories() , model.getId() , model.getName());
            }else
            {
                estimationSubCategoriesInterface.selectedEstimationSubCategories(model.getSub_categories() , model.getId() , model.getArabic_name());
            }


            holder.categoriesTitleView.setBackground(ContextCompat.getDrawable(mContext, R.drawable.green_button_bacground));
            holder.categoriesTitle.setTextColor(ContextCompat.getColor(mContext, R.color.green));
        }
        else
        {
            holder.categoriesTitleView.setBackground(ContextCompat.getDrawable(mContext, R.drawable.outline_button_bacground));
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


    public interface EstimationSubCategoriesInterface
    {
        void selectedEstimationSubCategories(ArrayList<EstimationSubCategoriesModel> sub_categories, String categoryId , String categoryName);
    }
}

