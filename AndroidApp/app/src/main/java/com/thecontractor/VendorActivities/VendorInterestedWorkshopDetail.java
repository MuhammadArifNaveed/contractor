package com.thecontractor.VendorActivities;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.WorkshopAdImagesAdapter;
import com.thecontractor.Adapter.WorkshopAdInterestedQuotationAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImagePartFromUri;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.Model.WorkshopAdImagesModel;
import com.thecontractor.Model.WorkshopAdModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.UpdateProfile;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class VendorInterestedWorkshopDetail extends AppCompatActivity implements WorkshopAdInterestedQuotationAdapter.QuotationInterface{
    String vendorId;
    String userId;
    String userType;
    String workshopAdId;
    String paidStatusId;


    LinearLayout workshopAdDetailsLayout;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    WorkshopAdModel workshopAdModel;

    TextView bidType;
    TextView workSector;
    TextView workCity;
    TextView paidStatus;
    TextView createdAt;
    TextView workshopStatus;
    TextView title;
    TextView description;
    LinearLayout imagesLayout , quotationsLayout;
    RecyclerView quotationImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    RecyclerView quotationRecyclerView;
    LinearLayoutManager linearLayoutManager ;
    WorkshopAdImagesAdapter workshopAdImagesAdapter;
    WorkshopAdInterestedQuotationAdapter workshopAdInterestedQuotationAdapter;
    String selectedLanguage = "en";
    ArrayList<WorkshopAdImagesModel> imagesArray;
    ArrayList<WorkshopAdModel.QuotationsModel> quotationArray;
    TextView giveQuotation;
    private ActivityResultLauncher<String[]> pdfPickerLauncher;
    private static final long CV_MAX_FILE_SIZE = 1;
    public Uri documentURI;
    MultipartBody.Part fileToUpload;

    TextView fileName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_interested_workshop_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.workshop_ad_detail);

        getLanguageFromSP();
        getVendorDataFromSP();
        getObjectFromAdapter();
        initiate();
        clickListener();
        initLaunchers();
        workshopAdDetailsAPI();
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
        if (!SharedPrefManager.getInstance(VendorInterestedWorkshopDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorInterestedWorkshopDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            workshopAdId = (String) bundle.getString("id");

            Log.e("tag", "workshop ad id is : " + workshopAdId);
        }
    }

    public void getVendorDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorInterestedWorkshopDetail.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorInterestedWorkshopDetail.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);


        }
    }

    public void initiate() {
        imagesArray = new ArrayList<>();
        quotationArray = new ArrayList<>();

        progressDialog = new ProgressDialog(VendorInterestedWorkshopDetail.this);

        workshopAdDetailsLayout = (LinearLayout) findViewById(R.id.workshopAdDetailsLayout);
        workshopAdDetailsLayout.setVisibility(GONE);



        bidType = (TextView) findViewById(R.id.bidType);
        workSector = (TextView) findViewById(R.id.workSector);
        workCity = (TextView) findViewById(R.id.workCity);
        paidStatus = (TextView) findViewById(R.id.paidStatus);
        createdAt = (TextView) findViewById(R.id.createdAt);
        workshopStatus = (TextView) findViewById(R.id.workshopStatus);
        title = (TextView) findViewById(R.id.title);
        description = (TextView) findViewById(R.id.description);
        imagesLayout = (LinearLayout) findViewById(R.id.imagesLayout);
        imagesLayout.setVisibility(GONE);
        quotationsLayout = (LinearLayout) findViewById(R.id.quotationsLayout);
        quotationsLayout.setVisibility(GONE);

        workshopAdImagesAdapter = new WorkshopAdImagesAdapter(VendorInterestedWorkshopDetail.this);

        quotationImagesRecyclerView = findViewById(R.id.quotationImagesRecyclerView);
        gridLayoutManager = new GridLayoutManager(VendorInterestedWorkshopDetail.this , 3 ,  GridLayoutManager.VERTICAL , false);
        quotationImagesRecyclerView.setLayoutManager(gridLayoutManager);
        quotationImagesRecyclerView.setAdapter(workshopAdImagesAdapter);



        quotationRecyclerView = findViewById(R.id.quotationRecyclerView);
        linearLayoutManager = new LinearLayoutManager(VendorInterestedWorkshopDetail.this ,  LinearLayoutManager.VERTICAL , false);
        quotationRecyclerView.setLayoutManager(linearLayoutManager);

        giveQuotation = (TextView) findViewById(R.id.giveQuotation);
    }

    public void clickListener(){
        giveQuotation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                quotationDialog();
            }
        });
    }

    private void workshopAdDetailsAPI() {

        RequestBody id = RequestBody.create(workshopAdId, MediaType.parse("text/plain"));


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
        call = retrofitApi.workshopAdDetails(id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {

                        workshopAdDetailsLayout.setVisibility(VISIBLE);
                        workshopAdModel = response.body().getWorkshop_details();

                        setDataToWidget();


                    } else {
                        Toast.makeText(VendorInterestedWorkshopDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorInterestedWorkshopDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorInterestedWorkshopDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }



    private void workshopGiveQuotationAPI(String priceStr, String writeSomethingStr, String selectedOption) {

        if(documentURI != null) {
            fileToUpload = ImagePartFromUri.createPartFromUri(VendorInterestedWorkshopDetail.this, documentURI, "file");
        }

        RequestBody id = RequestBody.create(workshopAdId, MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
        RequestBody price = RequestBody.create(priceStr , MediaType.parse("text/plain"));
        RequestBody description = RequestBody.create(writeSomethingStr , MediaType.parse("text/plain"));
        RequestBody option = RequestBody.create(selectedOption , MediaType.parse("text/plain"));

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
        call = retrofitApi.workshopsQuotation(vendor_id , user_type , user_id , id , price , description , fileToUpload);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {


                        if(response.body().getAction().equals("'invalid id") || response.body().getAction().equals("posted") || response.body().getAction().equals("failed")){
                            Toast.makeText(VendorInterestedWorkshopDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        }else if(response.body().getAction().equals("need subscription") || response.body().getAction().equals("subscription expired")){
                            AlertDialog alertDialog = AlertDialog(response.body().getMessage() , response.body().getAction());
                            alertDialog.show();
                        }





                    } else {
                        Toast.makeText(VendorInterestedWorkshopDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorInterestedWorkshopDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorInterestedWorkshopDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void showProgress() {
        progressDialog.setCancelable(false);
        progressDialog.show();
        progressDialog.setContentView(R.layout.progress_dialog);
        progressDialog.getWindow().setBackgroundDrawable(null);
    }

    public void hideProgress() {
        progressDialog.dismiss();
    }

    public void setDataToWidget()
    {

        bidType.setText(workshopAdModel.getBid_type());
        workSector.setText(workshopAdModel.getWork_sector());

        if(workshopAdModel.getIs_paid().equals("0")){
            paidStatus.setText("Unpaid");
        }else{
            paidStatus.setText("Paid");
        }

        if(workshopAdModel.getIs_active().equals("1")){
            workshopStatus.setText("Enabled");
            workshopStatus.setTextColor(ContextCompat.getColor(VendorInterestedWorkshopDetail.this, R.color.green));
        }else{
            workshopStatus.setText("Disabled");
            workshopStatus.setTextColor(ContextCompat.getColor(VendorInterestedWorkshopDetail.this, R.color.red));
        }

        workCity.setText(workshopAdModel.getCity_name());
        //viewCount.setText(workshopAdModel.getView_count());
        createdAt.setText(parseDateToddMMyyyy(workshopAdModel.getCreated_at()));

        title.setText(workshopAdModel.getTitle());
        description.setText(workshopAdModel.getDescription());
        imagesArray = workshopAdModel.getImages();

        Log.e("tag" , "imagesArray size is  : "+imagesArray.size());

        if(imagesArray.size() > 0)
        {
            imagesLayout.setVisibility(VISIBLE);
            workshopAdImagesAdapter.setData(imagesArray);

        }

        quotationArray = workshopAdModel.getQuotations();

        Log.e("tag" , "quotationArray size is  : "+quotationArray.size());


        if(quotationArray.size() > 0)
        {
            quotationsLayout.setVisibility(VISIBLE);
            workshopAdInterestedQuotationAdapter = new WorkshopAdInterestedQuotationAdapter(VendorInterestedWorkshopDetail.this , quotationArray , selectedLanguage , VendorInterestedWorkshopDetail.this);
            quotationRecyclerView.setAdapter(workshopAdInterestedQuotationAdapter);

        }

    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
        String outputPattern = "yyyy-dd-MM h:mm a";
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
    public void selectedQuotation(int pos, WorkshopAdModel.QuotationsModel quotationsModel) {

    }


    private AlertDialog AlertDialog(String message , String type)
    {
        AlertDialog myDialogBox = new AlertDialog.Builder(VendorInterestedWorkshopDetail.this)
                // set message, title, and icon
                .setTitle("Alert")
                .setMessage(message)
                .setPositiveButton("Update", new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int whichButton) {
                        //your deleting code
                        dialog.dismiss();
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


    public void quotationDialog()
    {
        Dialog dialog = new Dialog(VendorInterestedWorkshopDetail.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.workshop_quotation_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        EditText price = dialog.findViewById(R.id.price);
        EditText writeSomething = dialog.findViewById(R.id.writeSomething);
        RadioGroup myRadioGroup = dialog.findViewById(R.id.myRadioGroup);
        Button submitComplainBtn = dialog.findViewById(R.id.submitComplainBtn);
        Button chooseDocument = dialog.findViewById(R.id.chooseDocument);
        fileName = dialog.findViewById(R.id.fileName);
        fileName.setVisibility(GONE);

        chooseDocument.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openPdfPicker();
            }
        });

        submitComplainBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String priceStr = price.getText().toString();
                String writeSomethingStr = writeSomething.getText().toString();
                int selectedId = myRadioGroup.getCheckedRadioButtonId();

                if(priceStr.equals(""))
                {
                    Toast.makeText(VendorInterestedWorkshopDetail.this , "Please enter price", Toast.LENGTH_SHORT).show();
                }else if(selectedId == -1){
                    Toast.makeText(VendorInterestedWorkshopDetail.this, "Please select an option", Toast.LENGTH_SHORT).show();
                }
                else
                {
                    RadioButton selectedRadioButton = dialog.findViewById(selectedId);
                    String selectedOption = selectedRadioButton.getText().toString();

                    Log.e("tag" , "priceStr is : "+priceStr);
                    Log.e("tag" , "writeSomething is : "+writeSomething);
                    Log.e("tag" , "writeSomethingStr is : "+writeSomethingStr);
                    Log.e("tag" , "selectedOption is : "+selectedOption);
                    Log.e("tag" , "documentURI is : "+documentURI);

                    dialog.dismiss();
                    workshopGiveQuotationAPI(priceStr , writeSomethingStr , selectedOption);
                }
            }
        });
    }

    private void initLaunchers() {

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

        documentURI = uri;
        fileName.setText(ImagePartFromUri.getFileNameFromUri(VendorInterestedWorkshopDetail.this , uri));
        fileName.setVisibility(VISIBLE);
        Toast.makeText(this, "PDF Selected", Toast.LENGTH_SHORT).show();
    }




}