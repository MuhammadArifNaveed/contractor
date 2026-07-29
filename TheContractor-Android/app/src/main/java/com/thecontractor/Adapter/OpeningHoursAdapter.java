package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import com.thecontractor.Model.OpeningHoursModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class OpeningHoursAdapter extends RecyclerView.Adapter<OpeningHoursAdapter.ViewHolder>  {

    private List<OpeningHoursModel> list;
    private Context mContext;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView timing;
        TextView timingDay;


        public ViewHolder(final View view) {
            super(view);

            timing = (TextView) view.findViewById(R.id.timing);
            timingDay = (TextView) view.findViewById(R.id.timingDay);




        }
    }


    public OpeningHoursAdapter(Context context, List<OpeningHoursModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.opening_hours_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        OpeningHoursModel model = list.get(position);

        if(selectedLanguage.equals("en"))
        {
            holder.timingDay.setText(model.getName());
        }
        else
        {
            holder.timingDay.setText(model.getArabic_name());
        }


        if(model.getStatus().equals("0")){
            holder.timing.setText("Closed");

        }
        else
        {
            holder.timing.setText(parseDateToddMMyyyy(model.getOpen_time()) +"-" +parseDateToddMMyyyy(model.getClose_time()));
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

