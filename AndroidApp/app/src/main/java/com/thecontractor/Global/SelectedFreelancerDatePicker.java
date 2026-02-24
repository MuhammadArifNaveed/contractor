package com.thecontractor.Global;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.applandeo.materialcalendarview.CalendarView;
import com.applandeo.materialcalendarview.DatePicker;
import com.applandeo.materialcalendarview.builders.DatePickerBuilder;
import com.applandeo.materialcalendarview.listeners.OnSelectDateListener;
import com.google.gson.Gson;
import com.thecontractor.Adapter.SelectedFreelancerDateRateAdapter;
import com.thecontractor.Database.FreelancerDatabaseHelper;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.SelectedFreelancerDateRateModel;
import com.thecontractor.Model.SelectedFreelancersDatabaseModel;
import com.thecontractor.Model.SelectedFreelancersDateDatabaseModel;
import com.thecontractor.Model.SelectedFreelancersDetailDatabaseModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class SelectedFreelancerDatePicker {
    Context context;
    private static double HOURLY_RATE = 22;
    private static double HOURS_PER_DAY = 10;
    private List<Calendar> selectedDates = new ArrayList<>();
    private Calendar fromTimeCalendar;
    private Calendar toTimeCalendar;

    private OnFreelancerSelectedListener listener;

    public interface OnFreelancerSelectedListener {
        void onFreelancerSelected();
    }

    public void setOnFreelancerSelectedListener(OnFreelancerSelectedListener listener) {
        this.listener = listener;
    }

    public void showSelectFreelancerDialog(Context context, FreelancerListModel freelancerListModel , String companyCommissionRate) {

        Dialog dialogView = new Dialog(context);
        dialogView.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialogView.setContentView(R.layout.select_freelancer_dialog);
        Window window = dialogView.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialogView.setCancelable(true);
        dialogView.show();


        TextView tvSelectedTime = dialogView.findViewById(R.id.tvSelectedTime);
        TextView tvPerHourRate = dialogView.findViewById(R.id.tvPerHourRate);
        EditText etDates = dialogView.findViewById(R.id.etDates);
        LinearLayout hourlyLayout = dialogView.findViewById(R.id.hourlyLayout);
        if(freelancerListModel.getAvailable_per_hour().equals("0")){
            hourlyLayout.setVisibility(GONE);
        }
        CheckBox cbHourly = dialogView.findViewById(R.id.cbHourly);
        LinearLayout layoutTimePickers = dialogView.findViewById(R.id.layoutTimePickers);
        layoutTimePickers.setVisibility(GONE);
        EditText etFromTime = dialogView.findViewById(R.id.etFromTime);
        EditText etToTime = dialogView.findViewById(R.id.etToTime);
        LinearLayout recyclerviewAndTotalLayout = dialogView.findViewById(R.id.recyclerviewAndTotalLayout);
        recyclerviewAndTotalLayout.setVisibility(GONE);
        RecyclerView recyclerView = dialogView.findViewById(R.id.recyclerViewBookings);
        TextView tvGrandTotal = dialogView.findViewById(R.id.tvGrandTotal);
        Button addToListBtn = dialogView.findViewById(R.id.addToListBtn);

        HOURS_PER_DAY = calculateHoursLegacy(freelancerListModel.getFrom_time(), freelancerListModel.getTo_time());
        HOURLY_RATE = new SelectedFreelancerDatePicker().calculateHourlyRatePercentage(freelancerListModel.getHourly_rate() , companyCommissionRate);

        tvSelectedTime.setText("Selected Time : " + parseTime(freelancerListModel.getFrom_time()) + " to " + parseTime(freelancerListModel.getTo_time()));
        tvPerHourRate.setText("Per Hour Rate : " + String.format("%.2f" , HOURLY_RATE));

        List<SelectedFreelancerDateRateModel> bookingList = new ArrayList<>();
        SelectedFreelancerDateRateAdapter adapter = new SelectedFreelancerDateRateAdapter(context , bookingList);
        recyclerView.setLayoutManager(new LinearLayoutManager(context));
        recyclerView.setAdapter(adapter);

        cbHourly.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                layoutTimePickers.setVisibility(View.VISIBLE);
                HOURS_PER_DAY = 0;
                updateBookingList(bookingList, adapter, etDates, tvGrandTotal , recyclerviewAndTotalLayout);

            } else {
                layoutTimePickers.setVisibility(View.GONE);
                // Clear selections and recalculate
                fromTimeCalendar = null;
                toTimeCalendar = null;
                etFromTime.setText("");
                etToTime.setText("");
                HOURS_PER_DAY = calculateHoursLegacy(freelancerListModel.getFrom_time(), freelancerListModel.getTo_time());
                updateBookingList(bookingList, adapter, etDates, tvGrandTotal , recyclerviewAndTotalLayout);
            }
        });

        etFromTime.setOnClickListener(v -> showTimePicker(context , etFromTime, true , bookingList, adapter, etDates, tvGrandTotal , recyclerviewAndTotalLayout));
        etToTime.setOnClickListener(v -> showTimePicker(context , etToTime, false , bookingList, adapter, etDates, tvGrandTotal , recyclerviewAndTotalLayout));


        etDates.setOnClickListener(v -> {
            OnSelectDateListener listener = calendars -> {

                this.selectedDates.clear();
                this.selectedDates.addAll(calendars);

                updateBookingList(bookingList, adapter, etDates, tvGrandTotal , recyclerviewAndTotalLayout);
            };

            DatePickerBuilder builder_calendar = new DatePickerBuilder(context, listener)
                    .pickerType(CalendarView.MANY_DAYS_PICKER)
                    .setMinimumDate(Calendar.getInstance())
                    .setSelectedDays(selectedDates);



            DatePicker datePicker = builder_calendar.build();
            datePicker.show();
        });

        addToListBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(etDates.getText().toString().isEmpty()){
                    Toast.makeText(context, "Select Date", Toast.LENGTH_SHORT).show();
                }else if(cbHourly.isChecked() && etFromTime.getText().toString().isEmpty()){
                    Toast.makeText(context, "Select From Date", Toast.LENGTH_SHORT).show();
                }else if(cbHourly.isChecked() && etToTime.getText().toString().isEmpty()){
                    Toast.makeText(context, "Select To Date", Toast.LENGTH_SHORT).show();
                }else {
                    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
                    ArrayList<SelectedFreelancersDateDatabaseModel> dates  = new ArrayList<>();
                    for (Calendar cal : selectedDates) {
                        dates .add(new SelectedFreelancersDateDatabaseModel(formatter.format(cal.getTime())));
                    }

                    String checkboxValueString = cbHourly.isChecked() ? "1" : "0";

                    String fromTime = freelancerListModel.getFrom_time();
                    String toTime = freelancerListModel.getTo_time() ;

                    if(cbHourly.isChecked()){
                        fromTime = parseTimeViceVersa(etFromTime.getText().toString());
                        toTime = parseTimeViceVersa(etToTime.getText().toString());
                    }


                    SelectedFreelancersDetailDatabaseModel detail = new SelectedFreelancersDetailDatabaseModel(
                            checkboxValueString ,
                            fromTime,
                            toTime,
                            "0",
                            dates
                    );

                    SelectedFreelancersDatabaseModel freelancer = new SelectedFreelancersDatabaseModel(
                            freelancerListModel.getId(),
                            freelancerListModel.getUuid(),
                            freelancerListModel.getCity_id(),
                            freelancerListModel.getName(),
                            freelancerListModel.getImage(),
                            freelancerListModel.getJob_category_title(),
                            freelancerListModel.getHourly_rate(),
                            companyCommissionRate,
                            freelancerListModel.getCity_name(),
                            freelancerListModel.getArea_name(),
                            "0",
                            detail
                    );

                    FreelancerDatabaseHelper freelancerDatabaseHelper = new FreelancerDatabaseHelper(context);
                    boolean success = freelancerDatabaseHelper.addFreelancerBooking(freelancer);

                    if (success) {
                        Toast.makeText(context, "Freelancer booking saved successfully!", Toast.LENGTH_SHORT).show();
                    } else {
                        Toast.makeText(context, "Error saving booking.", Toast.LENGTH_SHORT).show();
                    }

                    Log.e("tag" , "selected data is : " + new Gson().toJson(freelancer));


                    if (listener != null) {
                        listener.onFreelancerSelected();
                    }


                    dialogView.dismiss();
                }
            }
        });


    }





    private void updateBookingList(List<SelectedFreelancerDateRateModel> bookingList,
                                   SelectedFreelancerDateRateAdapter adapter, EditText etDates, TextView tvGrandTotal, LinearLayout recyclerviewAndTotalLayout) {


        if(!selectedDates.isEmpty()){
            recyclerviewAndTotalLayout.setVisibility(VISIBLE);
        }
        bookingList.clear();

        // Sort dates chronologically for better display
        Collections.sort(selectedDates);

        for (Calendar cal : selectedDates) {
            bookingList.add(new SelectedFreelancerDateRateModel(cal, HOURS_PER_DAY, HOURLY_RATE));
        }

        adapter.notifyDataSetChanged();
        updateDateEditText(selectedDates, etDates);
        updateGrandTotal(bookingList, tvGrandTotal);
    }

    private void updateDateEditText(List<Calendar> dates, EditText etDates) {
        if (dates.isEmpty()) {
            etDates.setText("");
            return;
        }

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        List<String> dateStrings = new ArrayList<>();
        for (Calendar cal : dates) {
            dateStrings.add(formatter.format(cal.getTime()));
        }
        etDates.setText(TextUtils.join(", ", dateStrings));

    }

    private void updateGrandTotal(List<SelectedFreelancerDateRateModel> bookingList, TextView tvGrandTotal) {
        double total = 0;
        for (SelectedFreelancerDateRateModel item : bookingList) {
            total += item.getTotal();
        }
        tvGrandTotal.setText(String.format("%.2f" , total));
    }


    private void showTimePicker(Context context, EditText timeEditText, boolean isFromTime , List<SelectedFreelancerDateRateModel> bookingList,
                                SelectedFreelancerDateRateAdapter adapter, EditText etDates, TextView tvGrandTotal, LinearLayout recyclerviewAndTotalLayout) {
        // Use the previously selected time for the picker's initial state, or current time
        Calendar initialTime = isFromTime ? fromTimeCalendar : toTimeCalendar;
        if (initialTime == null) {
            initialTime = Calendar.getInstance();
        }

        int hour = initialTime.get(Calendar.HOUR_OF_DAY);
        int minute = initialTime.get(Calendar.MINUTE);

        TimePickerDialog timePickerDialog = new TimePickerDialog(context, (view, hourOfDay, minuteOfHour) -> {
            Calendar selectedTime = Calendar.getInstance();
            selectedTime.set(Calendar.HOUR_OF_DAY, hourOfDay);
            selectedTime.set(Calendar.MINUTE, minuteOfHour);


            if (isFromTime) {
                // User is setting the 'From' time.
                // Check if a 'To' time exists and if the new 'From' time is after it.
                if (toTimeCalendar != null && selectedTime.after(toTimeCalendar)) {
                    Toast.makeText(context, "'From' time cannot be after 'To' time", Toast.LENGTH_SHORT).show();
                    return; // Reject the change
                }
            } else {
                // User is setting the 'To' time.
                // Check if a 'From' time exists and if the new 'To' time is before it.
                if (fromTimeCalendar != null && selectedTime.before(fromTimeCalendar)) {
                    Toast.makeText(context, "'To' time cannot be before 'From' time", Toast.LENGTH_SHORT).show();
                    return; // Reject the change
                }
            }


            // Store the selection
            if (isFromTime) {
                fromTimeCalendar = selectedTime;
            } else {
                toTimeCalendar = selectedTime;
            }

            // Format and display the time
            SimpleDateFormat sdf = new SimpleDateFormat("h:mm a", Locale.getDefault());
            timeEditText.setText(sdf.format(selectedTime.getTime()));

            if (fromTimeCalendar != null && toTimeCalendar != null) {
                SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss");

                HOURS_PER_DAY = calculateHoursLegacy(format.format(fromTimeCalendar.getTime()), format.format(toTimeCalendar.getTime()));

                Log.e("tag" , "HOURS_PER_DAY : "+HOURS_PER_DAY  + " from time : " + format.format(fromTimeCalendar.getTime()) + " to time : " + format.format(toTimeCalendar.getTime()));

                updateBookingList(bookingList, adapter, etDates, tvGrandTotal , recyclerviewAndTotalLayout);

            }

        }, hour, minute, false); // false for 12-hour format with AM/PM

        timePickerDialog.show();
    }

    public double calculateHoursLegacy(String startTimeStr , String endTimeStr) {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.ENGLISH);

        try {
            Date startTime = sdf.parse(startTimeStr);
            Date endTime = sdf.parse(endTimeStr);

            long differenceInMillis = endTime.getTime() - startTime.getTime();


            if (differenceInMillis < 0) {
                differenceInMillis += 24 * 60 * 60 * 1000; // Add 24 hours in milliseconds
            }

            // Return the difference as a double in hours
            return differenceInMillis / (double) (1000 * 60 * 60);
            //return TimeUnit.MILLISECONDS.toHours(differenceInMillis);

        } catch (ParseException e) {
            e.printStackTrace();
            // This exception is thrown if the string format does not match the pattern.
            return -1;
        }
    }

    public String parseTime(String time) {
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

    public String parseTimeViceVersa(String time) {
        String inputPattern = "h:mm a";
        String outputPattern = "HH:mm:ss";
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

    public double calculateHourlyRatePercentage(String hourlyRate , String commissionRate){
        double rate = Double.parseDouble(hourlyRate);
        double commission = Double.parseDouble(commissionRate);

        Log.e("tag" , "hourlyRate is : "+hourlyRate);
        Log.e("tag" , "commissionRate is : "+commissionRate);

        double commissionAmount = (rate * commission) / 100.0;
        double totalRate = rate + commissionAmount;

        return totalRate;

    }

    public double calculateTransportationPercentage(double transportationCharges ,double transportationChargesDiscount ,  String commissionRate){
        double commission = Double.parseDouble(commissionRate);

        Log.e("tag" , "transportationCharges is : "+transportationCharges);
        Log.e("tag" , "transportationChargesDiscount is : "+transportationChargesDiscount);
        Log.e("tag" , "commissionRate is : "+commissionRate);

        double commissionAmount = (transportationCharges * commission) / 100.0;
        double totalRate = (transportationCharges + commissionAmount) - transportationChargesDiscount;

        return totalRate;

    }


    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd";
        String outputPattern = "dd MMM yyyy";
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

