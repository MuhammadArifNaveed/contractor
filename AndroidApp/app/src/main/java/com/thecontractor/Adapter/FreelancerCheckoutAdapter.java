package com.thecontractor.Adapter;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SelectedFreelancerDatePicker;
import com.thecontractor.Model.SelectedFreelancersDatabaseModel;
import com.thecontractor.Model.SelectedFreelancersDateDatabaseModel;
import com.thecontractor.Model.SelectedFreelancersDetailDatabaseModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;


public class FreelancerCheckoutAdapter extends RecyclerView.Adapter<FreelancerCheckoutAdapter.ViewHolder>  {

    private List<SelectedFreelancersDatabaseModel> list;
    private Context mContext;
    private String selectedLanguage;
    private String cityName;
    private OnItemInteractionListener interactionListener;


    public class ViewHolder extends RecyclerView.ViewHolder {

        ImageView freelancerImage;
        TextView freelancerName;
        TextView freelancerCategory;
        TextView freelancerRateHR;
        TextView freelancerAreaCity;
        TextView freelancerBookingDates;
        TextView freelancerAmountCalculation;
        TextView freelancerTransportCharges;
        TextView freelancerPayable;
        TextView calculateTransportCharges;
        ImageView deleteFreelancer;



        public ViewHolder(final View view) {
            super(view);

            freelancerImage = (ImageView) view.findViewById(R.id.freelancerImage);
            freelancerName = (TextView) view.findViewById(R.id.freelancerName);
            freelancerCategory = (TextView) view.findViewById(R.id.freelancerCategory);
            freelancerRateHR = (TextView) view.findViewById(R.id.freelancerRateHR);
            freelancerAreaCity = (TextView) view.findViewById(R.id.freelancerAreaCity);
            freelancerBookingDates = view.findViewById(R.id.freelancerBookingDates);
            freelancerAmountCalculation = view.findViewById(R.id.freelancerAmountCalculation);
            freelancerTransportCharges = view.findViewById(R.id.freelancerTransportCharges);
            freelancerPayable = view.findViewById(R.id.freelancerPayable);
            calculateTransportCharges = view.findViewById(R.id.calculateTransportCharges);
            deleteFreelancer = view.findViewById(R.id.deleteFreelancer);

            deleteFreelancer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();
                    SelectedFreelancersDatabaseModel selectedFreelancersDatabaseModel = list.get(pos);
                    if (interactionListener != null) {
                        interactionListener.onDeleteClicked(selectedFreelancersDatabaseModel, pos);
                    }
                }
            });

            calculateTransportCharges.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();
                    SelectedFreelancersDatabaseModel selectedFreelancersDatabaseModel = list.get(pos);
                    if (interactionListener != null) {
                        interactionListener.onTransportChargesClicked(selectedFreelancersDatabaseModel, pos);
                    }
                }
            });


        }
    }


    public FreelancerCheckoutAdapter(Context context, List<SelectedFreelancersDatabaseModel> list , String selectedLanguage , OnItemInteractionListener interactionListener , String cityName) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.interactionListener = interactionListener;
        this.cityName = cityName;

    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.freelancer_checkout_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        SelectedFreelancersDatabaseModel model = list.get(position);

        Glide.with(mContext)
                .load(ApiUrls.PROFILE_IMAGE_URL+model.getImage())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(holder.freelancerImage);

        if(selectedLanguage.equals("en"))
        {
            holder.freelancerName.setText(model.getName());
            holder.freelancerCategory.setText(model.getCategory());
            holder.freelancerAreaCity.setText(model.getArea() + " , " +model.getCity());
        }
        else
        {
            holder.freelancerName.setText(model.getName());
            holder.freelancerCategory.setText(model.getCategory());
            holder.freelancerAreaCity.setText(model.getArea() + " , " +model.getCity());
        }

        double hourlyRate = new SelectedFreelancerDatePicker().calculateHourlyRatePercentage(model.getHourlyRate() , model.getCommission());

        holder.freelancerRateHR.setText(String.format("%.2f" , hourlyRate) + "/hr");

        SelectedFreelancersDetailDatabaseModel detail = model.getDetail();
        int numDays = detail.getDates().size();
        double hoursPerDay = new SelectedFreelancerDatePicker().calculateHoursLegacy(detail.getFromTime(), detail.getToTime());
        double freelancerCharges = hoursPerDay * hourlyRate * numDays;


        if(model.getTransportation_charges().equals("0")){
            holder.calculateTransportCharges.setVisibility(VISIBLE);
            holder.freelancerTransportCharges.setVisibility(GONE);
        }else {
            holder.calculateTransportCharges.setVisibility(GONE);
            holder.freelancerTransportCharges.setVisibility(VISIBLE);

        }

        double transportCharges = Double.parseDouble(model.getTransportation_charges());

        double totalPayable = freelancerCharges + transportCharges;

        StringBuilder datesText = new StringBuilder();
        for (SelectedFreelancersDateDatabaseModel dateModel : detail.getDates()) {
            datesText.append(String.format(Locale.getDefault(),
                    "%s ( %s to %s ) ( %.2f hrs)\n",
                    new SelectedFreelancerDatePicker().parseDateToddMMyyyy(dateModel.getDate()),
                    new SelectedFreelancerDatePicker().parseTime(detail.getFromTime()),
                    new SelectedFreelancerDatePicker().parseTime(detail.getToTime()),
                    hoursPerDay));
        }

        holder.freelancerBookingDates.setText(datesText.toString().trim());

        holder.freelancerAmountCalculation.setText(String.format(Locale.getDefault(),
                "Amount ( %.2f Hr x %.2f Rate x %d days ) : %.2f AED",
                hoursPerDay, hourlyRate, numDays, freelancerCharges));

        holder.freelancerTransportCharges.setText(String.format(Locale.getDefault(),
                "Transport charges ( %s To %s ) : %.2f AED",
                model.getCity() , cityName , transportCharges));

        holder.freelancerPayable.setText(String.format(Locale.getDefault(), "Payable : %.2f AED", totalPayable));

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


    public interface OnItemInteractionListener  {
        void onDeleteClicked(SelectedFreelancersDatabaseModel freelancer, int position);
        void onTransportChargesClicked(SelectedFreelancersDatabaseModel freelancer, int position);
    }


}

