package com.thecontractor.Global;

import android.app.DownloadManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.util.Log;
import android.widget.Toast;

import com.thecontractor.R;

import java.io.File;


import static android.os.Environment.DIRECTORY_DOWNLOADS;

public class downloadFile {
    public static DownloadManager downloadManager;
    public static long downloadID;
    private static String directoryInstaShoryDirectorydownload_images = "/The Contractor/Contractor Documents/";


    public static void DownloadingInsta(final Context context, String url, String title, String ext) {
        String cutTitle = title;

        downloadManager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
        //  Uri mainUri = FileProvider.get(context, context.getApplicationContext().getPackageName() + ".provider", url);

        DownloadManager.Request request = new DownloadManager.Request(Uri.parse(url));
        request.setTitle(title);

        request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE | DownloadManager.Request.NETWORK_WIFI);  // Tell on which network you want to download file.
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
        request.setVisibleInDownloadsUi(true);

        request.setDescription("Downloading");

        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                request.setDestinationInExternalPublicDir(DIRECTORY_DOWNLOADS, directoryInstaShoryDirectorydownload_images + cutTitle);
        } else {
                request.setDestinationInExternalPublicDir(DIRECTORY_DOWNLOADS, directoryInstaShoryDirectorydownload_images + cutTitle);
        }


        request.allowScanningByMediaScanner();
        downloadID = downloadManager.enqueue(request);
        Log.e("downloadFileName", cutTitle);

        try {
            if (Build.VERSION.SDK_INT >= 19) {
                MediaScannerConnection.scanFile(context, new String[]{new File(DIRECTORY_DOWNLOADS + "/" + directoryInstaShoryDirectorydownload_images + cutTitle).getAbsolutePath()},
                        null, new MediaScannerConnection.OnScanCompletedListener() {
                            public void onScanCompleted(String path, Uri uri) {
                            }
                        });
            } else {
                context.sendBroadcast(new Intent("android.intent.action.MEDIA_MOUNTED", Uri.fromFile(new File(DIRECTORY_DOWNLOADS + "/" + directoryInstaShoryDirectorydownload_images + cutTitle))));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }


        Toast.makeText(context, "Downloading Start!", Toast.LENGTH_SHORT).show();



    }


}