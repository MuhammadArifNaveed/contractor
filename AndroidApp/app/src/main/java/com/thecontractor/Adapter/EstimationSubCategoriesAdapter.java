package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.EstimationSubCategoriesModel;
import com.thecontractor.R;

import java.util.List;


public class EstimationSubCategoriesAdapter extends RecyclerView.Adapter<EstimationSubCategoriesAdapter.ViewHolder>  {

    private List<EstimationSubCategoriesModel> list;
    private Context mContext;
    int rowIndex = -1;
    private EstimationSubCategoryIdInterface estimationSubCategoryIdInterface;
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

                    if(selectedLanguage.equals("en"))
                    {
                        estimationSubCategoryIdInterface.selectedEstimationSubCategoryId(list.get(pos).getId() , list.get(pos).getName() , list.get(pos).getMin_val());
                    }else
                    {
                        estimationSubCategoryIdInterface.selectedEstimationSubCategoryId(list.get(pos).getId() , list.get(pos).getArabic_name() , list.get(pos).getMin_val());
                    }


                    notifyDataSetChanged();
                }
            });
        }
    }


    public EstimationSubCategoriesAdapter(Context context, List<EstimationSubCategoriesModel> list  , EstimationSubCategoryIdInterface estimationSubCategoryIdInterface , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.estimationSubCategoryIdInterface = estimationSubCategoryIdInterface;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.estimation_sub_categories_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        EstimationSubCategoriesModel model = list.get(position);

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


    public interface EstimationSubCategoryIdInterface
    {
        void selectedEstimationSubCategoryId(String id, String name, String value);
    }

}

