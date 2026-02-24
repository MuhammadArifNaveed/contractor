package com.thecontractor;

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
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.gson.Gson;
import com.thecontractor.Adapter.ChatConnectionAdapter;
import com.thecontractor.Adapter.VendorChatConnectionAdapter;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.ChatConnectionModel;
import com.thecontractor.Model.UserModel;

import java.util.ArrayList;
import java.util.Collections;

public class ChatConnection extends AppCompatActivity {
    String selectedLanguage = "en";
    String userId;
    String userName;
    String userUUID;
    ProgressDialog progressDialog;
    FirebaseFirestore db;
    TextView noData;
    RecyclerView chatConnectionRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<ChatConnectionModel> list;
    ChatConnectionAdapter chatConnectionAdapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_connection);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.inbox));

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        getConnections();
        //createFirebaseDate();
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
        if (!SharedPrefManager.getInstance(ChatConnection.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(ChatConnection.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(ChatConnection.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(ChatConnection.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();
            userName = userModel.getName() + " " + userModel.getSurname();
            userUUID = userModel.getUuid();

            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user name is : "+userName);
            Log.e("tag" , "user uuid is : "+userUUID);


        }
    }



    public void initiate()
    {
        progressDialog = new ProgressDialog(ChatConnection.this);
        db = FirebaseFirestore.getInstance();
        list = new ArrayList<>();

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        chatConnectionRV = (RecyclerView) findViewById(R.id.chatConnectionRV);
        linearLayoutManager = new LinearLayoutManager(ChatConnection.this  , LinearLayoutManager.VERTICAL , false);
        chatConnectionRV.setLayoutManager(linearLayoutManager);
        chatConnectionAdapter = new ChatConnectionAdapter(ChatConnection.this , list , selectedLanguage);
        chatConnectionRV.setAdapter(chatConnectionAdapter);

    }

    public void getConnections()
    {
        showProgress();
        db.collection("user_connections")
                .whereEqualTo("user_uuid", userUUID)
                //.orderBy("message_time", Query.Direction.DESCENDING)
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
                            chatConnectionAdapter.notifyDataSetChanged();
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