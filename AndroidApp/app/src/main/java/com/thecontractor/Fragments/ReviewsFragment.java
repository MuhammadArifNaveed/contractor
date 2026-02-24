package com.thecontractor.Fragments;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.thecontractor.Adapter.OpeningHoursAdapter;
import com.thecontractor.Adapter.ReviewsAdapter;
import com.thecontractor.Model.OpeningHoursModel;
import com.thecontractor.Model.ReviewsModel;
import com.thecontractor.R;

import java.util.ArrayList;

public class ReviewsFragment extends Fragment {

    TextView noData;
    LinearLayout reviewLayout;
    RecyclerView reviewsRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<ReviewsModel> list;

    public ReviewsFragment(ArrayList<ReviewsModel> list) {
        // Required empty public constructor
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
        View view = inflater.inflate(R.layout.fragment_reviews, container, false);

        initiate(view);
        setDateToWidget();

        return view;
    }

    public void initiate(View view)
    {
         noData = (TextView) view.findViewById(R.id.noData);
         noData.setVisibility(View.GONE);
        reviewLayout =(LinearLayout) view.findViewById(R.id.reviewLayout);
        reviewLayout.setVisibility(View.GONE);

        reviewsRV = (RecyclerView) view.findViewById(R.id.reviewsRV);
        linearLayoutManager = new LinearLayoutManager(getActivity()  , LinearLayoutManager.VERTICAL , false);
        reviewsRV.setLayoutManager(linearLayoutManager);
    }

    public void setDateToWidget()
    {

        if(list.size() > 0)
        {
            reviewLayout.setVisibility(View.VISIBLE);
            ReviewsAdapter reviewsAdapter = new ReviewsAdapter(getActivity() , list);
            reviewsRV.setAdapter(reviewsAdapter);
        }
        else
        {
            noData.setVisibility(View.VISIBLE);
        }



    }
}