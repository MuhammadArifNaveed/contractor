package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Companies;
import com.thecontractor.Model.AreaModel;
import com.thecontractor.Model.AreaModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class AreasAdapter extends RecyclerView.Adapter<AreasAdapter.ViewHolder>  {

    private List<AreaModel> list;
    private Context mContext;
    int rowIndex = -1;
    private AreaIdInterface areaIdInterface;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        LinearLayout areaLayout;
        TextView areaTitle;



        public ViewHolder(final View view) {
            super(view);

            areaLayout = (LinearLayout) view.findViewById(R.id.areaLayout);
            areaTitle = (TextView) view.findViewById(R.id.areaTitle);

            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();
                    rowIndex = pos;

                    areaIdInterface.selectedAreaId(list.get(pos).getArea_id());

                    notifyDataSetChanged();
                }
            });
        }
    }


    public AreasAdapter(Context context, List<AreaModel> list , AreaIdInterface areaIdInterface , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.areaIdInterface = areaIdInterface;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.areas_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        AreaModel model = list.get(position);

        if(selectedLanguage.equals("en"))
        {
            holder.areaTitle.setText(model.getArea_name());
        }else
        {
            holder.areaTitle.setText(model.getArabic_name());
        }


        if(position == rowIndex)
        {
            holder.areaLayout.setBackground(ContextCompat.getDrawable(mContext, R.drawable.green_button_sub_categories_bacground));
            holder.areaTitle.setTextColor(ContextCompat.getColor(mContext, R.color.white));
        }
        else
        {
            holder.areaLayout.setBackground(ContextCompat.getDrawable(mContext, R.drawable.outline_button_sub_categories_bacground));
            holder.areaTitle.setTextColor(ContextCompat.getColor(mContext, R.color.black));
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


    public interface AreaIdInterface
    {
        void selectedAreaId(String id);
    }

}

