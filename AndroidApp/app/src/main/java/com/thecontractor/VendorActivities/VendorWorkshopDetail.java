package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.Manifest;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorStatusAdapter;
import com.thecontractor.Adapter.WorkshopAdImagesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.WorkshopAdImagesModel;
import com.thecontractor.Model.WorkshopAdModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.WorkshopAdDetail;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import static android.Manifest.permission.CALL_PHONE;

public class VendorWorkshopDetail extends AppCompatActivity {
    String workshopAdId;

    LinearLayout workshopAdDetailsLayout;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    WorkshopAdModel workshopAdModel;

    TextView category;
    TextView subCategory;
    TextView quotationNo;
    TextView status;
    TextView createdAt;
    TextView title;
    TextView description;
    TextView adminNote;
    TextView userName;
    TextView phoneNo;
    TextView address;

    LinearLayout adminNoteLayout , descriptionLayout , imagesLayout , phoneNoLayout , addressLayout;
    TextView callLayout , whatsAppLayout , chatLayout;

    RecyclerView quotationImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    WorkshopAdImagesAdapter workshopAdImagesAdapter;

    private static final int PERMISSIONS_REQUEST = 10;

    String selectedLanguage = "en";
    ArrayList<WorkshopAdImagesModel> imagesArray;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_workshop_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.workshop_ad_detail);

        getLanguageFromSP();
        getObjectFromAdapter();
        initiate();
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
        if (!SharedPrefManager.getInstance(VendorWorkshopDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorWorkshopDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            workshopAdId = (String) bundle.getString("id");

            Log.e("tag", "worshop ad id is : " + workshopAdId);
        }
    }



    public void initiate() {
        imagesArray = new ArrayList<>();
        progressDialog = new ProgressDialog(VendorWorkshopDetail.this);

        workshopAdDetailsLayout = (LinearLayout) findViewById(R.id.workshopAdDetailsLayout);
        workshopAdDetailsLayout.setVisibility(View.GONE);



        category = (TextView) findViewById(R.id.category);
        subCategory = (TextView) findViewById(R.id.subCategory);
        quotationNo = (TextView) findViewById(R.id.quotationNo);
        status = (TextView) findViewById(R.id.status);
        createdAt = (TextView) findViewById(R.id.createdAt);
        title = (TextView) findViewById(R.id.title);
        description = (TextView) findViewById(R.id.description);
        adminNote = (TextView) findViewById(R.id.adminNote);

        userName = (TextView) findViewById(R.id.userName);
        phoneNo = (TextView) findViewById(R.id.phoneNo);
        address = (TextView) findViewById(R.id.address);

        adminNoteLayout = (LinearLayout) findViewById(R.id.adminNoteLayout);
        adminNoteLayout.setVisibility(View.GONE);
        descriptionLayout = (LinearLayout) findViewById(R.id.descriptionLayout);
        descriptionLayout.setVisibility(View.GONE);
        imagesLayout = (LinearLayout) findViewById(R.id.imagesLayout);
        imagesLayout.setVisibility(View.GONE);
        phoneNoLayout = (LinearLayout) findViewById(R.id.phoneNoLayout);
        phoneNoLayout.setVisibility(View.GONE);
        addressLayout = (LinearLayout) findViewById(R.id.addressLayout);
        addressLayout.setVisibility(View.GONE);
        callLayout = (TextView) findViewById(R.id.callLayout);
        callLayout.setVisibility(View.GONE);
        whatsAppLayout = (TextView) findViewById(R.id.whatsAppLayout);
        whatsAppLayout.setVisibility(View.GONE);
        chatLayout = (TextView) findViewById(R.id.chatLayout);
        chatLayout.setVisibility(View.GONE);


        workshopAdImagesAdapter = new WorkshopAdImagesAdapter(VendorWorkshopDetail.this);

        quotationImagesRecyclerView = findViewById(R.id.quotationImagesRecyclerView);
        quotationImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(VendorWorkshopDetail.this , 3 ,  GridLayoutManager.VERTICAL , false);
        quotationImagesRecyclerView.setLayoutManager(gridLayoutManager);
        quotationImagesRecyclerView.setAdapter(workshopAdImagesAdapter);


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
        call = retrofitApi.vendorWorkshopAdDetail(id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {

                        workshopAdDetailsLayout.setVisibility(View.VISIBLE);
                        workshopAdModel = response.body().getVendor_workshop_ad_detail();


                        setDataToWidget();


                    } else {
                        Toast.makeText(VendorWorkshopDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorWorkshopDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorWorkshopDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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
        if(selectedLanguage.equals("en"))
        {
            category.setText(workshopAdModel.getCategory_name());
            subCategory.setText(workshopAdModel.getSub_category_name());
            status.setText(workshopAdModel.getStatus_name());

        }else
        {
            category.setText(workshopAdModel.getCategory_arabic_name());
            subCategory.setText(workshopAdModel.getArabic_sub_category_name());
            status.setText(workshopAdModel.getArabic_status_name());
        }


        quotationNo.setText(workshopAdModel.getAd_id());
        createdAt.setText(parseDateToddMMyyyy(workshopAdModel.getCreated_at()));
        userName.setText(workshopAdModel.getName() + " " + workshopAdModel.getSurname());

        title.setText(workshopAdModel.getTitle());



        if(!workshopAdModel.getPhone().equals(""))
        {
            phoneNoLayout.setVisibility(View.VISIBLE);
            phoneNo.setText(workshopAdModel.getPhone());
        }

        if(!workshopAdModel.getAddress().equals(""))
        {
            addressLayout.setVisibility(View.VISIBLE);
            address.setText(workshopAdModel.getAddress());
        }

        if(!workshopAdModel.getDescription().equals(""))
        {
            descriptionLayout.setVisibility(View.VISIBLE);
            description.setText(workshopAdModel.getDescription());
        }

        if(!workshopAdModel.getReason().equals(""))
        {
            adminNoteLayout.setVisibility(View.VISIBLE);
            adminNote.setText(workshopAdModel.getReason());
        }

        if(!workshopAdModel.getImage_path().equals(""))
        {
            imagesArray.add(new WorkshopAdImagesModel("0" , workshopAdId , workshopAdModel.getImage_path() , "1"));
        }



        if(imagesArray.size() > 0)
        {
            if(workshopAdModel.getImages().size() > 0)
            {
                imagesArray.addAll(workshopAdModel.getImages());
            }
            imagesLayout.setVisibility(View.VISIBLE);
            workshopAdImagesAdapter.setData(imagesArray);

        }else
        {
            imagesLayout.setVisibility(View.GONE);
        }


        if(workshopAdModel.getShow_call().equals("1"))
        {
            callLayout.setVisibility(View.VISIBLE);

            callLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    if (checkPermission()) {
                        Intent intent = new Intent(Intent.ACTION_CALL);
                        intent.setData(Uri.parse("tel:"+workshopAdModel.getPhone()));
                        startActivity(intent);
                    } else {
                        requestPermission();
                    }

                }
            });
        }

        if(workshopAdModel.getShow_whatsapp().equals("1"))
        {
            whatsAppLayout.setVisibility(View.VISIBLE);

            whatsAppLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    String url = "https://api.whatsapp.com/send?phone=" + workshopAdModel.getPhone();
                    Intent i = new Intent(Intent.ACTION_VIEW);
                    i.setData(Uri.parse(url));
                    startActivity(i);


                }
            });
        }

        if(workshopAdModel.getShow_chat().equals("1"))
        {
            chatLayout.setVisibility(View.VISIBLE);

            chatLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent(VendorWorkshopDetail.this , VendorChat.class);
                    intent.putExtra("userId" , workshopAdModel.getUser_id());
                    intent.putExtra("userName" , workshopAdModel.getUsername());
                    intent.putExtra("fullName" , workshopAdModel.getName() + " " +workshopAdModel.getSurname());
                    intent.putExtra("userUUID" , workshopAdModel.getUser_uuid());
                    startActivity(intent);

                }
            });
        }


        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(workshopAdModel.getStatus_color())));
        ViewCompat.setBackground(status,shapeDrawable);
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


    private void requestPermission() {

        ActivityCompat.requestPermissions(VendorWorkshopDetail.this, new String[]
                {
                        CALL_PHONE
                }, PERMISSIONS_REQUEST);

    }

    public boolean checkPermission() {

        int LocationPermissionResult = ContextCompat.checkSelfPermission(getApplicationContext(), CALL_PHONE);
        Log.e("tag", "in checkPermission");

        return LocationPermissionResult == PackageManager.PERMISSION_GRANTED;
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        switch (requestCode) {

            case PERMISSIONS_REQUEST:

                if (grantResults.length > 0) {

                    boolean LocationPermissionResult = grantResults[0] == PackageManager.PERMISSION_GRANTED;

                    if (LocationPermissionResult) {

                        Log.e("tag", "permission granted");
                    } else {

                        if (ActivityCompat.shouldShowRequestPermissionRationale(VendorWorkshopDetail.this, CALL_PHONE)) {
                            Toast.makeText(this, "Permission denied", Toast.LENGTH_SHORT).show();

                        } else {
                            showSettingsDialog();
                            //Toast.makeText(this, "Permission permatently denied", Toast.LENGTH_SHORT).show();

                        }

                    }
                }

                break;

        }
    }


    private void showSettingsDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(VendorWorkshopDetail.this);
        builder.setTitle("Need Permissions");
        builder.setMessage("This app needs permission to use this feature. You can grant them in app settings.");
        builder.setPositiveButton("GOTO SETTINGS", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                openSettings();
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });
        builder.show();

    }

    private void openSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", getPackageName(), null);
        intent.setData(uri);
        startActivityForResult(intent, 101);
    }

}