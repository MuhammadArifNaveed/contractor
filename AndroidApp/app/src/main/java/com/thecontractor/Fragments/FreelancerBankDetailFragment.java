package com.thecontractor.Fragments;

import android.content.Intent;
import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.thecontractor.Model.AddFreelancerViewModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorAddFreelancer;

public class FreelancerBankDetailFragment extends Fragment {
    FreelancerListModel freelancerListModel;
    String from;
    String type;
    private EditText bankNameET, bankAddressET , accountNameTitleET , accountIBANET;
    private String bankNameETStr, bankAddressETStr , accountNameTitleETStr , accountIBANETStr;
    Button btnBack, btnNext;
    AddFreelancerViewModel addFreelancerViewModel;


    public FreelancerBankDetailFragment() {
        // Required empty public constructor
    }



    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view =  inflater.inflate(R.layout.fragment_freelancer_bank_detail, container, false);

        getObjectFromAdapter();
        initiate(view);
        clickListener();




        return view;
    }

    public void getObjectFromAdapter() {
        Intent intent = requireActivity().getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            from = (String) bundle.get("from");
            type = (String) bundle.get("type");

            Log.e("tag" , "from is :"+from);
            Log.e("tag" , "type is :"+type);

            assert type != null;
            if(type.equals("update")){
                freelancerListModel = (FreelancerListModel) bundle.get("freelancerListModel");
            }

        }
    }

    public void initiate(View view){
        bankNameET = view.findViewById(R.id.bankNameET);
        bankAddressET = view.findViewById(R.id.bankAddressET);
        accountNameTitleET = view.findViewById(R.id.accountNameTitleET);
        accountIBANET = view.findViewById(R.id.accountIBANET);
        btnBack = view.findViewById(R.id.btnBack);
        btnNext = view.findViewById(R.id.btnNext);

        addFreelancerViewModel = new ViewModelProvider(requireActivity()).get(AddFreelancerViewModel.class);

        assert type != null;
        if(type.equals("update")){
            setDataToWidget();
        }

    }

    public void setDataToWidget() {
        if (freelancerListModel != null) {
            bankNameET.setText(freelancerListModel.getBank_name());
            bankAddressET.setText(freelancerListModel.getBank_address());
            accountNameTitleET.setText(freelancerListModel.getAccount_title());
            accountIBANET.setText(freelancerListModel.getIban());
        }
    }

    public void clickListener(){
        btnBack.setOnClickListener(v -> ((VendorAddFreelancer) requireActivity()).previousPage());

        btnNext.setOnClickListener(v -> {

            bankNameETStr = bankNameET.getText().toString();
            bankAddressETStr = bankAddressET.getText().toString();
            accountNameTitleETStr = accountNameTitleET.getText().toString();
            accountIBANETStr = accountIBANET.getText().toString();

            if(bankNameETStr.isEmpty()){
                Toast.makeText(getActivity(), "Please enter bank name", Toast.LENGTH_SHORT).show();
            }else if(bankAddressETStr.isEmpty()){
                Toast.makeText(getActivity(), "Please enter bank address", Toast.LENGTH_SHORT).show();
            }else if(accountNameTitleETStr.isEmpty()){
                Toast.makeText(getActivity(), "Please enter account name / title", Toast.LENGTH_SHORT).show();
            }else if(accountIBANETStr.isEmpty()){
                Toast.makeText(getActivity(), "Please enter account IBAN ", Toast.LENGTH_SHORT).show();
            }else {

                Log.e("tag" , "bankNameETStr is : "+bankNameETStr);
                Log.e("tag" , "bankAddressETStr is : "+bankAddressETStr);
                Log.e("tag" , "accountNameTitleETStr is : "+accountNameTitleETStr);
                Log.e("tag" , "accountIBANETStr is : "+accountNameTitleETStr);

                addFreelancerViewModel.setBankName(bankNameETStr);
                addFreelancerViewModel.setBankAddress(bankAddressETStr);
                addFreelancerViewModel.setAccountName(accountNameTitleETStr);
                addFreelancerViewModel.setAccountIBAN(accountNameTitleETStr);


                ((VendorAddFreelancer) requireActivity()).nextPage();

            }



        });
    }


}