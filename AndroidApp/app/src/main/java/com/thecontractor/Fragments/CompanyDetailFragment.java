package com.thecontractor.Fragments;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.thecontractor.Adapter.CompanyDetailSubCategoriesAdapter;
import com.thecontractor.CompanyDetails;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.CompanyDetailSubCategoriesModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.R;

import java.util.ArrayList;


public class CompanyDetailFragment extends Fragment {
    String companyDescription;
    String companyAddress;
    String cityName;
    String areaName;
    String since;
    String noOfEmployees;

    LinearLayout descriptionLayout , addressLayout , cityLayout , areaLayout , sinceLayout , noOfEmployeesLayout;
    TextView companyDescriptionTV , companyAddressTV , companyCityTV , companyAreaTV , companySinceTV , companyNoOfEmployeesTV;

    RecyclerView subCategoriesRV;
    GridLayoutManager gridLayoutManager ;
    ArrayList<CompanyDetailSubCategoriesModel> list;
    String selectedLanguage = "en";


    public CompanyDetailFragment(String companyDescription, String companyAddress, String cityName, String areaName , ArrayList<CompanyDetailSubCategoriesModel> list , String since , String noOfEmployees) {
        this.companyDescription = companyDescription;
        this.companyAddress = companyAddress;
        this.cityName = cityName;
        this.areaName = areaName;
        this.list = list;
        this.since = since;
        this.noOfEmployees = noOfEmployees;
    }




    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_company_detail, container, false);

        getLanguageFromSP();
        initiate(view);
        setDateToWidget();

        return view;
    }


    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(getActivity()).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void initiate(View view)
    {
        descriptionLayout = (LinearLayout) view.findViewById(R.id.descriptionLayout);
        addressLayout = (LinearLayout) view.findViewById(R.id.addressLayout);
        cityLayout = (LinearLayout) view.findViewById(R.id.cityLayout);
        areaLayout = (LinearLayout) view.findViewById(R.id.areaLayout);
        sinceLayout = (LinearLayout) view.findViewById(R.id.sinceLayout);
        noOfEmployeesLayout = (LinearLayout) view.findViewById(R.id.noOfEmployeesLayout);

        companyDescriptionTV = (TextView) view.findViewById(R.id.companyDescriptionTV);
        companyAddressTV = (TextView) view.findViewById(R.id.companyAddressTV);
        companyCityTV = (TextView) view.findViewById(R.id.companyCityTV);
        companyAreaTV = (TextView) view.findViewById(R.id.companyAreaTV);
        companySinceTV = (TextView) view.findViewById(R.id.companySinceTV);
        companyNoOfEmployeesTV = (TextView) view.findViewById(R.id.companyNoOfEmployeesTV);

        subCategoriesRV = (RecyclerView) view.findViewById(R.id.subCategoriesRV);
        gridLayoutManager = new GridLayoutManager(getActivity() , 2 , LinearLayoutManager.VERTICAL , false);
        subCategoriesRV.setLayoutManager(gridLayoutManager);
    }

    public void setDateToWidget()
    {
        if(!companyDescription.equals(""))
        {
            companyDescriptionTV.setText(companyDescription);
        }else
        {
            descriptionLayout.setVisibility(View.GONE);
        }

        if(!companyAddress.equals(""))
        {
            companyAddressTV.setText(companyAddress);
        }else
        {
            addressLayout.setVisibility(View.GONE);
        }

        companyCityTV.setText(cityName);
        companyAreaTV.setText(areaName);
        companySinceTV.setText(since);
        companyNoOfEmployeesTV.setText(noOfEmployees);

        CompanyDetailSubCategoriesAdapter companyDetailSubCategoriesAdapter = new CompanyDetailSubCategoriesAdapter(getActivity() , list , selectedLanguage);
        subCategoriesRV.setAdapter(companyDetailSubCategoriesAdapter);

    }
}