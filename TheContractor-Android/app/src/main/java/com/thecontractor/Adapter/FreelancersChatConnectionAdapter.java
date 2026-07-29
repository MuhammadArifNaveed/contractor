package com.thecontractor.Adapter;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Chat;
import com.thecontractor.Model.ChatConnectionModel;
import com.thecontractor.Model.FreelancersChatConnectionModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorFreelancerChat;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;


public class FreelancersChatConnectionAdapter extends RecyclerView.Adapter<FreelancersChatConnectionAdapter.ViewHolder>  {

    private List<FreelancersChatConnectionModel> list;
    private Context mContext;
    private String from;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView chatUserName;
        TextView chatLastMessageTime;



        public ViewHolder(final View view) {
            super(view);

            chatUserName = (TextView) view.findViewById(R.id.chatUserName);
            chatLastMessageTime = (TextView) view.findViewById(R.id.chatLastMessageTime);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    Intent intent = new Intent(mContext , VendorFreelancerChat.class);
                    intent.putExtra("orderId" , list.get(pos).getOrder_id());
                    intent.putExtra("from" , from);
                    mContext.startActivity(intent);

                }
            });


        }
    }


    public FreelancersChatConnectionAdapter(Context context, List<FreelancersChatConnectionModel> list , String from) {
        this.list = list;
        this.mContext = context;
        this.from = from;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.freelancer_chat_connection_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        FreelancersChatConnectionModel model = list.get(position);
        holder.chatUserName.setText(model.getFreelancer_name());
        holder.chatLastMessageTime.setText(parseDateToddMMyyyy(model.getBasic_details().getCreated_at()));


    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd HH:mm:ss";
        String outputPattern = "dd MM yyyy h:mm a";
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

