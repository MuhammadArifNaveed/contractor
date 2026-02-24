package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import com.thecontractor.Global.LocaleHelper;
import com.thecontractor.Global.SharedPrefManager;

import java.util.Locale;

public class SelectLanguage extends AppCompatActivity {
    RadioGroup languagesRadioGroup;
    RadioButton englishRadioButton;
    RadioButton arabicRadioButton;
    RadioButton urduRadioButton;
    String selectedLanguage = "en";
    Button nextBtn;
    String from;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_language);
        getSupportActionBar().setTitle(getResources().getString(R.string.select_language));

        getLanguageFromSP();
        getDataFromPreviousActivity();
        initiate();
        clickListener();

    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(SelectLanguage.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(SelectLanguage.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void getDataFromPreviousActivity()
    {
        Intent intent = getIntent();
        from = intent.getStringExtra("from");

        Log.e("tag" , "from is : "+from);

        if(from.equals("profileFragment"))
        {
            getSupportActionBar().setHomeButtonEnabled(true);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        switch (menuItem.getItemId()) {
            case android.R.id.home:
                Intent intent = new Intent();
                setResult(Activity.RESULT_CANCELED, intent);
                finish();
                return true;
            default:
                return super.onOptionsItemSelected(menuItem);
        }
    }
    
    public void initiate()
    {
        languagesRadioGroup = (RadioGroup) findViewById(R.id.languagesRadioGroup);
        englishRadioButton = (RadioButton) findViewById(R.id.englishRadioButton);
        arabicRadioButton = (RadioButton) findViewById(R.id.arabicRadioButton);
        urduRadioButton = (RadioButton) findViewById(R.id.urduRadioButton);
        nextBtn = (Button) findViewById(R.id.nextBtn);


        Log.e("tag" , "in initiate");

        if(selectedLanguage.equals("en"))
        {
            englishRadioButton.setChecked(true);
        }else
        {
            arabicRadioButton.setChecked(true);
        }


    }

    public void clickListener()
    {
        nextBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                int selectedId = languagesRadioGroup.getCheckedRadioButtonId();
                RadioButton radioButton = (RadioButton) findViewById(selectedId);
                selectedLanguage = radioButton.getText().toString();

                Log.e("tag", "selected language is : " + selectedLanguage);

                if(selectedLanguage.equals(getResources().getString(R.string.english)))
                {
                    Log.e("tag" , "in english");
                    LocaleHelper.setLocale(SelectLanguage.this , "en");

                }else if(selectedLanguage.equals(getResources().getString(R.string.arabic)))
                {
                    Log.e("tag" , "in arabic");
                    LocaleHelper.setLocale(SelectLanguage.this , "ar");
                }


                if(from.equals("profileFragment"))
                {
                    Intent intent = new Intent();
                    setResult(Activity.RESULT_OK, intent);
                    finish();

                }else
                {
                    Intent intent = new Intent(SelectLanguage.this , Login.class);
                    startActivity(intent);
                }


                //finish();

            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();

    }
}