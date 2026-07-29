package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.CompaniesAdapter;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.BadgeDrawable;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CompaniesModel;
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

public class CompanyFinder extends AppCompatActivity {
    String keyword;
    TextView noData;

    RecyclerView searchCompaniesRV;
    LinearLayoutManager linearLayoutManagerSimple ;
    ArrayList<CompaniesModel> list;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    CompaniesAdapter companiesAdapter;

    private LayerDrawable mCartMenuIcon;
    private MenuItem action_cart;
    private int cartCount = 0;
    private DatabaseHandler databaseHandler;
    String selectedLanguage = "en";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_company_finder);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.search_result));

        getDataFromPreviousActivity();
        getLanguageFromSP();
        initiate();
        companiesAPI();
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


    public void getDataFromPreviousActivity()
    {
        Intent intent = getIntent();
        keyword = intent.getStringExtra("keyword");

        Log.e("tag" , "keyword is : "+keyword);
    }


    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(CompanyFinder.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(CompanyFinder.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void initiate()
    {

        databaseHandler = new DatabaseHandler(CompanyFinder.this);

        progressDialog = new ProgressDialog(CompanyFinder.this);

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        list = new ArrayList<>();
        searchCompaniesRV = (RecyclerView) findViewById(R.id.searchCompaniesRV);
        linearLayoutManagerSimple = new LinearLayoutManager(CompanyFinder.this ,  LinearLayoutManager.VERTICAL , false);
        searchCompaniesRV.setLayoutManager(linearLayoutManagerSimple);
    }

    private void companiesAPI() {

        RequestBody key = RequestBody.create(keyword , MediaType.parse("text/plain"));

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
        call = retrofitApi.search(key);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        list = response.body().getCompanies();

                        Log.e("tag" , "simple companies list size is : "+list.size());

                        if(list.size() > 0)
                        {
                            companiesAdapter = new CompaniesAdapter(CompanyFinder.this , list , selectedLanguage);
                            searchCompaniesRV.setAdapter(companiesAdapter);
                        }

                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(CompanyFinder.this, getResources().getText(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(CompanyFinder.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);

        mCartMenuIcon = (LayerDrawable) menu.findItem(R.id.action_cart).getIcon();
        action_cart = (MenuItem) menu.findItem(R.id.action_cart);
        MenuItem action_search = (MenuItem) menu.findItem(R.id.action_search);
        MenuItem action_twenty_four_seven = (MenuItem) menu.findItem(R.id.action_twenty_four_seven);

        action_search.setVisible(false);
        action_twenty_four_seven.setVisible(false);

        action_cart.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {


                dbCount();

                if (cartCount == 0) {
                    Toast.makeText(CompanyFinder.this, getResources().getString(R.string.cart_empty), Toast.LENGTH_SHORT).show();
                } else {
                    Intent i = new Intent(CompanyFinder.this, Cart.class);
                    startActivity(i);
                }


                return false;
            }
        });


        dbCount();
        setBadgeCount(CompanyFinder.this, mCartMenuIcon, String.valueOf(cartCount));
        return super.onCreateOptionsMenu(menu);


    }

    public static void setBadgeCount(Context context, LayerDrawable icon, String count) {

        Log.e("tag", "count in badge" + count);

        BadgeDrawable badge;

        // Reuse drawable if possible
        Drawable reuse = icon.findDrawableByLayerId(R.id.ic_badge);
        if (reuse != null && reuse instanceof BadgeDrawable) {
            badge = (BadgeDrawable) reuse;
        } else {
            badge = new BadgeDrawable(context);
        }

        badge.setCount(count);
        icon.mutate();
        icon.setDrawableByLayerId(R.id.ic_badge, badge);
    }

    private BroadcastReceiver updateValue = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            String type = intent.getStringExtra("type");

            if (type.contentEquals("update_value")) {
                dbCount();
                setBadgeCount(CompanyFinder.this, mCartMenuIcon, String.valueOf(cartCount));
            }
        }
    };

    public void dbCount() {
        cartCount = databaseHandler.getCartCount();

        Log.e("tag", "cart count is : " + cartCount);
    }


    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(updateValue , new IntentFilter("update"));
        dbCount();
        invalidateOptionsMenu();

        if(companiesAdapter != null)
        {
            companiesAdapter.notifyDataSetChanged();
        }

    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(updateValue);

    }
}