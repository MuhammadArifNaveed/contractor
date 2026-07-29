package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.thecontractor.Adapter.SubCategoriesAdapter;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.SubCategoriesModel;

import java.util.ArrayList;

import retrofit2.Call;

public class SubCategories extends AppCompatActivity implements SubCategoriesAdapter.SubCategoryIdInterface {
    CategoriesModel categoriesModel;

    TextView noData;
    RecyclerView subCategoriesRV;
    GridLayoutManager linearLayoutManager ;
    ArrayList<SubCategoriesModel> list;


    LinearLayout subCategoryLayout;
    String selectedLanguage = "en";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sub_categories);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.sub_categories));

        getLanguageFromSP();
        getObjectFromAdapter();
        initiate();
        setDataToAdapter();
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
        if (!SharedPrefManager.getInstance(SubCategories.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(SubCategories.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            categoriesModel = (CategoriesModel) bundle.getParcelable("categoriesModel");





        }
    }

    public void initiate() {

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        subCategoryLayout = (LinearLayout) findViewById(R.id.subCategoryLayout);
        subCategoryLayout.setVisibility(View.GONE);

        list = new ArrayList<>();
        subCategoriesRV = (RecyclerView) findViewById(R.id.subCategoriesRV);
        linearLayoutManager = new GridLayoutManager(SubCategories.this, 2 ,  LinearLayoutManager.VERTICAL, false);
        subCategoriesRV.setLayoutManager(linearLayoutManager);

    }

    public void setDataToAdapter()
    {
        list = categoriesModel.getSub_categories();

        Log.e("tag" , "sub categories list size is : "+subCategoriesRV);

        if(list.size() > 0)
        {
            subCategoryLayout.setVisibility(View.VISIBLE);
            SubCategoriesAdapter subCategoriesAdapter = new SubCategoriesAdapter(SubCategories.this , list , "true" , this , selectedLanguage);
            subCategoriesRV.setAdapter(subCategoriesAdapter);
        }
        else
        {
            noData.setVisibility(View.VISIBLE);
        }

    }

    @Override
    public void selectedSubCategoryId(String id) {

    }
}