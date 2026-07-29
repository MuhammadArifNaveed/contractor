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

import java.util.List;


public class WorkshopAdInterestedQuotationAdapter extends RecyclerView.Adapter<WorkshopAdInterestedQuotationAdapter.ViewHolder>  {

    private List<WorkshopAdModel.QuotationsModel> list;
    private Context mContext;
    private String selectedLanguage;
    private ChatReplyInterface chatReplyInterface;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView companyName , price , message , chatReply;
        LinearLayout contactLayout;
        RecyclerView quotationChatRecyclerView;
        LinearLayoutManager linearLayoutManager ;

        public ViewHolder(final View view) {
            super(view);

            companyName = (TextView) view.findViewById(R.id.companyName);
            price = (TextView) view.findViewById(R.id.price);
            message = (TextView) view.findViewById(R.id.message);
            chatReply = (TextView) view.findViewById(R.id.chatReply);
            contactLayout = (LinearLayout) view.findViewById(R.id.contactLayout);

            quotationChatRecyclerView = view.findViewById(R.id.quotationChatRecyclerView);
            linearLayoutManager = new LinearLayoutManager(mContext ,  LinearLayoutManager.VERTICAL , false);
            quotationChatRecyclerView.setLayoutManager(linearLayoutManager);


            chatReply.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();
                    WorkshopAdModel.QuotationsModel quotationsModel = list.get(pos);

                    chatReplyInterface.selectReply(pos , quotationsModel);
                }
            });




        }
    }


    public WorkshopAdInterestedQuotationAdapter(Context context, List<WorkshopAdModel.QuotationsModel> list , String selectedLanguage , ChatReplyInterface chatReplyInterface) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.chatReplyInterface = chatReplyInterface;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.workshop_interested_quotation_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        WorkshopAdModel.QuotationsModel model = list.get(position);

        holder.companyName.setText(model.getAdded_by().getName());
        holder.price.setText(model.getFinal_price() + " " + mContext.getResources().getString(R.string.currency));
        holder.message.setText(model.getMessage());

        WorkshopAdChatAdapter workshopAdChatAdapter = new WorkshopAdChatAdapter(mContext , model.getChats() , selectedLanguage);
        holder.quotationChatRecyclerView.setAdapter(workshopAdChatAdapter);

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

    public interface ChatReplyInterface
    {
        void selectReply(int pos, WorkshopAdModel.QuotationsModel quotationsModel);
    }
}

