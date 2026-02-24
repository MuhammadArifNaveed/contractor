package com.thecontractor.Fragments;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.ProgressDialog;
import android.app.TimePickerDialog;
import android.content.Context;
import android.content.Intent;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.PickVisualMediaRequest;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.text.InputType;
import android.util.Log;
import android.util.Patterns;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.MediaController;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.nguyenhoanglam.imagepicker.model.Image;
import com.thecontractor.Adapter.AreaSpinnerAdapter;
import com.thecontractor.Adapter.CustomImagesAdapter;
import com.thecontractor.Adapter.JobCategoriesSpinnerAdapter;
import com.thecontractor.Adapter.JobCitiesSpinnerAdapter;
import com.thecontractor.Adapter.NewCustomImagesAdapter;
import com.thecontractor.Adapter.SelectedFreelancerDateRateAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.MultiSelectAutoCompleteViewNew;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.AddFreelancerViewModel;
import com.thecontractor.Model.AreaModel;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.FreelancerSkillModel;
import com.thecontractor.Model.FreelancerSkillsModel;
import com.thecontractor.Model.IdModel;
import com.thecontractor.Model.NameModel;
import com.thecontractor.Model.NewCustomImagesModel;
import com.thecontractor.Model.SelectedFreelancerDateRateModel;
import com.thecontractor.Model.VendorJobCategoriesModel;
import com.thecontractor.Model.VendorJobCitiesModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.SearchFreelancer;
import com.thecontractor.VendorActivities.VendorAddFreelancer;
import com.thecontractor.VendorActivities.VendorPostJob;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;


public class FreelancerGeneralFragment extends Fragment implements NewCustomImagesAdapter.DeleteImage{


    FreelancerListModel freelancerListModel;
    String from;
    String type;
    LinearLayout generalInfoLayout;
    private EditText nameET, emailET , phoneET , hourlyRateET , fromTimeET , toTimeET;
    private String nameETStr, emailETStr , phoneETStr , hourlyRateETStr , selectedSkills , selectedPerHour , fromTimeETStr , toTimeETStr;
    private Uri imageURI, videoURI;
    MultiSelectAutoCompleteViewNew<FreelancerSkillsModel> multiSelectAutoCompleteView;
    Spinner categorySpinner , citySpinner , areaSpinner;
    CheckBox cbHourly;
    RecyclerView customImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    NewCustomImagesAdapter newCustomImagesAdapter;
    VideoView videoView;
    private Button chooseImages , chooseVideo , btnNext;
    String selectedCategory = "0", selectedCity = "0" , selectedArea = "0";
    ArrayList<VendorJobCategoriesModel> categoriesList;
    ArrayList<VendorJobCitiesModel> citiesList;
    ArrayList<AreaModel> areasList;

    ArrayList<FreelancerSkillsModel> skillsList;
    private ArrayList<NewCustomImagesModel> selectedImages = new ArrayList<>();

    String selectedLanguage = "en";

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    private Calendar fromTimeCalendar;
    private Calendar toTimeCalendar;
    AddFreelancerViewModel addFreelancerViewModel;

    public FreelancerGeneralFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view =  inflater.inflate(R.layout.fragment_freelancer_general, container, false);

        getObjectFromAdapter();
        initiate(view);
        clickListener();
        getFreelancerDataAPI();



        return view;
    }


    public void getObjectFromAdapter() {
        Intent intent = requireActivity().getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            from = (String) bundle.get("from");
            type = (String) bundle.get("type");

            Log.e("tag" , "from is :"+from);
            Log.e("tag" , "type is :"+type);

            assert type != null;
            if(type.equals("update")){
                freelancerListModel = (FreelancerListModel) bundle.get("freelancerListModel");
            }

        }
    }


    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(getActivity()).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void initiate(View view){
        progressDialog = new ProgressDialog(getActivity());
        skillsList = new ArrayList<>();
        categoriesList = new ArrayList<>();
        citiesList = new ArrayList<>();
        areasList = new ArrayList<>();

        generalInfoLayout = view.findViewById(R.id.generalInfoLayout);
        generalInfoLayout.setVisibility(GONE);
        nameET = view.findViewById(R.id.nameET);
        emailET = view.findViewById(R.id.emailET);
        phoneET = view.findViewById(R.id.phoneET);
        hourlyRateET = view.findViewById(R.id.hourlyRateET);

        multiSelectAutoCompleteView = view.findViewById(R.id.multiSelectAutoCompleteView);
        multiSelectAutoCompleteView.setHint("Search Skills");
        multiSelectAutoCompleteView.setInputType(InputType.TYPE_CLASS_TEXT);
        multiSelectAutoCompleteView.setMaxLength(0);

        categorySpinner = (Spinner) view.findViewById(R.id.categorySpinner);
        citySpinner = (Spinner) view.findViewById(R.id.citySpinner);
        areaSpinner = (Spinner) view.findViewById(R.id.areaSpinner);
        cbHourly = view.findViewById(R.id.cbHourly);
        fromTimeET = view.findViewById(R.id.fromTimeET);
        toTimeET = view.findViewById(R.id.toTimeET);

        chooseImages = view.findViewById(R.id.chooseImages);
        chooseVideo = view.findViewById(R.id.chooseVideo);
        videoView = view.findViewById(R.id.videoView);
        videoView.setVisibility(GONE);

        newCustomImagesAdapter = new NewCustomImagesAdapter(getActivity() , this);
        customImagesRecyclerView = view.findViewById(R.id.customImagesRecyclerView);
        customImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(getActivity() , 3 ,  GridLayoutManager.VERTICAL , false);
        customImagesRecyclerView.setLayoutManager(gridLayoutManager);
        customImagesRecyclerView.setAdapter(newCustomImagesAdapter);

        btnNext = view.findViewById(R.id.btnNext);
        addFreelancerViewModel = new ViewModelProvider(requireActivity()).get(AddFreelancerViewModel.class);

        if(from.equals("user")){
            nameET.setVisibility(GONE);
            emailET.setVisibility(GONE);
            phoneET.setVisibility(GONE);
            chooseImages.setVisibility(GONE);
            chooseVideo.setVisibility(GONE);
        }

    }

    public void setDataToWidget(){
        if(freelancerListModel != null){
            nameET.setText(freelancerListModel.getName());
            emailET.setText(freelancerListModel.getEmail());
            phoneET.setText(freelancerListModel.getPhone());
            hourlyRateET.setText(freelancerListModel.getHourly_rate());
            fromTimeET.setText(parseTime(freelancerListModel.getFrom_time()));
            toTimeET.setText(parseTime(freelancerListModel.getTo_time()));

            if(freelancerListModel.getIs_available_as_freelancer().equals("1")){
                cbHourly.setChecked(true);
            }

            if(!freelancerListModel.getSkills().isEmpty()){
                ArrayList<FreelancerSkillsModel> skillList = new ArrayList<>();
                for (int i = 0 ; i< freelancerListModel.getSkills().size() ; i++) {
                    skillList.add(new FreelancerSkillsModel(freelancerListModel.getSkills().get(i).getSkill_id() , freelancerListModel.getSkills().get(i).getSkill_title()));
                }
                multiSelectAutoCompleteView.setSelection(skillList);
            }



            if(!categoriesList.isEmpty()){
                for (int i = 0; i < categoriesList.size(); i++) {
                    if (categoriesList.get(i).getId().equals(freelancerListModel.getJob_category())) { // Or compare by name, or a unique identifier
                        categorySpinner.setSelection(i);
                        break;
                    }
                }
            }

            if(!citiesList.isEmpty()){
                for (int i = 0; i < citiesList.size(); i++) {
                    if (citiesList.get(i).getId().equals(freelancerListModel.getCity_id())) { // Or compare by name, or a unique identifier
                        citySpinner.setSelection(i);
                        break;
                    }
                }
            }



        }
    }

    public void clickListener(){

        fromTimeET.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showTimePicker(fromTimeET, true);
            }
        });

        toTimeET.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showTimePicker(toTimeET, false);

            }
        });

        chooseImages.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                pickImageMedia.launch(new PickVisualMediaRequest.Builder()
                        .setMediaType(ActivityResultContracts.PickVisualMedia.ImageOnly.INSTANCE)
                        .build());
            }
        });

        chooseVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                pickVideoMedia.launch(new PickVisualMediaRequest.Builder()
                        .setMediaType(ActivityResultContracts.PickVisualMedia.VideoOnly.INSTANCE)
                        .build());
            }
        });

        btnNext.setOnClickListener(v -> {

            nameETStr = nameET.getText().toString();
            emailETStr = emailET.getText().toString();
            phoneETStr = phoneET.getText().toString();
            hourlyRateETStr = hourlyRateET.getText().toString();
            fromTimeETStr = fromTimeET.getText().toString();
            toTimeETStr = toTimeET.getText().toString();
            ArrayList<IdModel> areaIds =  multiSelectAutoCompleteView.getSelectedItems(IdModel::new);
            selectedSkills = new Gson().toJson(areaIds);

            if(cbHourly.isChecked()){
                selectedPerHour = "1";
            }else {
                selectedPerHour = "0";
            }

            if(nameETStr.isEmpty() && from.equals("vendor")){
                Toast.makeText(getActivity(), "Please enter name", Toast.LENGTH_SHORT).show();
            }else if(emailETStr.isEmpty()& from.equals("vendor")){
                Toast.makeText(getActivity(), "Please enter email address", Toast.LENGTH_SHORT).show();
            }else if (!Patterns.EMAIL_ADDRESS.matcher(emailETStr).matches() && from.equals("vendor")) {
                Toast.makeText(getActivity(), "Please enter valid email address", Toast.LENGTH_SHORT).show();
            }else if(phoneETStr.toString().isEmpty() && from.equals("vendor")){
                Toast.makeText(getActivity(), "Please enter phone", Toast.LENGTH_SHORT).show();
            }else if(hourlyRateETStr.isEmpty()){
                Toast.makeText(getActivity(), "Please enter hourly rare", Toast.LENGTH_SHORT).show();
            }else if(selectedSkills.equals("[]")){
                Toast.makeText(getActivity(), "Please select skills", Toast.LENGTH_SHORT).show();
            }else if(selectedCategory.equals("0")){
                Toast.makeText(getActivity(), "Please select category", Toast.LENGTH_SHORT).show();
            }else if(selectedCity.equals("0")){
                Toast.makeText(getActivity(), "Please select city", Toast.LENGTH_SHORT).show();
            }else if(selectedArea.equals("0")){
                Toast.makeText(getActivity(), "Please select area", Toast.LENGTH_SHORT).show();
            }else if(fromTimeETStr.isEmpty()){
                Toast.makeText(getActivity(), "Please select from time", Toast.LENGTH_SHORT).show();
            }else if(toTimeETStr.isEmpty()){
                Toast.makeText(getActivity(), "Please select to time", Toast.LENGTH_SHORT).show();
            }
            else if(imageURI == null && type.equals("add") && from.equals("vendor")){
                Toast.makeText(getActivity(), "Please select image", Toast.LENGTH_SHORT).show();
            }
//            else if(videoURI == null && type.equals("add") && from.equals("vendor")){
//                Toast.makeText(getActivity(), "Please select video", Toast.LENGTH_SHORT).show();
//            }
            else {

                Log.e("tag" , "nameETStr is : "+nameETStr);
                Log.e("tag" , "emailETStr is : "+emailETStr);
                Log.e("tag" , "phoneETStr is : "+phoneETStr);
                Log.e("tag" , "hourlyRateETStr is : "+hourlyRateETStr);
                Log.e("tag" , "selectedSkills is : "+selectedSkills);
                Log.e("tag" , "selectedCategory is : "+selectedCategory);
                Log.e("tag" , "selectedCity is : "+selectedCity);
                Log.e("tag" , "selectedArea is : "+selectedArea);
                Log.e("tag" , "selectedPerHour is : "+selectedPerHour);
                Log.e("tag" , "fromTimeETStr is : "+fromTimeETStr);
                Log.e("tag" , "toTimeETStr is : "+toTimeETStr);
                Log.e("tag" , "imageURI is : "+imageURI);
                Log.e("tag" , "videoURI is : "+videoURI);



                addFreelancerViewModel.setName(nameETStr);
                addFreelancerViewModel.setEmail(emailETStr);
                addFreelancerViewModel.setPhone(phoneETStr);
                addFreelancerViewModel.setHourlyRate(hourlyRateETStr);
                addFreelancerViewModel.setSkills(selectedSkills);
                addFreelancerViewModel.setCategory(selectedCategory);
                addFreelancerViewModel.setCity(selectedCity);
                addFreelancerViewModel.setArea(selectedArea);
                addFreelancerViewModel.setPerHour(selectedPerHour);
                addFreelancerViewModel.setFromTime(fromTimeETStr);
                addFreelancerViewModel.setToTime(toTimeETStr);
                addFreelancerViewModel.setImage(imageURI);
                addFreelancerViewModel.setVideo(videoURI);

                ((VendorAddFreelancer) requireActivity()).nextPage();
            }


        });
    }

    ActivityResultLauncher<PickVisualMediaRequest> pickImageMedia =
            registerForActivityResult(new ActivityResultContracts.PickVisualMedia(), uri -> {
                // Callback is invoked after the user selects a media item or closes the
                // photo picker.
                if (uri != null) {
                    imageURI = uri;
                    selectedImages = new ArrayList<>();
                    selectedImages.add(new NewCustomImagesModel(imageURI));
                    customImagesRecyclerView.setVisibility(VISIBLE);
                    newCustomImagesAdapter.setData(selectedImages);
                    Log.e("PhotoPicker", "Selected URI: " + uri);
                } else {
                    Log.e("PhotoPicker", "No media selected");
                }
            });

    ActivityResultLauncher<PickVisualMediaRequest> pickVideoMedia =
            registerForActivityResult(new ActivityResultContracts.PickVisualMedia(), uri -> {
                // Callback is invoked after the user selects a media item or closes the
                // photo picker.
                if (uri != null) {

                    playVideo(uri);

                    Log.e("PhotoPicker", "Selected URI: " + uri);
                } else {
                    Log.e("PhotoPicker", "No media selected");
                }
            });

    // Play the video using VideoView
    private void playVideo(Uri uri) {
        videoURI = uri;
        videoView.setVisibility(VISIBLE);
        videoView.setVideoURI(uri);

        MediaController mediaController = new MediaController(getActivity());
        mediaController.setAnchorView(videoView);

        videoView.setMediaController(mediaController);
        videoView.requestFocus();
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                
            }
        });

    }
    private void getFreelancerDataAPI() {

        //The gson builder
        Gson gson = new GsonBuilder()
                .setLenient()
                .create();

        OkHttpClient okHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(120, TimeUnit.SECONDS)
                .readTimeout(120, TimeUnit.SECONDS)
                .writeTimeout(120, TimeUnit.SECONDS)
                .build();

        //creating retrofit object
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(ApiUrls.API_URL)
                .client(SSSHandShake.getUnsafeOkHttpClient())
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build();

        showProgress();

        RetrofitApi retrofitApi = retrofit.create(RetrofitApi.class);

        //creating a call and calling the upload image method
        call = retrofitApi.freelancerDataAPI();

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        generalInfoLayout.setVisibility(VISIBLE);

                        skillsList = response.body().getFreelancer_skills();

                        multiSelectAutoCompleteView.setItems(skillsList , FreelancerSkillsModel::getTitle , FreelancerSkillsModel::getId);
                        //multiSelectAutoCompleteView.showDropdown();

                        categoriesList.add(new VendorJobCategoriesModel("0" , "Select Category" ,"حدد الفئة"));
                        categoriesList.addAll(response.body().getFreelancer_categories());

                        citiesList.add(new VendorJobCitiesModel("0" , "Select City" ,"اختر المدينة" , new ArrayList<>()));
                        citiesList.addAll(response.body().getFreelancer_cities());

                        Log.e("tag" , "list size is : "+skillsList.size());
                        Log.e("tag" , "categories list size is : "+categoriesList.size());
                        Log.e("tag" , "cities list size is : "+citiesList.size());

                        dataSetToSpinner();

                        assert type != null;
                        if(type.equals("update")){
                            setDataToWidget();
                        }



                    }
                    else
                    {
                        Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if(call.isCanceled())
                {
                    Log.e("tag" , "request is cancelled");
                }
                else
                {
                    hideProgress();
                    Toast.makeText(getActivity() , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void showProgress()
    {
        progressDialog.setCancelable(false);
        progressDialog.show();
        progressDialog.setContentView(R.layout.progress_dialog);
        progressDialog.getWindow().setBackgroundDrawable(null);
    }

    public void hideProgress()
    {
        progressDialog.dismiss();
    }

    public void dataSetToSpinner(){


        JobCategoriesSpinnerAdapter jobCategoriesSpinnerAdapter = new JobCategoriesSpinnerAdapter(getActivity() , categoriesList , selectedLanguage);
        categorySpinner.setAdapter(jobCategoriesSpinnerAdapter);


        categorySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedCategory = "0";
                selectedCategory = categoriesList.get(i).getId();


                Log.e("tag" , "selectedCategory is : "+selectedCategory);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });


        JobCitiesSpinnerAdapter jobCitiesSpinnerAdapter = new JobCitiesSpinnerAdapter(getActivity() , citiesList , selectedLanguage);
        citySpinner.setAdapter(jobCitiesSpinnerAdapter);

        citySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                areasList = new ArrayList<>();
                selectedCity = "0";
                selectedCity = citiesList.get(i).getId();

                Log.e("tag" , "selectedCity is "+selectedCity);

                areasList.add(new AreaModel("0" , "Select Area" , "حدد المنطقة"));
                areasList.addAll(citiesList.get(i).getAreas());

                AreaSpinnerAdapter areaSpinnerAdapter = new AreaSpinnerAdapter(getActivity() , areasList , selectedLanguage);
                areaSpinner.setAdapter(areaSpinnerAdapter);

                assert type != null;
                if(type.equals("update")){

                    if(!areasList.isEmpty()){
                        for (int j = 0; j < areasList.size(); j++) {
                            if (areasList.get(j).getArea_id().equals(freelancerListModel.getArea_id())) { // Or compare by name, or a unique identifier
                                areaSpinner.setSelection(j);
                                break;
                            }
                        }
                    }

                }


                areaSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                        selectedArea = "0";
                        selectedArea = areasList.get(i).getArea_id();

                        Log.e("tag" , "selected area id is : "+selectedArea);
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> adapterView) {

                    }
                });

            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

    }

    private void showTimePicker(EditText timeEditText, boolean isFromTime) {
        // Use the previously selected time for the picker's initial state, or current time
        Calendar initialTime = isFromTime ? fromTimeCalendar : toTimeCalendar;
        if (initialTime == null) {
            initialTime = Calendar.getInstance();
        }

        int hour = initialTime.get(Calendar.HOUR_OF_DAY);
        int minute = initialTime.get(Calendar.MINUTE);

        TimePickerDialog timePickerDialog = new TimePickerDialog(getActivity(), (view, hourOfDay, minuteOfHour) -> {
            Calendar selectedTime = Calendar.getInstance();
            selectedTime.set(Calendar.HOUR_OF_DAY, hourOfDay);
            selectedTime.set(Calendar.MINUTE, minuteOfHour);


            if (isFromTime) {
                // User is setting the 'From' time.
                // Check if a 'To' time exists and if the new 'From' time is after it.
                if (toTimeCalendar != null && selectedTime.after(toTimeCalendar)) {
                    Toast.makeText(getActivity(), "'From' time cannot be after 'To' time", Toast.LENGTH_SHORT).show();
                    return; // Reject the change
                }
            } else {
                // User is setting the 'To' time.
                // Check if a 'From' time exists and if the new 'To' time is before it.
                if (fromTimeCalendar != null && selectedTime.before(fromTimeCalendar)) {
                    Toast.makeText(getActivity(), "'To' time cannot be before 'From' time", Toast.LENGTH_SHORT).show();
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


        }, hour, minute, false); // false for 12-hour format with AM/PM

        timePickerDialog.show();
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


    @Override
    public void selectedImages(int pos) {
        imageURI = null;
        selectedImages.remove(pos);
        newCustomImagesAdapter.setData(selectedImages);
    }
}