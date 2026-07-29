package com.thecontractor.Fragments;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.thecontractor.Adapter.CompanyDetailSubCategoriesAdapter;
import com.thecontractor.Adapter.OpeningHoursAdapter;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.OpeningHoursModel;
import com.thecontractor.R;

import java.util.ArrayList;


public class OpeningHoursFragment extends Fragment {

    TextView noData;
    LinearLayout openingHoursLayout;
    RecyclerView openingHoursRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<OpeningHoursModel> list;
    String selectedLanguage = "en";



    public OpeningHoursFragment(ArrayList<OpeningHoursModel> list) {
        this.list = list;
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_opening_hours, container, false);

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
        noData = (TextView) view.findViewById(R.id.noData);
        noData.setVisibility(View.GONE);
        openingHoursLayout = (LinearLayout) view.findViewById(R.id.openingHoursLayout);
        openingHoursLayout.setVisibility(View.GONE);

        openingHoursRV = (RecyclerView) view.findViewById(R.id.openingHoursRV);
        linearLayoutManager = new LinearLayoutManager(getActivity()  , LinearLayoutManager.VERTICAL , false);
        openingHoursRV.setLayoutManager(linearLayoutManager);
    }

    public void setDateToWidget()
    {
        if(list.size() > 0)
        {
            openingHoursLayout.setVisibility(View.VISIBLE);
            OpeningHoursAdapter openingHoursAdapter = new OpeningHoursAdapter(getActivity() , list , selectedLanguage);
            openingHoursRV.setAdapter(openingHoursAdapter);

        }
        else
        {
            noData.setVisibility(View.VISIBLE);
        }

    }
}