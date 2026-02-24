package com.thecontractor.Notifications;


import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import androidx.core.app.NotificationCompat;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Login;
import com.thecontractor.R;
import com.thecontractor.VendorActivities.VendorLogin;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;


public class MyFirebaseMessagingService extends FirebaseMessagingService {


    public static final String ANDROID_CHANNEL_ID = "The Contractor";
    private static final String TAG = "tag";

    @Override
    public void onNewToken(String s) {
        super.onNewToken(s);
        Log.e("tag","NEW_TOKEN "+s);
    }


    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {

        Log.e(TAG, "payload is " + remoteMessage.getData());
        Log.e(TAG, "the title is " + remoteMessage.getData().get("title"));
        Log.e(TAG, "the message is : " + remoteMessage.getData().get("message"));

        if(remoteMessage.getData().size() > 0)
        {
            displayNotification(remoteMessage);
        }
    }



    private void displayNotification(RemoteMessage remoteMessage) {

        PendingIntent pendingIntent = null;
        Intent intent = null;


        if(remoteMessage.getData().get("type").equals("user"))
        {
            if (!SharedPrefManager.getInstance(MyFirebaseMessagingService.this).getUserObject().equals("")) {

                if(remoteMessage.getData().get("action").equals("user_inbox"))
                {
                    intent = new Intent(remoteMessage.getData().get("action"));
                    intent.putExtra("vendorId" , remoteMessage.getData().get("vendorId"));
                    intent.putExtra("vendorName" , remoteMessage.getData().get("vendorName"));
                    intent.putExtra("vendorUUID" , remoteMessage.getData().get("vendorUUID"));
                    intent.putExtra("chatUUID" , remoteMessage.getData().get("chatUUID"));
                    intent.putExtra("vendorSerialNo" , remoteMessage.getData().get("vendorSerialNo"));

                }else
                {
                    intent = new Intent(remoteMessage.getData().get("action"));
                    intent.putExtra("id" , remoteMessage.getData().get("id"));
                }



            }else
            {
                intent = new Intent(this, Login.class);
            }


        }else if(remoteMessage.getData().get("type").equals("vendor"))
        {
            if (!SharedPrefManager.getInstance(MyFirebaseMessagingService.this).getVendorObject().equals("")) {

                if(remoteMessage.getData().get("action").equals("user_inbox"))
                {
                    intent = new Intent(remoteMessage.getData().get("action"));
                    intent.putExtra("vendorId" , remoteMessage.getData().get("vendorId"));
                    intent.putExtra("vendorName" , remoteMessage.getData().get("vendorName"));
                    intent.putExtra("vendorUUID" , remoteMessage.getData().get("vendorUUID"));
                    intent.putExtra("chatUUID" , remoteMessage.getData().get("chatUUID"));
                    intent.putExtra("vendorSerialNo" , remoteMessage.getData().get("vendorSerialNo"));

                }else
                {
                    intent = new Intent(remoteMessage.getData().get("action"));
                    intent.putExtra("id" , remoteMessage.getData().get("id"));
                }




            }else
            {
                intent = new Intent(this, VendorLogin.class);
            }
        }


        //intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
        pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);

        NotificationCompat.Builder notificationBuilder;
        if(remoteMessage.getData().get("image") != null)
        {
            Bitmap bitmap = getBitmapFromURL(remoteMessage.getData().get("image"));

            notificationBuilder = new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID)
                    .setSmallIcon(getNotificationIcon())
                    .setContentTitle(remoteMessage.getData().get("title"))
                    .setContentText(remoteMessage.getData().get("message"))
                    .setStyle(new NotificationCompat.BigPictureStyle().bigPicture(bitmap).setSummaryText(remoteMessage.getData().get("message")))
                    .setLargeIcon(BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher))
                    .setAutoCancel(true)
                    .setSound(defaultSoundUri)
                    .setContentIntent(pendingIntent);

        }
        else
        {
           notificationBuilder = new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID)
                   .setSmallIcon(getNotificationIcon())
                   .setContentTitle(remoteMessage.getData().get("title"))
                   .setContentText(remoteMessage.getData().get("message"))
                   .setStyle(new NotificationCompat.BigTextStyle().bigText(remoteMessage.getData().get("message")))
                   .setAutoCancel(true)
                   .setSound(defaultSoundUri)
                   .setContentIntent(pendingIntent);

        }



        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(ANDROID_CHANNEL_ID,
                    getString(R.string.app_name),
                    NotificationManager.IMPORTANCE_DEFAULT);

            AudioAttributes attributes = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build();

            channel.enableLights(true);
            channel.enableVibration(true);
            channel.setSound(defaultSoundUri, attributes); // This is IMPORTANT


            notificationManager.createNotificationChannel(channel);
        }

        notificationManager.notify(0, notificationBuilder.build());

    }


    private int getNotificationIcon() {
        boolean useWhiteIcon = (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP);
        return useWhiteIcon ? R.mipmap.ic_launcher : R.mipmap.ic_launcher;
    }

    public Bitmap getBitmapFromURL(String strURL) {
        try {
            URL url = new URL(strURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap myBitmap = BitmapFactory.decodeStream(input);
            return myBitmap;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
