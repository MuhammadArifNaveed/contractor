package com.thecontractor;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.PickVisualMediaRequest;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.MediaController;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.JobCategoriesSpinnerAdapter;
import com.thecontractor.Adapter.JobCitiesSpinnerAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImagePartFromUri;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorJobCategoriesModel;
import com.thecontractor.Model.VendorJobCitiesModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorAddFreelancer;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;
import static android.view.View.GONE;
import static android.view.View.VISIBLE;

public class UpdateProfile extends AppCompatActivity {
    private int REQUEST_CAMERA = 0, SELECT_FILE = 1;
    public String imagePath  = "path";
    public Uri imageURI;
    public Uri videoURI;
    public Uri CVURI;
    VideoView videoView;
    MultipartBody.Part fileToUploadImage;
    MultipartBody.Part fileToUploadVideo;
    MultipartBody.Part fileToUploadCV;
    private String  userChoosenTask;
    public static final int REQUEST_MULTIPLE_PERMISSION_CODE = 500;
    private ActivityResultLauncher<String> cameraPermissionLauncher;
    private ActivityResultLauncher<Uri> cameraLauncher;
    private ActivityResultLauncher<PickVisualMediaRequest> galleryLauncher;
    private ActivityResultLauncher<PickVisualMediaRequest> VideoGalleryLauncher;
    private ActivityResultLauncher<String[]> pdfPickerLauncher;

    ImageView profileImage;
    EditText fistNameET , lastNameET  , addressET  , mobileET , emailET;
    String fistNameETStr;
    String lastNameETStr;
    String addressETStr;
    String mobileETStr;
    String emailETStr;
    String imageStr;
    String videoStr;
    String CVStr;
    Spinner citySpinner, categorySpinner;
    String vendorId;
    String userId;
    String userType;
    String userUUID;
    Button chooseVideo , chooseCV , updateProfileBtn;
    TextView CVName , videoName;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    ArrayList<VendorJobCitiesModel> citiesList;
    ArrayList<VendorJobCategoriesModel> categoriesList;
    String selectedCategory = "0";
    String selectedCity = "0";
    String selectedLanguage = "en";
    LinearLayout updateProfileLayout;
    private static final long IMAGE_MAX_FILE_SIZE = 2;
    private static final long VIDEO_MAX_FILE_SIZE = 5;
    private static final long CV_MAX_FILE_SIZE = 1;
    TextView updateFreelancer;
    CheckBox cbJob , cbFreelancer;
    String isAvailableForJob , isAvailableFreelancer;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_update_profile);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.update_profile));

        getDataFromSP();
        initiate();
        initLaunchers();
        clickListener();
        getCityCategoryAPI();

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        switch (menuItem.getItemId()) {
            case android.R.id.home:
                this.finish();
                return true;
            default:
                return super.onOptionsItemSelected(menuItem);
        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(UpdateProfile.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(UpdateProfile.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(UpdateProfile.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(UpdateProfile.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();
            userUUID = userModel.getUuid();
            userType = userModel.getUser_type();
            vendorId = userId;

            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);
            Log.e("tag" , "vendor id is : "+vendorId);

        }
    }




    public void initiate()
    {
        progressDialog = new ProgressDialog(UpdateProfile.this);
        citiesList = new ArrayList<>();
        categoriesList = new ArrayList<>();


        profileImage = (ImageView) findViewById(R.id.profileImage);
        fistNameET = (EditText) findViewById(R.id.fistNameET);
        lastNameET = (EditText) findViewById(R.id.lastNameET);
        addressET = (EditText) findViewById(R.id.addressET);
        mobileET = (EditText) findViewById(R.id.mobileET);
        emailET = (EditText) findViewById(R.id.emailET);
        citySpinner = (Spinner) findViewById(R.id.citySpinner);
        categorySpinner = (Spinner) findViewById(R.id.categorySpinner);

        updateProfileBtn = (Button) findViewById(R.id.updateProfileBtn);
        chooseVideo = (Button) findViewById(R.id.chooseVideo);
        chooseCV = (Button) findViewById(R.id.chooseCV);
        CVName = (TextView) findViewById(R.id.CVName);
        CVName.setText("Upload CV upto " + CV_MAX_FILE_SIZE + " MB");
        videoName = (TextView) findViewById(R.id.videoName);
        videoName.setText("Upload Video upto " + VIDEO_MAX_FILE_SIZE + " MB");
        updateProfileLayout = (LinearLayout) findViewById(R.id.updateProfileLayout);
        updateProfileLayout.setVisibility(GONE);
        videoView = findViewById(R.id.videoView);
        videoView.setVisibility(GONE);
        updateFreelancer = (TextView) findViewById(R.id.updateFreelancer);
        cbJob = (CheckBox) findViewById(R.id.cbJob);
        cbFreelancer = (CheckBox) findViewById(R.id.cbFreelancer);


    }



    public void getUserDataFromSPForWidget() {
        if (!SharedPrefManager.getInstance(UpdateProfile.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(UpdateProfile.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);

            imageStr = userModel.getImage();
            if(imageStr == null){
                imageStr = "";
            }

            videoStr = userModel.getVideo();
            if(videoStr == null){
                videoStr = "";
            }
            CVStr = userModel.getCv();
            fistNameETStr = userModel.getName();
            lastNameETStr = userModel.getSurname();
            addressETStr = userModel.getAddress();
            mobileETStr = userModel.getPhone();
            emailETStr = userModel.getEmail();
            selectedCategory = userModel.getCv_job_category();
            selectedCity = userModel.getCity_id();
            isAvailableForJob = userModel.getIs_available_for_job();
            isAvailableFreelancer = userModel.getIs_available_as_freelance();
        }
    }


    public void setUserDataToWidget(){

        fistNameET.setText(fistNameETStr);
        lastNameET.setText(lastNameETStr);

        if(!addressETStr.isEmpty())
        {
            addressET.setText(addressETStr);

        }

        emailET.setText(emailETStr);
        mobileET.setText(mobileETStr);

        if(isAvailableForJob.equals("1")){
            cbJob.setChecked(true);
            cbJob.setText("Yes, i am available for job");
        }else {
            cbJob.setChecked(false);
            cbJob.setText("No, i am not available for job");
        }


        if(isAvailableFreelancer.equals("1")){
            cbFreelancer.setChecked(true);
            cbFreelancer.setText("Yes, i am available as freelancer");
        }else {
            cbFreelancer.setChecked(false);
            cbFreelancer.setText("No, I am not avaible as freelancer");
        }

        if(!imageStr.equals(""))
        {
            Glide.with(UpdateProfile.this)
                    .load(ApiUrls.PROFILE_IMAGE_URL+imageStr)
                    .apply(new RequestOptions().circleCrop().placeholder(R.drawable.ic_user_profile).error(R.drawable.ic_user_profile))
                    .into(profileImage);
        }

        if(videoStr.isEmpty())
        {
            Uri uri = Uri.parse(ApiUrls.PROFILE_VIDEO_URL + videoStr);
            playVideo(uri , "sharedPref");

        }

        if(!categoriesList.isEmpty()){
            for (int i = 0; i < categoriesList.size(); i++) {
                if (categoriesList.get(i).getId().equals(selectedCategory)) { // Or compare by name, or a unique identifier
                    categorySpinner.setSelection(i);
                    break;
                }
            }
        }


        if(!citiesList.isEmpty()){
            for (int i = 0; i < citiesList.size(); i++) {
                if (citiesList.get(i).getId().equals(selectedCity)) { // Or compare by name, or a unique identifier
                    citySpinner.setSelection(i);
                    break;
                }
            }
        }

    }

    private void initLaunchers() {

        // CAMERA PERMISSION
        cameraPermissionLauncher =
                registerForActivityResult(
                        new ActivityResultContracts.RequestPermission(),
                        granted -> {
                            if (granted) {
                                openCamera();
                            } else {
                                Toast.makeText(this, "Camera permission denied", Toast.LENGTH_SHORT).show();
                            }
                        }
                );

        // CAMERA CAPTURE
        cameraLauncher =
                registerForActivityResult(
                        new ActivityResultContracts.TakePicture(),
                        success -> {
                            if (success) {
                                if (ImagePartFromUri.isFileSizeValid(this, imageURI , IMAGE_MAX_FILE_SIZE)) {
                                    //profileImage.setImageURI(imageURI);
                                    Glide.with(this)
                                            .load(imageURI)
                                            .apply(new RequestOptions().circleCrop().placeholder(R.drawable.ic_user_profile).error(R.drawable.ic_user_profile))
                                            .into(profileImage);
                                }

                            }
                        }
                );

        // GALLERY PICKER (IMAGE ONLY)
        galleryLauncher =
                registerForActivityResult(
                        new ActivityResultContracts.PickVisualMedia(),
                        uri -> {
                            if (uri != null) {
                                imageURI = uri;
                                if (ImagePartFromUri.isFileSizeValid(this, imageURI , IMAGE_MAX_FILE_SIZE)) {
                                    //profileImage.setImageURI(imageURI);
                                    Glide.with(this)
                                            .load(imageURI)
                                            .apply(new RequestOptions().circleCrop().placeholder(R.drawable.ic_user_profile).error(R.drawable.ic_user_profile))
                                            .into(profileImage);
                                }

                            }else {
                                Log.e("tag", "No image selected");
                            }
                        }
                );


        // GALLERY PICKER (VIDEO ONLY)
        VideoGalleryLauncher =
                registerForActivityResult(
                        new ActivityResultContracts.PickVisualMedia(),
                        uri -> {
                            if (uri != null) {
                                videoURI = uri;
                                if (ImagePartFromUri.isFileSizeValid(this, videoURI , VIDEO_MAX_FILE_SIZE)) {
                                    playVideo(videoURI , "storage");
                                }

                            }else {
                                Log.e("tag", "No video selected");
                            }
                        }
                );

        pdfPickerLauncher =
                registerForActivityResult(
                        new ActivityResultContracts.OpenDocument(),
                        uri -> {
                            if (uri != null) {
                                if (ImagePartFromUri.isFileSizeValid(this, uri , CV_MAX_FILE_SIZE)) {
                                    handlePdf(uri);
                                }

                            }
                        }
                );



    }

    private void playVideo(Uri uri , String from) {
        if(from.equals("storage")){
            videoURI = uri;
        }
        videoView.setVisibility(VISIBLE);
        videoView.setVideoURI(uri);

        MediaController mediaController = new MediaController(UpdateProfile.this);
        mediaController.setAnchorView(videoView);

        videoView.setMediaController(mediaController);
        videoView.requestFocus();
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {

            }
        });

    }

    private void showPickDialog() {
        String[] options = {"Camera", "Gallery"};

        new AlertDialog.Builder(this)
                .setTitle("Select Image")
                .setItems(options, (dialog, which) -> {
                    if (which == 0) {
                        checkCameraPermission();
                    } else {
                        openGallery();
                    }
                })
                .show();
    }

    // ---------------- CAMERA ----------------
    private void checkCameraPermission() {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED) {

            openCamera();

        } else {
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA);
        }
    }

    private void openCamera() {
        imageURI = createImageUri();
        cameraLauncher.launch(imageURI);
    }

    private Uri createImageUri() {
        ContentValues values = new ContentValues();
        values.put(MediaStore.Images.Media.TITLE, "Camera Image");
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");

        return getContentResolver().insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                values
        );
    }

    // ---------------- GALLERY ----------------
    private void openGallery() {
        galleryLauncher.launch(
                new PickVisualMediaRequest.Builder()
                        .setMediaType(
                                ActivityResultContracts.PickVisualMedia.ImageOnly.INSTANCE
                        )
                        .build()
        );
    }

    private void openVideoGallery() {
        VideoGalleryLauncher.launch(
                new PickVisualMediaRequest.Builder()
                        .setMediaType(
                                ActivityResultContracts.PickVisualMedia.VideoOnly.INSTANCE
                        )
                        .build()
        );
    }

    private void openPdfPicker() {
        pdfPickerLauncher.launch(
                new String[]{"application/pdf"}
        );
    }

    private void handlePdf(Uri uri) {
        getContentResolver().takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
        );

        CVURI = uri;
        CVName.setText(ImagePartFromUri.getFileNameFromUri(UpdateProfile.this , uri));

        Toast.makeText(this, "PDF Selected", Toast.LENGTH_SHORT).show();
    }


    public void clickListener()
    {

        profileImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                showPickDialog();

//                if(checkPermission())
//                {
//                    selectImage();
//
//                }
//                else
//                {
//                    requestPermission();
//                }

            }
        });

        chooseVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openVideoGallery();
            }
        });


        chooseCV.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openPdfPicker();

            }
        });


        cbJob.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateUserJobStatusAPI();
            }
        });

        cbFreelancer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String status;
                if(cbFreelancer.isChecked()){
                    status = "1";
                }else {
                    status = "0";
                }

                updateUserFreelancerStatusAPI(status);
            }
        });

        updateFreelancer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                checkUserFreelancerDataAPI();
            }
        });

        updateProfileBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                fistNameETStr = fistNameET.getText().toString();
                lastNameETStr = lastNameET.getText().toString();
                addressETStr = addressET.getText().toString();
                mobileETStr = mobileET.getText().toString();
                emailETStr = emailET.getText().toString();

                if(imageStr.isEmpty())
                {
                    Toast.makeText(UpdateProfile.this, "Select Image", Toast.LENGTH_SHORT).show();
                }else if(fistNameETStr.equals(""))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.enter_name_error), Toast.LENGTH_SHORT).show();
                }else if(lastNameETStr.equals(""))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.enter_sur_name_error), Toast.LENGTH_SHORT).show();
                }else if(emailETStr.equals(""))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.enter_email_address_error), Toast.LENGTH_SHORT).show();
                }else if(!isValidEmail(emailETStr))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.enter_valid_email_address), Toast.LENGTH_SHORT).show();
                }else if(mobileETStr.equals(""))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.phone_no_error), Toast.LENGTH_SHORT).show();
                }else if(selectedCity.equals("0"))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.select_city), Toast.LENGTH_SHORT).show();
                }else if(addressETStr.equals(""))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.enter_address_error), Toast.LENGTH_SHORT).show();
                }else if(videoStr.isEmpty())
                {
                    Toast.makeText(UpdateProfile.this, "Select Video", Toast.LENGTH_SHORT).show();
                }else if(selectedCategory.equals("0"))
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.select_category), Toast.LENGTH_SHORT).show();
                }else if(CVStr.isEmpty())
                {
                    Toast.makeText(UpdateProfile.this, "Select CV", Toast.LENGTH_SHORT).show();
                }else
                {
                    updateProfile();
                }


            }
        });
    }


    public static boolean isValidEmail(final String emailAddress) {

        Pattern pattern;
        Matcher matcher;

        final String EMAIL_PATTERN = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

        pattern = Pattern.compile(EMAIL_PATTERN);
        matcher = pattern.matcher(emailAddress);
        return matcher.matches();
    }



    public void dataSetToSpinner(){

        JobCitiesSpinnerAdapter jobCitiesSpinnerAdapter = new JobCitiesSpinnerAdapter(UpdateProfile.this , citiesList , selectedLanguage);
        citySpinner.setAdapter(jobCitiesSpinnerAdapter);

        citySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                selectedCity = "0";
                selectedCity = citiesList.get(i).getId();

                Log.e("tag" , "selectedCity is "+selectedCity);

            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        JobCategoriesSpinnerAdapter jobCategoriesSpinnerAdapter = new JobCategoriesSpinnerAdapter(UpdateProfile.this , categoriesList , selectedLanguage);
        categorySpinner.setAdapter(jobCategoriesSpinnerAdapter);


        categorySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedCategory = "0";
                selectedCategory = categoriesList.get(i).getTitle();


                Log.e("tag" , "selectedCategory is : "+selectedCategory);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

    }

    private AlertDialog AlertDialog(String message , String type)
    {
        AlertDialog myDialogBox = new AlertDialog.Builder(UpdateProfile.this)
                // set message, title, and icon
                .setTitle("Alert")
                .setMessage(message)
                .setPositiveButton("Update", new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int whichButton) {
                        //your deleting code
                        dialog.dismiss();
                        if(type.equals("incomplete") || type.equals("open_modal")){
                            checkUserFreelancerDataAPI();
                        }else if(type.equals("expired")){

                        }
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                })
                .create();

        return myDialogBox;
    }

    private void getCityCategoryAPI() {

        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));

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
        call = retrofitApi.getUserDetailById(user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        updateProfileLayout.setVisibility(VISIBLE);

                        UserModel userModel = response.body().getUser();

                        Gson gson = new Gson();
                        String sharedPrefModelStr = gson.toJson(userModel);
                        SharedPrefManager.getInstance(UpdateProfile.this).userLogin(sharedPrefModelStr);

                        citiesList.add(new VendorJobCitiesModel("0" , "Select City" ,"اختر المدينة" , new ArrayList<>()));
                        citiesList.addAll(response.body().getFreelancer_cities());

                        categoriesList.add(new VendorJobCategoriesModel("0" , "Select Category" ,"حدد الفئة"));
                        categoriesList.addAll(response.body().getFreelancer_categories());

                        Log.e("tag" , "cities list size is : "+citiesList.size());
                        Log.e("tag" , "categories list size is : "+categoriesList.size());

                        getUserDataFromSPForWidget();
                        dataSetToSpinner();
                        setUserDataToWidget();


                    }
                    else
                    {
                        Toast.makeText(UpdateProfile.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(UpdateProfile.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    private void updateUserJobStatusAPI() {

        RequestBody user_uuid = RequestBody.create(userUUID , MediaType.parse("text/plain"));

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
        call = retrofitApi.userJobStatusApi(user_uuid);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        if(response.body().getStatus().equals("true")){
                            cbJob.setText("Yes, i am available for job");
                        }else {
                            cbJob.setText("No, I am not avaible for job");
                        }
                    }
                    else
                    {
                        cbJob.setChecked(!cbJob.isChecked());
                        Toast.makeText(UpdateProfile.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    cbJob.setChecked(!cbJob.isChecked());
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                cbFreelancer.setChecked(!cbFreelancer.isChecked());
                if(call.isCanceled())
                {
                    Log.e("tag" , "request is cancelled");
                }
                else
                {
                    hideProgress();
                    Toast.makeText(UpdateProfile.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }



    private void updateUserFreelancerStatusAPI(String status) {

        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody mStatus = RequestBody.create(status , MediaType.parse("text/plain"));

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
        call = retrofitApi.updateUserFreelanceStatus(user_id , user_type , vendor_id , mStatus);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        if(response.body().getAction().equals("incomplete") || response.body().getAction().equals("open_modal")){
                            cbFreelancer.setChecked(!cbFreelancer.isChecked());
                            AlertDialog alertDialog = AlertDialog(response.body().getMessage() , response.body().getAction());
                            alertDialog.show();
                        }else if(response.body().getAction().equals("expired")){
                            cbFreelancer.setChecked(!cbFreelancer.isChecked());
                            AlertDialog alertDialog = AlertDialog(response.body().getMessage() , response.body().getAction());
                            alertDialog.show();
                        }else if(response.body().getAction().equals("exists") || response.body().getAction().equals("unavailable")){
                            cbFreelancer.setChecked(response.body().isAvailable());
                            if(response.body().isAvailable()){
                                cbFreelancer.setText("Yes, i am available as freelancer");
                            }else {
                                cbFreelancer.setText("No, I am not avaible as freelancer");
                            }
                        }


                    }
                    else
                    {
                        cbFreelancer.setChecked(!cbFreelancer.isChecked());
                        Toast.makeText(UpdateProfile.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    cbFreelancer.setChecked(!cbFreelancer.isChecked());
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                cbFreelancer.setChecked(!cbFreelancer.isChecked());
                if(call.isCanceled())
                {
                    Log.e("tag" , "request is cancelled");
                }
                else
                {
                    hideProgress();
                    Toast.makeText(UpdateProfile.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void checkUserFreelancerDataAPI() {

        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));


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
        call = retrofitApi.userFreelancerData(user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        if(response.body().getStatus().equals("false")){
                            Intent intent = new Intent(UpdateProfile.this , VendorAddFreelancer.class);
                            Bundle b = new Bundle();
                            intent.putExtra("from" , "user");
                            b.putString("type" , "add");
                            intent.putExtras(b);
                            startActivity(intent);
                        }else {

                            FreelancerListModel freelancerListModel = response.body().getUser_freelancer_details();

                            Intent intent = new Intent(UpdateProfile.this , VendorAddFreelancer.class);
                            Bundle b = new Bundle();
                            b.putParcelable("freelancerListModel", freelancerListModel);
                            intent.putExtra("from" , "user");
                            b.putString("type" , "update");
                            intent.putExtras(b);
                            startActivity(intent);
                        }

                    }
                    else
                    {
                        Toast.makeText(UpdateProfile.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(UpdateProfile.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }




    private void updateProfile() {


        if(imageURI != null) {
            fileToUploadImage = ImagePartFromUri.createPartFromUri(UpdateProfile.this, imageURI, "user_image");
        }

        if(videoURI != null) {

            fileToUploadVideo = ImagePartFromUri.createPartFromUri(UpdateProfile.this, videoURI, "user_video");
        }

        if(CVURI != null) {
            fileToUploadCV = ImagePartFromUri.createPartFromUri(UpdateProfile.this, CVURI, "cv");
        }

        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody firstName = RequestBody.create(fistNameETStr , MediaType.parse("text/plain"));
        RequestBody lastName = RequestBody.create(lastNameETStr , MediaType.parse("text/plain"));
        RequestBody mobileNo = RequestBody.create(mobileETStr , MediaType.parse("text/plain"));
        RequestBody email = RequestBody.create(emailETStr , MediaType.parse("text/plain"));
        RequestBody address = RequestBody.create(addressETStr , MediaType.parse("text/plain"));
        RequestBody city = RequestBody.create(selectedCity , MediaType.parse("text/plain"));
        RequestBody country = RequestBody.create("2" , MediaType.parse("text/plain"));
        RequestBody jobCategory = RequestBody.create(selectedCategory , MediaType.parse("text/plain"));

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
       call = retrofitApi.updateProfile(user_id , firstName , lastName  , mobileNo ,  email , address , city , country , jobCategory ,
               fileToUploadImage , fileToUploadVideo , fileToUploadCV);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        UserModel userModel = response.body().getUser();


                        Gson gson = new Gson();
                        String sharedPrefModelStr = gson.toJson(userModel);
                        SharedPrefManager.getInstance(UpdateProfile.this).userLogin(sharedPrefModelStr);

                        Intent intent = new Intent(UpdateProfile.this, Home.class);
                        startActivity(intent);
                        finish();

                    }
                    else
                    {
                        Toast.makeText(UpdateProfile.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(UpdateProfile.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(UpdateProfile.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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



//    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        // Inflate the menu; this adds items to the action bar if it is present.
//        getMenuInflater().inflate(R.menu.menu_password, menu);
//
//        MenuItem action_change_password = (MenuItem) menu.findItem(R.id.action_change_password);
//
//        action_change_password.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
//            @Override
//            public boolean onMenuItemClick(MenuItem item) {
//
//                Intent i=new Intent(UpdateProfile.this  ,  ChangePassword.class);
//                startActivity(i);
//
//                return false;
//            }
//        });
//
//        return super.onCreateOptionsMenu(menu);
//    }



    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == REQUEST_CAMERA && resultCode == RESULT_OK) {

            galleryAddPic(imagePath);

            Glide.with(this)
                    .load(imagePath)
                    .apply(new RequestOptions().circleCrop().placeholder(R.drawable.ic_user_profile).error(R.drawable.ic_user_profile))
                    .into(profileImage);

        }

        if (requestCode == SELECT_FILE && resultCode == Activity.RESULT_OK && null != data) {

            Uri selectedImage = data.getData();
            String[] filePathColumn = {MediaStore.Images.Media.DATA};

            // Get the cursor
            Cursor cursor = getContentResolver().query(selectedImage,
                    filePathColumn, null, null, null);
            // Move to first row
            cursor.moveToFirst();

            int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
            imagePath = cursor.getString(columnIndex);
            Log.e("tag", "gallery image path is : " + imagePath);
            cursor.close();
            profileImage.setScaleType(ImageView.ScaleType.FIT_XY);

            Glide.with(this)
                    .load(imagePath)
                    .apply(new RequestOptions().circleCrop().placeholder(R.drawable.ic_user_profile).error(R.drawable.ic_user_profile))
                    .into(profileImage);


        }

        super.onActivityResult(requestCode, resultCode, data);

    }

    private void galleryAddPic(String imagePath) {
        Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        File f = new File(imagePath);
        Uri contentUri = Uri.fromFile(f);
        mediaScanIntent.setData(contentUri);
        this.sendBroadcast(mediaScanIntent);
    }

    private void requestPermission() {

        ActivityCompat.requestPermissions(UpdateProfile.this, new String[]
                {
                        READ_EXTERNAL_STORAGE,
                        WRITE_EXTERNAL_STORAGE
                }, REQUEST_MULTIPLE_PERMISSION_CODE);

    }

    public boolean checkPermission() {

        int ReadStoragePermissionResult = ContextCompat.checkSelfPermission(getApplicationContext(), READ_EXTERNAL_STORAGE);
        int WriteStoragePermissionResult = ContextCompat.checkSelfPermission(getApplicationContext(), WRITE_EXTERNAL_STORAGE);


        return
                ReadStoragePermissionResult == PackageManager.PERMISSION_GRANTED &&
                        WriteStoragePermissionResult == PackageManager.PERMISSION_GRANTED ;

    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {

            case REQUEST_MULTIPLE_PERMISSION_CODE:

                if (grantResults.length > 0) {
                    boolean ReadStoragePermissionResult = grantResults[0] == PackageManager.PERMISSION_GRANTED;
                    boolean WriteStoragePermissionResult = grantResults[1] == PackageManager.PERMISSION_GRANTED;

                    if (ReadStoragePermissionResult && WriteStoragePermissionResult) {

                        selectImage();

                    } else {
                        Toast.makeText(getApplicationContext(), getResources().getString(R.string.permit_all_permission), Toast.LENGTH_LONG).show();
                    }
                }

                break;

        }
    }

    private void selectImage() {
        final CharSequence[] items = { getResources().getString(R.string.take_photo), getResources().getString(R.string.select_from_gallery),
                getResources().getString(R.string.cancel) };

        AlertDialog.Builder builder = new AlertDialog.Builder(UpdateProfile.this);
        builder.setTitle(getResources().getString(R.string.add_photo));
        builder.setItems(items, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int item) {

                if (items[item].equals(getResources().getString(R.string.take_photo))) {
                    userChoosenTask ="Take Photo";

                    cameraIntent();

                } else if (items[item].equals(getResources().getString(R.string.select_from_gallery))) {
                    userChoosenTask ="Select Photo From Gallery";

                    galleryIntent();

                } else if (items[item].equals(getResources().getString(R.string.cancel))) {
                    dialog.dismiss();
                }
            }
        });
        builder.show();
    }

    private void galleryIntent()
    {

        Intent i = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(i, SELECT_FILE);

    }

    private void cameraIntent()
    {

        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        // Ensure that there's a camera activity to handle the intent
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            // Create the File where the photo should go
            File photoFile = null;
            try {
                photoFile = createImageFile();
            } catch (IOException ex) {
                // Error occurred while creating the File
            }
            // Continue only if the File was successfully created
            if (photoFile != null) {
                Uri photoURI = FileProvider.getUriForFile(UpdateProfile.this,
                        getPackageName() + ".fileprovider",
                        photoFile);
                takePictureIntent.putExtra("android.intent.extras.CAMERA_FACING", 1);
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
                startActivityForResult(takePictureIntent, REQUEST_CAMERA);
            }
        }

    }


    private File createImageFile() throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        File image = File.createTempFile(
                imageFileName,  /* prefix */
                ".jpg",         /* suffix */
                storageDir      /* directory */
        );

        // Save a file: path for use with ACTION_VIEW intents
        imagePath = image.getAbsolutePath();
        return image;
    }


}