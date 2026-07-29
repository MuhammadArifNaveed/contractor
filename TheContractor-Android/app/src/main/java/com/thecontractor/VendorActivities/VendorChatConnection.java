package com.thecontractor.VendorActivities;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.database.annotations.Nullable;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.gson.Gson;
import com.thecontractor.Adapter.VendorChatConnectionAdapter;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.ChatConnectionModel;
import com.thecontractor.Model.ChatModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;

import java.util.ArrayList;
import java.util.Collections;

public class VendorChatConnection extends AppCompatActivity {
    String selectedLanguage = "en";
    String vendorId;
    String vendorName;
    String vendorUUID;
    ProgressDialog progressDialog;
    FirebaseFirestore db;
    TextView noData;
    RecyclerView chatConnectionRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<ChatConnectionModel> list;
    VendorChatConnectionAdapter vendorChatConnectionAdapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_chat_connection);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Inbox");

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        getConnections();
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
        if (!SharedPrefManager.getInstance(VendorChatConnection.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorChatConnection.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorChatConnection.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorChatConnection.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            vendorName = vendorModel.getCompany_name();
            vendorUUID = vendorModel.getUuid();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "Vendor name is : "+vendorName);
            Log.e("tag" , "Vendor uuid is : "+vendorUUID);



        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorChatConnection.this);
        db = FirebaseFirestore.getInstance();
        list = new ArrayList<>();

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        chatConnectionRV = (RecyclerView) findViewById(R.id.chatConnectionRV);
        linearLayoutManager = new LinearLayoutManager(VendorChatConnection.this  , LinearLayoutManager.VERTICAL , false);
        chatConnectionRV.setLayoutManager(linearLayoutManager);
        vendorChatConnectionAdapter = new VendorChatConnectionAdapter(VendorChatConnection.this , list , selectedLanguage);
        chatConnectionRV.setAdapter(vendorChatConnectionAdapter);

    }

    public void getConnections()
    {
        showProgress();
        db.collection("user_connections")
                .whereEqualTo("company_uuid", vendorUUID)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots, @Nullable FirebaseFirestoreException e) {
                        hideProgress();
                        if (e != null) {
                            Log.e("tag", "listen:error", e);
                            return;
                        }
                        for (DocumentChange dc : snapshots.getDocumentChanges()) {
                            if (dc.getType() == DocumentChange.Type.ADDED) {
                                ChatConnectionModel chatConnectionModel = new ChatConnectionModel();
                                chatConnectionModel.setCompany_id(dc.getDocument().getString("company_id"));
                                chatConnectionModel.setCompany_uuid(dc.getDocument().getString("company_uuid"));
                                chatConnectionModel.setCompany_serial_no(dc.getDocument().getString("company_serial_no"));
                                chatConnectionModel.setCompany_name(dc.getDocument().getString("company_name"));
                                chatConnectionModel.setCompany_is_active(dc.getDocument().getString("company_is_active"));
                                chatConnectionModel.setUser_id(dc.getDocument().getString("user_id"));
                                chatConnectionModel.setUser_uuid(dc.getDocument().getString("user_uuid"));
                                chatConnectionModel.setUser_name(dc.getDocument().getString("user_name"));
                                chatConnectionModel.setFull_name(dc.getDocument().getString("full_name"));
                                chatConnectionModel.setUser_is_active(dc.getDocument().getString("user_is_active"));
                                chatConnectionModel.setIs_active(dc.getDocument().getString("is_active"));
                                chatConnectionModel.setChat_uuid(dc.getDocument().getString("chat_uuid"));
                                chatConnectionModel.setCreated_at(dc.getDocument().getString("created_at"));
                                chatConnectionModel.setLast_message(dc.getDocument().getString("last_message"));
                                chatConnectionModel.setMessage_time(dc.getDocument().getString("message_time"));
                                list.add(chatConnectionModel);
                            }else if(dc.getType() == DocumentChange.Type.MODIFIED)
                            {
                                for(int i = 0 ; i < list.size() ; i ++)
                                {
                                    String userUUID = dc.getDocument().getString("user_uuid");
                                    String companyUUID = dc.getDocument().getString("company_uuid");

                                    if(list.get(i).getCompany_uuid().equals(companyUUID) && list.get(i).getUser_uuid().equals(userUUID))
                                    {
                                        Log.e("tag" , "user uuid is : "+dc.getDocument().getString("user_uuid"));

                                        list.get(i).setLast_message(dc.getDocument().getString("last_message"));
                                        list.get(i).setMessage_time(dc.getDocument().getString("message_time"));
                                        break;
                                    }

                                }
                            }
                        }
                        Log.e("tag" , "list size is  :"+list.size());

                        if(list.size() > 0)
                        {
                            noData.setVisibility(View.GONE);
                            Collections.sort(list, (o1, o2) -> o2.getMessage_time().compareTo(o1.getMessage_time()));
                            vendorChatConnectionAdapter.notifyDataSetChanged();
                            chatConnectionRV.smoothScrollToPosition(0);
                        }else
                        {
                            noData.setVisibility(View.VISIBLE);
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