package com.thecontractor;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;


import androidx.appcompat.app.AppCompatActivity;



public class WebViewActivity extends AppCompatActivity {
    String link;
    String page;

    WebView websiteWebView;
    ProgressBar websiteProgressBar;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_webview_activity);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
//        getSupportActionBar().hide();

        initiate();
        getDataFromNavigation();
        loadWebsiteFromUrl();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    public void getDataFromNavigation()
    {
        Intent intent = getIntent();
        link = intent.getStringExtra("link");
        page = intent.getStringExtra("page");

        getSupportActionBar().setTitle(page);

        Log.e("tag", "link in web view: "+link);
    }


    public void initiate() {

        websiteWebView = (WebView) findViewById(R.id.websiteWebView);
        websiteProgressBar = (ProgressBar) findViewById(R.id.websiteProgressBar);

    }




    public void loadWebsiteFromUrl()
    {

        WebSettings webSettings = websiteWebView.getSettings();
        websiteWebView.setWebViewClient(new WebsiteWebClient());
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setAllowContentAccess(true);
        webSettings.setAllowFileAccess(true);
        websiteWebView.loadUrl(link);



    }

    public class WebsiteWebClient extends WebViewClient {

        @Override
        public void onPageStarted(android.webkit.WebView view, String url, Bitmap favicon) {
            Log.e("tag", "your current url when webpage loading onPageStarted.." + url);


            super.onPageStarted(view, url, favicon);
        }

        @Override
        public boolean shouldOverrideUrlLoading(android.webkit.WebView view, String url) {

            Log.e("tag" , "url in web view client shouldOverrideUrlLoading:"+url);

            view.loadUrl(url);

            websiteProgressBar.setVisibility(View.VISIBLE);
            return true;

        }

        @Override
        public void onPageFinished(android.webkit.WebView view, String url) {

            super.onPageFinished(view, url);

            websiteProgressBar.setVisibility(View.GONE);
        }

    }





    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (event.getAction() == KeyEvent.ACTION_DOWN) {
            switch (keyCode) {
                case KeyEvent.KEYCODE_BACK:
                    if (websiteWebView.canGoBack()) {
                        websiteWebView.goBack();
                    }
                    else {
                        finish();
                    }
                    return true;
            }

        }
        return super.onKeyDown(keyCode, event);
    }




}