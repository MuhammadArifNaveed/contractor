package com.thecontractor.Model;

import android.net.Uri;

public class NewCustomImagesModel {
    private Uri uri;

    public NewCustomImagesModel(Uri uri) {
        this.uri = uri;
    }

    public Uri getUri() {
        return uri;
    }
}
