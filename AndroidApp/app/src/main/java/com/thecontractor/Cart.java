package com.thecontractor;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.widget.NestedScrollView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.SelectedCompaniesAdapter;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.SelectedCompaniesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class Cart extends AppCompatActivity implements  SelectedCompaniesAdapter.GoogleMapInterface{

    String userId = "";
    RecyclerView selectedCompaniesRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<SelectedCompaniesModel> selectedCompaniesList;
    private DatabaseHandler databaseHandler;

    LinearLayout goToAddContactInfoLayout;
    NestedScrollView cartLayout;
    TextView totalCompanies;
    TextView noData;
    TextView cartLimitIssue;
    String selectedLanguage = "en";
    EditText googleMapEditText;
    TextView googleMapLat;
    TextView googleMapLng;
    SelectedCompaniesAdapter selectedCompaniesAdapter;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    int cartLimit;
    int availableCartLimit;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cart);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.selected_companies));

        getDataFromSP();
        getLanguageFromSP();
        initiate();
        checkCartLimit();


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


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(Cart.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(Cart.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);
            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(Cart.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(Cart.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void initiate() {

        progressDialog = new ProgressDialog(Cart.this);

        databaseHandler = new DatabaseHandler(Cart.this);

        selectedCompaniesList = new ArrayList<>();
        selectedCompaniesRV = (RecyclerView) findViewById(R.id.selectedCompaniesRV);
        linearLayoutManager = new LinearLayoutManager(Cart.this  ,  LinearLayoutManager.VERTICAL , false);
        selectedCompaniesRV.setLayoutManager(linearLayoutManager);

        goToAddContactInfoLayout = (LinearLayout) findViewById(R.id.goToAddContactInfoLayout);
        goToAddContactInfoLayout.setVisibility(View.GONE);
        cartLayout = (NestedScrollView) findViewById(R.id.cartLayout);
        cartLayout.setVisibility(View.GONE);
        totalCompanies = (TextView) findViewById(R.id.totalCompanies);
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);
        cartLimitIssue = (TextView) findViewById(R.id.cartLimitIssue);
        cartLimitIssue.setVisibility(View.GONE);

    }

    public void getSelectedCompaniesFromDatabase()
    {
        selectedCompaniesList = databaseHandler.getAllSelectedCompaniesFromDB();

        Log.e("tag" , "selected companies list is : "+selectedCompaniesList.size());
    }

    public void setDataToAdapter()
    {
        if(selectedCompaniesList.size() > 0)
        {
            cartLayout.setVisibility(View.VISIBLE);

            selectedCompaniesAdapter = new SelectedCompaniesAdapter(Cart.this , selectedCompaniesList , goToAddContactInfoLayout , selectedLanguage , cartResultLauncher , Cart.this);
            selectedCompaniesRV.setAdapter(selectedCompaniesAdapter);
        }
        else
        {
            cartLayout.setVisibility(View.GONE);
            noData.setVisibility(View.VISIBLE);
        }


    }

    ActivityResultLauncher<Intent> cartResultLauncher = registerForActivityResult(
    new ActivityResultContracts.StartActivityForResult(),
    new ActivityResultCallback<ActivityResult>() {
        @Override
        public void onActivityResult(ActivityResult result) {
            if (result.getResultCode() == Activity.RESULT_OK) {
                // There are no request codes
                Intent data = result.getData();

                double lat = data.getDoubleExtra("lat"  , 0.0);
                double  lng = data.getDoubleExtra("lng" , 0.0);

                Log.e("tag" , "lat lng in onActivityResult : "+ lat  +"  "+ lng);

                if(selectedCompaniesAdapter != null)
                {
                    selectedCompaniesAdapter.setLocationData(googleMapEditText ,  googleMapLat , googleMapLng , lat , lng);
                }

            }
        }
    });




    private BroadcastReceiver updateValue = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            String type = intent.getStringExtra("type");

            if (type.contentEquals("update_value")) {
               showHideGoAddContactInfoLayout();
            }
        }
    };

    private void showHideGoAddContactInfoLayout() {

        totalCompanies.setText(String.valueOf(databaseHandler.getCartCount() + " " + getResources().getString(R.string.selected_companies)));

        if(databaseHandler.getCartCount() == 0)
        {
            goToAddContactInfoLayout.setVisibility(View.GONE);
            cartLayout.setVisibility(View.GONE);
            cartLimitIssue.setVisibility(View.GONE);
            noData.setVisibility(View.VISIBLE);

        }
        else {
            if (databaseHandler.getCartCount() > availableCartLimit) {
                cartLimitIssue.setText(getString(R.string.remove) + (databaseHandler.getCartCount() - availableCartLimit) + getString(R.string.company_from_your_list));
                cartLimitIssue.setVisibility(View.VISIBLE);
                goToAddContactInfoLayout.setVisibility(View.GONE);

            } else
            {
                cartLimitIssue.setVisibility(View.GONE);
                goToAddContactInfoLayout.setVisibility(View.VISIBLE);
            }
        }

    }

    @Override
    protected void onResume() {
        super.onResume();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(updateValue, new IntentFilter("update") , RECEIVER_NOT_EXPORTED);
        }else {
            registerReceiver(updateValue, new IntentFilter("update"));
        }


    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(updateValue);

    }

    @Override
    public void selectedView(EditText editText, TextView googleLocationLat, TextView googleLocationLng) {
        googleMapEditText = editText;
        googleMapLat = googleLocationLat;
        googleMapLng = googleLocationLng;

        Intent intent = new Intent(Cart.this , MapsActivity.class);
        cartResultLauncher.launch(intent);
    }



    private void checkCartLimit() {


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
        call = retrofitApi.checkCartLimit(user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        SharedPrefManager.getInstance(Cart.this).cartLimit(response.body().getCart_limit() , response.body().getAvailable_cart_limit());
                        cartLimit = response.body().getCart_limit();
                        availableCartLimit = response.body().getAvailable_cart_limit();

                        Log.e("tag" , "cart available limit is : "+availableCartLimit);

                        getSelectedCompaniesFromDatabase();
                        setDataToAdapter();
                        showHideGoAddContactInfoLayout();

                    }
                    else
                    {
                        Toast.makeText(Cart.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(Cart.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(Cart.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

}