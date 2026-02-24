package com.thecontractor.VendorActivities;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.core.view.ViewCompat;
import androidx.documentfile.provider.DocumentFile;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ContentUris;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.database.Cursor;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.provider.Settings;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.QuotationImagesAdapter;
import com.thecontractor.Adapter.QuotationsCompaniesAdapter;
import com.thecontractor.Adapter.VendorStatusAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.FilePath;
import com.thecontractor.Global.ImageComprasser;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.QuotationModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorQuotationDetailModel;
import com.thecontractor.Model.VendorQuotationModel;
import com.thecontractor.Model.VendorRatingModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.UpdateProfile;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
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

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class VendorQuotationDetail extends AppCompatActivity implements VendorStatusAdapter.StatusIdInterface{

    String vendorId;
    String quotationId;
    String statusId;

    LinearLayout quotationDetailsLayout , uploadDocumentLayout;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    VendorQuotationDetailModel vendorQuotationModel;

    TextView category;
    TextView subCategory;
    TextView quotationNo;
    TextView status;
    TextView createdAt;
    TextView description;
    TextView userName;
    TextView phoneNo;
    TextView email;
    TextView uploadDocument;
    TextView fileName;

    LinearLayout  descriptionLayout , imagesLayout;

    RecyclerView quotationImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    QuotationImagesAdapter quotationImagesAdapter;
    TextView updateStatusTV;

    RecyclerView statusRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<VendorRatingModel> list;

    String selectedLanguage = "en";

    private int SELECT_FILE = 1;
    public String imagePath  = "path";
    public Uri fileUri;
    MultipartBody.Part fileToUpload;
    public static final int REQUEST_MULTIPLE_PERMISSION_CODE = 500;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_quotation_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.quotation_details);

        getLanguageFromSP();
        getDataFromSP();
        getObjectFromAdapter();
        initiate();
        clickListener();
        quotationDetailsAPI();
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
        if (!SharedPrefManager.getInstance(VendorQuotationDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorQuotationDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorQuotationDetail.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorQuotationDetail.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();


            Log.e("tag" , "Vendor id is : "+vendorId);


        }
    }

    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            quotationId = (String) bundle.getString("id");

            Log.e("tag", "quotation id is : " + quotationId);
        }
    }


    public void initiate() {
        progressDialog = new ProgressDialog(VendorQuotationDetail.this);

        quotationDetailsLayout = (LinearLayout) findViewById(R.id.quotationDetailsLayout);
        quotationDetailsLayout.setVisibility(View.GONE);

        uploadDocumentLayout = (LinearLayout) findViewById(R.id.uploadDocumentLayout);
        uploadDocumentLayout.setVisibility(View.GONE);



        category = (TextView) findViewById(R.id.category);
        subCategory = (TextView) findViewById(R.id.subCategory);
        quotationNo = (TextView) findViewById(R.id.quotationNo);
        status = (TextView) findViewById(R.id.status);
        createdAt = (TextView) findViewById(R.id.createdAt);
        description = (TextView) findViewById(R.id.description);
        uploadDocument = (TextView) findViewById(R.id.uploadDocument);
        fileName = (TextView) findViewById(R.id.fileName);
        fileName.setVisibility(View.GONE);

        userName = (TextView) findViewById(R.id.userName);
        phoneNo = (TextView) findViewById(R.id.phoneNo);
        email = (TextView) findViewById(R.id.email);

        descriptionLayout = (LinearLayout) findViewById(R.id.descriptionLayout);
        descriptionLayout.setVisibility(View.GONE);
        imagesLayout = (LinearLayout) findViewById(R.id.imagesLayout);
        imagesLayout.setVisibility(View.GONE);


        quotationImagesAdapter = new QuotationImagesAdapter(VendorQuotationDetail.this);

        quotationImagesRecyclerView = findViewById(R.id.quotationImagesRecyclerView);
        quotationImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(VendorQuotationDetail.this , 3 ,  GridLayoutManager.VERTICAL , false);
        quotationImagesRecyclerView.setLayoutManager(gridLayoutManager);
        quotationImagesRecyclerView.setAdapter(quotationImagesAdapter);

        updateStatusTV = (TextView) findViewById(R.id.updateStatusTV);
        updateStatusTV.setVisibility(View.GONE);

        list = new ArrayList<>();
        statusRV = (RecyclerView) findViewById(R.id.statusRV);
        linearLayoutManager = new LinearLayoutManager(VendorQuotationDetail.this  ,  LinearLayoutManager.HORIZONTAL , false);
        statusRV.setLayoutManager(linearLayoutManager);

    }

    public void clickListener()
    {
        uploadDocument.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if(checkPermission())
                {
                    galleryIntent();
                }
                else
                {
                    requestPermission();
                }

            }
        });
    }

    ActivityResultLauncher<Intent> profileActivityResultLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {
                        // There are no request codes
                        Intent data = result.getData();

                        fileUri = data.getData();



                        Log.e("tag" , "selected uri is : "+fileUri);

                        String[] filePathColumn = {MediaStore.Images.Media.DATA};




                        // Get the cursor
                        Cursor cursor = getContentResolver().query(fileUri, filePathColumn, null, null, null);
                        // Move to first row
                        cursor.moveToFirst();

                        int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                        imagePath = cursor.getString(columnIndex);
                        Log.e("tag" , "selected path is : "+imagePath);
                        cursor.close();

//                        imagePath = getRealPath(fileUri);
//                        Log.e("tag" , "selected path is : "+imagePath);




                        String filename = imagePath.substring(imagePath.lastIndexOf("/")+1);
                        fileName.setVisibility(View.VISIBLE);
                        fileName.setText(filename);

                        uploadDocumentAPI();

                    }
                }
            });


    ActivityResultLauncher<Intent> openFileResultLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {
                        // There are no request codes
                        Intent data = result.getData();

                        fileUri = data.getData();



                        Log.e("tag" , "selected uri is : "+fileUri);


                        //imagePath =  FilePath.getPath(VendorQuotationDetail.this , fileUri);
                        try {
                            imagePath =  getFilePath(VendorQuotationDetail.this , fileUri);
                        } catch (URISyntaxException e) {
                            e.printStackTrace();
                        }

                        Log.e("tag" , "selected path is : "+imagePath);




//                        String filename = imagePath.substring(imagePath.lastIndexOf("/")+1);
//                        fileName.setVisibility(View.VISIBLE);
//                        fileName.setText(filename);

//                        uploadDocumentAPI();

                    }
                }
            });


    @SuppressLint("NewApi")
    public String getFilePath(Context context, Uri uri) throws URISyntaxException {
        String selection = null;
        String[] selectionArgs = null;
        // Uri is different in versions after KITKAT (Android 4.4), we need to
        if (Build.VERSION.SDK_INT >= 19 && DocumentsContract.isDocumentUri(context.getApplicationContext(), uri)) {
            if (isExternalStorageDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                return Environment.getExternalStorageDirectory() + "/" + split[1];
            } else if (isDownloadsDocument(uri)) {
                final String id = DocumentsContract.getDocumentId(uri);
                uri = ContentUris.withAppendedId(Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));
            } else if (isMediaDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                Log.e("tag" , "document is : "+type);

                if ("image".equals(type)) {
                    uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                } else if("document".equals(type))
                {
                    uri = MediaStore.Files.getContentUri("external");
                }

                Log.e("tag" , "uri.getScheme() is : "+uri.getScheme());

                selection = "_id=?";
                selectionArgs = new String[]{
                        split[1]
                };
            }
        }
        if ("content".equalsIgnoreCase(uri.getScheme())) {


            if (isGooglePhotosUri(uri)) {
                return uri.getLastPathSegment();
            }

            String[] projection = {
                    MediaStore.Images.Media.DATA
            };
            Cursor cursor = null;
            try {
                cursor = context.getContentResolver()
                        .query(uri, projection, selection, selectionArgs, null);
                int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                if (cursor.moveToFirst()) {
                    return cursor.getString(column_index);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }
        return null;
    }

    public static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    public static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    public static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    public static boolean isGooglePhotosUri(Uri uri) {
        return "com.google.android.apps.photos.content".equals(uri.getAuthority());
    }





    public String getRealPath(Uri uri) {
        String docId = DocumentsContract.getDocumentId(uri);

        Log.e("tag" , "doc id is : "+docId);

        String[] split = docId.split(":");
        String type = split[0];

        Log.e("tag" , "type is : "+ type);

        Uri contentUri = null;
        switch (type) {
            case "image":
                contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                break;
            case "video":
                contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                break;
            case "audio":
                contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                break;
            case "document":
                contentUri = MediaStore.Files.getContentUri("external");
                break;

        }

        Log.e("tag" , "content uri is : "+contentUri);

        String selection = "_id=?";
        String[] selectionArgs = new String[]{split[1]};


        return getDataColumn(VendorQuotationDetail.this , contentUri, selection, selectionArgs);
    }

    public String getDataColumn(Context context, Uri uri, String selection, String[] selectionArgs) {


        Cursor cursor = null;
        String column = "_data";
        String[] projection = {column};

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
            Log.e("tag" , "in try section : "+cursor);

            if (cursor != null && cursor.moveToFirst()) {
                int column_index = cursor.getColumnIndexOrThrow(column);

                Log.e("tag" , "column index is : "+column_index);

                String value = cursor.getString(column_index);

                Log.e("tag" , "value is : "+value);

                if (value.startsWith("content://") || !value.startsWith("/") && !value.startsWith("file://")) {
                    return null;
                }
                return value;
            }
        } catch (Exception e) {
            Log.e("tag" , "in catch section");

            e.printStackTrace();
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return null;
    }


    public String getPath(Uri uri) {
        Cursor cursor = getContentResolver().query(uri, null, null, null, null);
        cursor.moveToFirst();
        String document_id = cursor.getString(0);
        document_id = document_id.substring(document_id.lastIndexOf(":") + 1);
        cursor.close();

        cursor = getContentResolver().query(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI, null, MediaStore.Images.Media._ID + " = ? ", new String[]{document_id}, null);
        cursor.moveToFirst();
        String path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
        cursor.close();

        return path;
    }


    public static String getNameFromContentUri(Context context, Uri contentUri){
        Cursor returnCursor = context.getContentResolver().query(contentUri, null, null, null, null);
        int nameColumnIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
        returnCursor.moveToFirst();
        String fileName = returnCursor.getString(nameColumnIndex);
        return fileName;}



    private void requestPermission() {

        ActivityCompat.requestPermissions(VendorQuotationDetail.this, new String[]
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

                        galleryIntent();

                    } else {

                        if (ActivityCompat.shouldShowRequestPermissionRationale(VendorQuotationDetail.this, Manifest.permission.ACCESS_FINE_LOCATION)){
                            Toast.makeText(this, "Permission denied", Toast.LENGTH_SHORT).show();

                        }
                        else {
                            showSettingsDialog();
                            //Toast.makeText(this, "Permission permatently denied", Toast.LENGTH_SHORT).show();

                        }

                    }
                }

                break;

        }
    }

    private void showSettingsDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(VendorQuotationDetail.this);
        builder.setTitle("Need Permissions");
        builder.setMessage("This app needs permission to use this feature. You can grant them in app settings.");
        builder.setPositiveButton("GO TO SETTINGS", new DialogInterface.OnClickListener() {
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
        startActivity(intent);
    }


    private void galleryIntent()
    {

        Intent i = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        profileActivityResultLauncher.launch(i);
//
//        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
//        intent.addCategory(Intent.CATEGORY_OPENABLE);
//        intent.setType("*/*");

//        Intent intent = new Intent();
//        intent.setType("application/pdf");
//        intent.setAction(Intent.ACTION_GET_CONTENT);
//        openFileResultLauncher.launch(intent);


    }


    private void uploadDocumentAPI() {



        if(!imagePath.equals("path")) {
            //creating a file
            //File file = new File(imagePath);
            File file = new ImageComprasser().compressImage(VendorQuotationDetail.this, new File(imagePath));


            //creating request body for file
            RequestBody mFile = RequestBody.create(file , MediaType.parse("*/*"));
            fileToUpload = MultipartBody.Part.createFormData("quotation_document", file.getName(), mFile);
        }

        RequestBody id = RequestBody.create(quotationId, MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId, MediaType.parse("text/plain"));

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
        call = retrofitApi.uploadDocument(id , vendor_id , fileToUpload);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                         quotationDetailsAPI();


                    }
                    else
                    {
                        Toast.makeText(VendorQuotationDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorQuotationDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorQuotationDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }





    private void quotationDetailsAPI() {

        RequestBody id = RequestBody.create(quotationId, MediaType.parse("text/plain"));


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
        call = retrofitApi.vendorParticularQuotationDetail(id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {

                        quotationDetailsLayout.setVisibility(View.VISIBLE);

                        vendorQuotationModel = response.body().getVendor_quotation();

                        Log.e("tag", "message is : " + vendorQuotationModel.getMessage());

                        setDataToWidget();


                    } else {
                        Toast.makeText(VendorQuotationDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorQuotationDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorQuotationDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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


        category.setText(vendorQuotationModel.getCate_name());
        subCategory.setText(vendorQuotationModel.getSub_cat_name());
        status.setText(vendorQuotationModel.getStatus_name());
        quotationNo.setText(vendorQuotationModel.getQuotation_number());
        createdAt.setText(parseDateToddMMyyyy(vendorQuotationModel.getCreated_at()));
        userName.setText(vendorQuotationModel.getName() + " " + vendorQuotationModel.getSurname());
        phoneNo.setText(vendorQuotationModel.getPhone());
        email.setText(vendorQuotationModel.getEmail());


        if(!vendorQuotationModel.getMessage().equals(""))
        {
            descriptionLayout.setVisibility(View.VISIBLE);
            description.setText(vendorQuotationModel.getMessage());
        }


        if(vendorQuotationModel.getImages().size() > 0)
        {
            imagesLayout.setVisibility(View.VISIBLE);
            quotationImagesAdapter.setData(vendorQuotationModel.getImages());

        }else
        {
            imagesLayout.setVisibility(View.GONE);
        }



        if(vendorQuotationModel.getStatus().size() > 0)
        {
            updateStatusTV.setVisibility(View.VISIBLE);
        }
        else
        {
            updateStatusTV.setVisibility(View.GONE);
        }

        VendorStatusAdapter vendorStatusAdapter = new VendorStatusAdapter(VendorQuotationDetail.this , vendorQuotationModel.getStatus() , selectedLanguage , VendorQuotationDetail.this);
        statusRV.setAdapter(vendorStatusAdapter);


        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(vendorQuotationModel.getColor())));
        ViewCompat.setBackground(status,shapeDrawable);

        if(vendorQuotationModel.getStatus_id().equals("2"))
        {
            uploadDocument.setText("Select Document");
            uploadDocumentLayout.setVisibility(View.VISIBLE);
        }else if(vendorQuotationModel.getStatus_id().equals("5"))
        {
            uploadDocument.setText("Resubmit Document");
            fileName.setVisibility(View.GONE);
            uploadDocumentLayout.setVisibility(View.VISIBLE);
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
    public void selectedId(String statusId) {
        this.statusId = statusId;
        updateEnquiryStatusAPI();

    }

    private void updateEnquiryStatusAPI() {

        RequestBody id = RequestBody.create(quotationId, MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId, MediaType.parse("text/plain"));
        RequestBody status_id = RequestBody.create(statusId, MediaType.parse("text/plain"));


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
        call = retrofitApi.updateQuotationStatus(id , vendor_id , status_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {

                    if (response.body().getError().equals("false")) {

                        if(response.body().getStatus().equals("reject"))
                        {
                            showDialog();
                        }else
                        {
                            quotationDetailsAPI();
                        }



                    } else {
                        Toast.makeText(VendorQuotationDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorQuotationDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorQuotationDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    public void showDialog()
    {
        Dialog dialog = new Dialog(VendorQuotationDetail.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.rejection_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        EditText reasonOfRejection = dialog.findViewById(R.id.reasonOfRejection);
        Button submitBtn = dialog.findViewById(R.id.submitBtn);

        submitBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(reasonOfRejection.getText().toString().equals(""))
                {
                    Toast.makeText(VendorQuotationDetail.this , "Enter your reason of rejection", Toast.LENGTH_SHORT).show();
                }
                else
                {
                    dialog.dismiss();
                    updateRejectStatusAPI(reasonOfRejection.getText().toString());
                }
            }
        });



    }


    private void updateRejectStatusAPI(String reason) {

        RequestBody id = RequestBody.create(quotationId, MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId, MediaType.parse("text/plain"));
        RequestBody status_id = RequestBody.create(statusId, MediaType.parse("text/plain"));
        RequestBody reason_rejection = RequestBody.create(reason, MediaType.parse("text/plain"));


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
        call = retrofitApi.updateQuotationRejectionStatus(id , vendor_id , status_id , reason_rejection);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {

                    if (response.body().getError().equals("false")) {

                        quotationDetailsAPI();

                    } else {
                        Toast.makeText(VendorQuotationDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorQuotationDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorQuotationDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

}