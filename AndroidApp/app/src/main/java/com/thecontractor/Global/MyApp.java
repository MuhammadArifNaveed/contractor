package com.thecontractor.Global;

import android.app.Application;
import android.util.Log;

import com.pusher.client.Pusher;
import com.pusher.client.PusherOptions;
import com.pusher.client.channel.Channel;
import com.pusher.client.connection.ConnectionEventListener;
import com.pusher.client.connection.ConnectionState;
import com.pusher.client.connection.ConnectionStateChange;

public class MyApp extends Application {

    private static final String TAG = "tag";
    private static Pusher pusher;
    private static boolean isConnected = false;

    @Override
    public void onCreate() {
        super.onCreate();
        initPusher();
    }

    // 🔹 Initialize & connect (called once)
    private void initPusher() {
        if (pusher != null) return;

        PusherOptions options = new PusherOptions();
        options.setCluster("ap2");

        pusher = new Pusher("97c23a35cc18713570da", options);

        connectPusher();
    }

    public static void connectPusher() {
        if (pusher == null || isConnected) return;

        pusher.connect(new ConnectionEventListener() {
            @Override
            public void onConnectionStateChange(ConnectionStateChange change) {
                Log.e(TAG, "Pusher State: " + change.getCurrentState());
                if (change.getCurrentState() == ConnectionState.CONNECTED) {
                    isConnected = true;
                }
            }

            @Override
            public void onError(String message, String code, Exception e) {
                Log.e(TAG, "Pusher Error: " + message);
                isConnected = false;
            }
        }, ConnectionState.ALL);
    }

    public static Pusher getPusher() {
        return pusher;
    }

    public static Channel subscribeChannel(String channelName) {
        if (pusher == null) return null;

        Channel channel = pusher.getChannel(channelName);
        if (channel == null) {
            channel = pusher.subscribe(channelName);
            Log.e(TAG, "Pusher channel subscribe: " + channelName);

        }
        return channel;
    }

    public static void unsubscribeChannel(String channelName) {
        if (pusher != null && pusher.getChannel(channelName) != null) {
            pusher.unsubscribe(channelName);
        }
    }
}
