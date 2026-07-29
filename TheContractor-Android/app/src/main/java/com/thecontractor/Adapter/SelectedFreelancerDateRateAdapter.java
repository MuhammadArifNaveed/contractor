package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.SelectedFreelancerDateRateModel;
import com.thecontractor.R;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;


public class SelectedFreelancerDateRateAdapter extends RecyclerView.Adapter<SelectedFreelancerDateRateAdapter.ViewHolder>  {

    private List<SelectedFreelancerDateRateModel> list;
    private Context mContext;
    private final SimpleDateFormat dateFormatter = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault());
    private final SimpleDateFormat dayFormatter = new SimpleDateFormat("EEEE", Locale.getDefault());

    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView tvDate, tvDayOfWeek, tvHours, tvRate, tvTotal;



        public ViewHolder(final View view) {
            super(view);

            tvDate = itemView.findViewById(R.id.tvDate);
            tvDayOfWeek = itemView.findViewById(R.id.tvDayOfWeek);
            tvHours = itemView.findViewById(R.id.tvHours);
            tvRate = itemView.findViewById(R.id.tvRate);
            tvTotal = itemView.findViewById(R.id.tvTotal);


        }
    }


    public SelectedFreelancerDateRateAdapter(Context context, List<SelectedFreelancerDateRateModel> list) {
        this.list = list;
        this.mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.selected_freelancer_data_rate_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        SelectedFreelancerDateRateModel model = list.get(position);

        holder.tvDate.setText(dateFormatter.format(model.getCalendar().getTime()));
        holder.tvDayOfWeek.setText(dayFormatter.format(model.getCalendar().getTime()));
        holder.tvHours.setText(String.format("%.2f" , model.getHours()));
        holder.tvRate.setText(String.format("%.2f" ,model.getRate()));
        holder.tvTotal.setText(String.format("%.2f" ,model.getTotal()));
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

