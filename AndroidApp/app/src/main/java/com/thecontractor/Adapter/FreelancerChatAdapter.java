package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.ChatModel;
import com.thecontractor.Model.FreelancerChatModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class FreelancerChatAdapter extends RecyclerView.Adapter<FreelancerChatAdapter.ViewHolder>  {

    private List<FreelancerChatModel> list;
    private Context mContext;
    private String selectedLanguage;
    private String vendorUUID;

    public static final int VIEW_MY_MESSAGES = 1;
    public static final int VIEW_OTHER_MESSAGES = 2;

    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView message;
        TextView time;


        public ViewHolder(final View view) {
            super(view);

            message = (TextView) view.findViewById(R.id.message);
            time = (TextView) view.findViewById(R.id.time);

        }
    }


    public FreelancerChatAdapter(Context context, List<FreelancerChatModel> list , String selectedLanguage, String vendorUUID) {
        this.list = list;
        this.mContext = context;
        this.vendorUUID = vendorUUID;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;

        if(viewType == VIEW_MY_MESSAGES)
        {
            itemView = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.freelancer_my_message_custom_row, parent, false);
        } else if(viewType == VIEW_OTHER_MESSAGES){
            itemView = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.freelancer_other_message_custom_row, parent, false);
        }

        return new ViewHolder(itemView);


    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        FreelancerChatModel model = list.get(position);


        holder.message.setText(model.getMessage());
        holder.time.setText(model.getCreated_at());




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
        FreelancerChatModel ad = list.get(position);


//        if(ad.getSent_by().equals("company"))
//        {
//            return VIEW_MY_MESSAGES;
//        }else
//        {
            return VIEW_OTHER_MESSAGES;
//        }
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

