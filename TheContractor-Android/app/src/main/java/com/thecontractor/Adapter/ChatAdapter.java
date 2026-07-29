package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.ChatModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.ViewHolder>  {

    private List<ChatModel> list;
    private Context mContext;
    private String selectedLanguage;
    private String userUUID;

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


    public ChatAdapter(Context context, List<ChatModel> list , String selectedLanguage, String userUUID) {
        this.list = list;
        this.mContext = context;
        this.userUUID = userUUID;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;

        if(viewType == VIEW_MY_MESSAGES)
        {
            itemView = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.my_message_custom_row, parent, false);
        } else if(viewType == VIEW_OTHER_MESSAGES){
            itemView = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.other_message_custom_row, parent, false);
        }

        return new ViewHolder(itemView);



    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        ChatModel model = list.get(position);


        holder.message.setText(model.getMessage());
        holder.time.setText(model.getTime());





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
        ChatModel ad = list.get(position);


        if(ad.getSent_by().equals("user"))
        {
            return VIEW_MY_MESSAGES;
        }else
        {
            return VIEW_OTHER_MESSAGES;
        }
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

