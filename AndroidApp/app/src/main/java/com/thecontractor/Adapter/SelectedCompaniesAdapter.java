package com.thecontractor.Adapter;

import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.location.Address;
import android.location.Geocoder;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Login;
import com.thecontractor.Model.SelectedCompaniesModel;
import com.thecontractor.Model.SelectedCompaniesResponseModel;
import com.thecontractor.OrderContactInfo;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;


public class SelectedCompaniesAdapter extends RecyclerView.Adapter<SelectedCompaniesAdapter.ViewHolder>  {

    private List<SelectedCompaniesModel> list;
    private Context mContext;
    private LinearLayout goToAddContactInfoLayout;
    private String selectedLanguage;
    private ActivityResultLauncher<Intent> cartResultLauncher;
    private GoogleMapInterface googleMapInterface;
    DatabaseHandler databaseHandler;
    ArrayList<SelectedCompaniesResponseModel> selectedCompaniesList = new ArrayList<>();

    public class ViewHolder extends RecyclerView.ViewHolder {

        ImageView companyImage;
        TextView companyName;
        TextView categoriesName;
        TextView companyTotalRatingCount;
        RatingBar ratingBar;
        Button selectOrRemoveBtn;
        EditText dateAndTime;
        EditText googleLocation;
        EditText location;
        EditText description;

        TextView googleLocationLat , googleLocationLng;

        public ViewHolder(final View view) {
            super(view);

            companyImage = (ImageView) view.findViewById(R.id.companyImage);
            companyName = (TextView) view.findViewById(R.id.companyName);
            categoriesName = (TextView) view.findViewById(R.id.categoriesName);
            companyTotalRatingCount = (TextView) view.findViewById(R.id.companyTotalRatingCount);
            ratingBar = (RatingBar) view.findViewById(R.id.ratingBar);
            selectOrRemoveBtn = (Button) view.findViewById(R.id.selectOrRemoveBtn);
            dateAndTime = (EditText) view.findViewById(R.id.dateAndTime);
            googleLocation = (EditText) view.findViewById(R.id.googleLocation);
            location = (EditText) view.findViewById(R.id.location);
            description = (EditText) view.findViewById(R.id.description);

            googleLocationLat = (TextView) view.findViewById(R.id.googleLocationLat);
            googleLocationLng = (TextView) view.findViewById(R.id.googleLocationLng);

            googleLocation.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    googleMapInterface.selectedView(googleLocation , googleLocationLat , googleLocationLng);

//                    Intent intent = new Intent(mContext , MapsActivity.class);
//                    cartResultLauncher.launch(intent);
                }
            });

            dateAndTime.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    dateAndTimePicker(dateAndTime);
                }
            });

            selectOrRemoveBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    int pos = getAdapterPosition();

                    databaseHandler.removeItemFromCart(list.get(pos).getId());
                    list.remove(pos);
                    notifyDataSetChanged();
                    updateValueIntent();

                }
            });

            goToAddContactInfoLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    selectedCompaniesList.clear();


                    for(int i=0; i < list.size(); i++)
                    {

                        SelectedCompaniesModel selectedCompaniesModel = list.get(i);

                        String id = selectedCompaniesModel.getId();
                        String dateTime = selectedCompaniesModel.getDate_time();
                        String location = selectedCompaniesModel.getLocation();
                        String lat = selectedCompaniesModel.getLat();
                        String lng = selectedCompaniesModel.getLng();
                        String description = selectedCompaniesModel.getDescription();

                        if(dateTime == null || dateTime.equals(""))
                        {
                            Toast.makeText(mContext, mContext.getResources().getString(R.string.enter_date_time) , Toast.LENGTH_SHORT).show();
                            break;
                        }else if((lat == null || lat.equals("")) && (lng == null || lng.equals("")))
                        {
                            Toast.makeText(mContext, mContext.getResources().getString(R.string.enter_google_location) , Toast.LENGTH_SHORT).show();
                            break;
                        }else if(location == null || location.equals(""))
                        {
                            Toast.makeText(mContext, mContext.getResources().getString(R.string.enter_location) , Toast.LENGTH_SHORT).show();
                            break;
                        }else if(description == null || description.equals(""))
                        {
                            Toast.makeText(mContext, mContext.getResources().getString(R.string.enter_description) , Toast.LENGTH_SHORT).show();
                            break;
                        }
                        else
                        {
                            selectedCompaniesList.add(new SelectedCompaniesResponseModel(id , dateTime , location , lat , lng  , description));


                            if(list.size() == selectedCompaniesList.size())
                            {

                                String jsonString = new Gson().toJson(selectedCompaniesList);

                                Log.e("tag" , "json string is : "+jsonString);

                                if (!SharedPrefManager.getInstance(mContext).getUserObject().equals("")) {
                                    Intent intent = new Intent(mContext, OrderContactInfo.class);
                                    intent.putExtra("selectedCompanies", jsonString);
                                    mContext.startActivity(intent);
                                }else
                                {
                                    Intent intent =  new Intent(mContext , Login.class);
                                    intent.putExtra("requestForLogin" , "yes");
                                    mContext.startActivity(intent);
                                }

                            }

                        }
                    }
                }
            });
        }
    }




    public void dateAndTimePicker(EditText dateAndTime)
    {
        Calendar calendar = Calendar.getInstance();
        final int mYear = calendar.get(Calendar.YEAR);
        final int mMonth = calendar.get(Calendar.MONTH);
        final int mDay = calendar.get(Calendar.DAY_OF_MONTH);
        final int hour = calendar.get(Calendar.HOUR_OF_DAY);
        final int minute = calendar.get(Calendar.MINUTE);

        DatePickerDialog datePickerDialog = new DatePickerDialog(mContext, new DatePickerDialog.OnDateSetListener() {
            @Override
            public void onDateSet(DatePicker datepicker, final int year, int month, final int day) {
                month++;
                final int finalMonth = month;
                TimePickerDialog timePickerDialog = new TimePickerDialog(mContext, new TimePickerDialog.OnTimeSetListener() {
                    @Override
                    public void onTimeSet(TimePicker view, int hourOfDay, int minute1) {
                        String dateTime = new StringBuilder().append(day).append("-").append(finalMonth).append("-").append(year).append(" ").append(hourOfDay).append(":").append(minute1).append(":00").toString();
                        try {
                            String dt = new SimpleDateFormat("MMM-dd-yyyy HH:mm:a").format(new SimpleDateFormat("d-M-yyyy H:m:ss", Locale.US).parse(dateTime));

                            String convertedDateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new SimpleDateFormat("MMM-dd-yyyy HH:mm:a", Locale.US).parse(dt));


                            Log.e("tag" , "convertedDateTime is : "+convertedDateTime);
                            Log.e("tag" , "date is : "+dt);

                            dateAndTime.setText(convertedDateTime);
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }
                    }
                }, hour, minute, false);
                timePickerDialog.show();
            }
        }, mYear, mMonth, mDay);
        datePickerDialog.show();

    }



    public SelectedCompaniesAdapter(Context context, List<SelectedCompaniesModel> list , LinearLayout goToAddContactInfoLayout , String selectedLanguage , ActivityResultLauncher<Intent> cartResultLauncher ,GoogleMapInterface googleMapInterface ) {
        this.list = list;
        this.mContext = context;
        this.goToAddContactInfoLayout = goToAddContactInfoLayout;
        this.selectedLanguage = selectedLanguage;
        this.cartResultLauncher = cartResultLauncher;
        this.googleMapInterface = googleMapInterface;
        databaseHandler = new DatabaseHandler(context);

    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.selected_companies_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        SelectedCompaniesModel model = list.get(position);

        Glide.with(mContext)
                .load(ApiUrls.COMPANIES_IMAGE_URL+model.getCompany_logo())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(holder.companyImage);

        if(selectedLanguage.equals("en"))
        {
            holder.companyName.setText(model.getCompany_name());
            holder.categoriesName.setText(model.getCategory_name());
        }else
        {
            holder.companyName.setText(model.getCompany_arabic_name());
            holder.categoriesName.setText(model.getCategory_arabic_name());
        }


        holder.companyTotalRatingCount.setText("("+model.getReview_count()+")");

        if(model.getAvg_rating() != null)
        {
            holder.ratingBar.setRating(Float.parseFloat(model.getAvg_rating()));
        }
        else
        {
            holder.ratingBar.setRating(0);
        }


        holder.dateAndTime.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                model.setDate_time(s.toString());
            }
        });


        holder.googleLocationLat.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                model.setLat(holder.googleLocationLat.getText().toString());
            }
        });


        holder.googleLocationLng.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                model.setLng(holder.googleLocationLng.getText().toString());
            }
        });

        holder.location.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                model.setLocation(s.toString());
            }
        });

        holder.description.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                model.setDescription(s.toString());
            }
        });


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


    private void updateValueIntent() {
        Intent updates = new Intent("update");
        updates.putExtra("type", "update_value");
        mContext.sendBroadcast(updates);
    }


    private BroadcastReceiver googleMapValue = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            String lat = intent.getStringExtra("lat");
            String lng = intent.getStringExtra("lng");

            Log.e("tag" , "lat lng in BroadcastReceiver : "+ lat  +"  "+ lng);


            //googleLocation.setText(getAddressFromLatLng(Double.parseDouble(lat) , Double.parseDouble(lng)));


        }
    };

    private String getAddressFromLatLng(double LATITUDE, double LONGITUDE) {
        String address = "";
        Geocoder geocoder = new Geocoder(mContext, Locale.getDefault());
        try {
            List<android.location.Address> addressList = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addressList != null) {
                Address returnedAddress = addressList.get(0);
                Log.e("tag", "My Current address returnedAddress : " + returnedAddress);

                address = addressList.get(0).getAddressLine(0);


                Log.e("tag", "My Complete address is : " + address);

            } else {
                address = "unknown address";
                Log.e("tag", "My Current address No Address returned!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            address = "unknown address";
            Log.e("tag", "My Current address Cannnot get Address!");
        }
        return address;
    }


    public interface GoogleMapInterface
    {
        void selectedView(EditText editText, TextView googleLocationLat, TextView googleLocationLng);
    }

    public void setLocationData(EditText googleMapEditText, TextView googleMapLat, TextView googleMapLng, double lat, double lng)
    {
        googleMapEditText.setText(getAddressFromLatLng(lat , lng ));
        googleMapLat.setText(String.valueOf(lat));
        googleMapLng.setText(String.valueOf(lng));
    }



}

