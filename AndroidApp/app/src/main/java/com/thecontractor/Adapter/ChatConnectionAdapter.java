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
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorChat;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;


public class ChatConnectionAdapter extends RecyclerView.Adapter<ChatConnectionAdapter.ViewHolder>  {

    private List<ChatConnectionModel> list;
    private Context mContext;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView chatUserName;
        TextView chatLastMessageTime;
        TextView chatLastMessage;
        TextView chatUnseen;


        public ViewHolder(final View view) {
            super(view);

            chatUserName = (TextView) view.findViewById(R.id.chatUserName);
            chatLastMessageTime = (TextView) view.findViewById(R.id.chatLastMessageTime);
            chatLastMessage = (TextView) view.findViewById(R.id.chatLastMessage);
            chatUnseen = (TextView) view.findViewById(R.id.chatUnseen);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    Intent intent = new Intent(mContext , Chat.class);
                    intent.putExtra("vendorId" , list.get(pos).getCompany_id());
                    intent.putExtra("vendorName" , list.get(pos).getCompany_name());
                    intent.putExtra("vendorUUID" ,list.get(pos).getCompany_uuid());
                    intent.putExtra("chatUUID" ,list.get(pos).getChat_uuid());
                    intent.putExtra("vendorSerialNo" ,list.get(pos).getCompany_serial_no());
                    mContext.startActivity(intent);

                }
            });


        }
    }


    public ChatConnectionAdapter(Context context, List<ChatConnectionModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_connection_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        ChatConnectionModel model = list.get(position);
        holder.chatUserName.setText(model.getCompany_name());
        holder.chatLastMessage.setText(model.getLast_message());
        holder.chatLastMessageTime.setText(covertTimeToTextTe(model.getMessage_time()));


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

    public String covertTimeToTextTe(String dataDate) {

        String convertTime = null;
        String suffix = "ago";

        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-dd-MM HH:mm:ss", Locale.getDefault());
            Date pasTime = dateFormat.parse(dataDate);

            Date nowTime = new Date();

            long dateDiff = nowTime.getTime() - pasTime.getTime();

            long second = TimeUnit.MILLISECONDS.toSeconds(dateDiff);
            long minute = TimeUnit.MILLISECONDS.toMinutes(dateDiff);
            long hour = TimeUnit.MILLISECONDS.toHours(dateDiff);
            long day = TimeUnit.MILLISECONDS.toDays(dateDiff);

            if (second < 60) {
                if (second == 1) {
                    convertTime = second + " second " + suffix;
                } else {
                    convertTime = second + " seconds " + suffix;
                }
            } else if (minute < 60) {
                if (minute == 1) {
                    convertTime = minute + " minute " + suffix;
                } else {
                    convertTime = minute + " minutes " + suffix;
                }
            } else if (hour < 24) {
                if (hour == 1) {
                    convertTime = hour + " hour " + suffix;
                } else {
                    convertTime = hour + " hours " + suffix;
                }
            } else if (day >= 7) {
                if (day >= 365) {
                    long tempYear = day / 365;
                    if (tempYear == 1) {
                        convertTime = tempYear + " year " + suffix;
                    } else {
                        convertTime = tempYear + " years " + suffix;
                    }
                } else if (day >= 30) {
                    long tempMonth = day / 30;
                    if (tempMonth == 1) {
                        convertTime = (day / 30) + " month " + suffix;
                    } else {
                        convertTime = (day / 30) + " months " + suffix;
                    }
                } else {
                    long tempWeek = day / 7;
                    if (tempWeek == 1) {
                        convertTime = (day / 7) + " week " + suffix;
                    } else {
                        convertTime = (day / 7) + " weeks " + suffix;
                    }
                }
            } else {
                if (day == 1) {
                    convertTime = day + " day " + suffix;
                } else {
                    convertTime = day + " days " + suffix;
                }
            }

        } catch (ParseException e) {
            e.printStackTrace();
            Log.e("TimeAgo", e.getMessage() + "");
        }
        return convertTime;
    }


}

