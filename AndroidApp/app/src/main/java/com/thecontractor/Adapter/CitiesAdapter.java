package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.AreaModel;
import com.thecontractor.Model.CitiesModel;
import com.thecontractor.R;


import java.util.ArrayList;
import java.util.List;


public class CitiesAdapter extends RecyclerView.Adapter<CitiesAdapter.ViewHolder>  {

    private List<CitiesModel> list;
    private Context mContext;
    int rowIndex = -1;
    private AreasInterface areasInterface;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView cityTitle;
        View cityTitleView;



        public ViewHolder(final View view) {
            super(view);

            cityTitle = (TextView) view.findViewById(R.id.cityTitle);
            cityTitleView = (View) view.findViewById(R.id.cityTitleView);



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


    public CitiesAdapter(Context context, List<CitiesModel> list , AreasInterface areasInterface , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.areasInterface = areasInterface;
        this.selectedLanguage = selectedLanguage;
    }


    public CitiesAdapter(Context context, List<CitiesModel> list, String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }



    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.cities_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        CitiesModel model = list.get(position);

        if(selectedLanguage.equals("en"))
        {
            holder.cityTitle.setText(model.getName());
        }else
        {
            holder.cityTitle.setText(model.getArabic_name());
        }

        if(position == rowIndex)
        {
            areasInterface.selectedAreas(model.getAreas() , model.getId());

            holder.cityTitleView.setBackground(ContextCompat.getDrawable(mContext, R.drawable.green_button_bacground));
            holder.cityTitle.setTextColor(ContextCompat.getColor(mContext, R.color.green));
        }
        else
        {
            holder.cityTitleView.setBackground(ContextCompat.getDrawable(mContext, R.drawable.outline_button_bacground));
            holder.cityTitle.setTextColor(ContextCompat.getColor(mContext, R.color.black));
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


    public interface AreasInterface
    {

        void selectedAreas(ArrayList<AreaModel> areas, String cityId);
    }
}

