package com.thecontractor.Adapter;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.thecontractor.Model.WorkshopAdModel;
import com.thecontractor.R;
import com.thecontractor.WorkshopAdDetail;

import java.util.List;


public class WorkshopAdChatAdapter extends RecyclerView.Adapter<WorkshopAdChatAdapter.ViewHolder>  {

    private List<WorkshopAdModel.ChatModel> list;
    private Context mContext;
    private String selectedLanguage;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView name , date , message;


        public ViewHolder(final View view) {
            super(view);

            name = (TextView) view.findViewById(R.id.name);
            date = (TextView) view.findViewById(R.id.date);
            message = (TextView) view.findViewById(R.id.message);


            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    WorkshopAdModel.ChatModel quotationsModel = list.get(pos);

                }
            });




        }
    }


    public WorkshopAdChatAdapter(Context context, List<WorkshopAdModel.ChatModel> list , String selectedLanguage) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.workshop_chat_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        WorkshopAdModel.ChatModel model = list.get(position);

        holder.name.setText(model.getAdded_by().getName());
        holder.date.setText(model.getDate());
        holder.message.setText(model.getMessage());


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

