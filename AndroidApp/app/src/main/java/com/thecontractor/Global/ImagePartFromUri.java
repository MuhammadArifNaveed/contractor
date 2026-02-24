package com.thecontractor.Global;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okio.BufferedSink;

public class ImagePartFromUri {


    public static MultipartBody.Part createPartFromUri(
            Context context,
            Uri uri,
            String fieldName
    ) {

        ContentResolver resolver = context.getContentResolver();
        String mimeType = resolver.getType(uri);

        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }

        String fileName = "upload_file";

        try (Cursor cursor = resolver.query(uri, null, null, null, null)) {
            if (cursor != null && cursor.moveToFirst()) {
                int index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                if (index != -1) fileName = cursor.getString(index);
            }
        }

        String finalMimeType = mimeType;
        RequestBody requestBody = new RequestBody() {

            @Nullable
            @Override
            public MediaType contentType() {
                return MediaType.parse(finalMimeType);
            }

            @Override
            public long contentLength() throws IOException {
                try (AssetFileDescriptor afd =
                             resolver.openAssetFileDescriptor(uri, "r")) {
                    return afd != null ? afd.getLength() : -1;
                }
            }

            @Override
            public void writeTo(@NonNull BufferedSink sink) throws IOException {
                try (InputStream in = resolver.openInputStream(uri)) {
                    if (in == null) return;
                    byte[] buffer = new byte[8192];
                    int read;
                    while ((read = in.read(buffer)) != -1) {
                        sink.write(buffer, 0, read);
                    }
                }
            }
        };

        return MultipartBody.Part.createFormData(fieldName, fileName, requestBody);
    }


    public static MultipartBody.Part createPartFromUri(Context context, Uri uri, String fieldName, String fileName , String contentType) {
        try {
            InputStream inputStream = context.getContentResolver().openInputStream(uri);
            if (inputStream == null) return null;

            RequestBody requestBody = new RequestBody() {
                @Nullable
                @Override
                public MediaType contentType() {
                    return MediaType.parse(contentType);
                }

                @Override
                public void writeTo(@NonNull BufferedSink sink) throws IOException {
                    byte[] buffer = new byte[8192];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        sink.write(buffer, 0, bytesRead);
                    }
                    inputStream.close();
                }
            };

            return MultipartBody.Part.createFormData(fieldName, fileName, requestBody);

        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static File getFileFromUri(Context context, Uri uri , String imageVideo) {
        if (uri == null) return null;

        if ("file".equals(uri.getScheme())) {
            return new File(uri.getPath());
        }

        if ("content".equals(uri.getScheme())) {
            try {
                InputStream inputStream = context.getContentResolver().openInputStream(uri);
                if (inputStream == null) return null;

                String fileName;
                if(imageVideo.equals("video")){
                    fileName = "upload_" + System.currentTimeMillis() + ".mp4";

                }else {
                    fileName = "upload_" + System.currentTimeMillis() + ".jpg";
                }

                File tempFile = new File(context.getCacheDir(), fileName);

                OutputStream outputStream = new FileOutputStream(tempFile);
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }

                outputStream.close();
                inputStream.close();

                return tempFile;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return null;
    }

    public static String getFileNameFromUri(Context context, Uri uri) {
        String fileName = null;

        if (uri.getScheme().equals("content")) {
            Cursor cursor = context.getContentResolver()
                    .query(uri, null, null, null, null);

            try {
                if (cursor != null && cursor.moveToFirst()) {
                    int nameIndex =
                            cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                    if (nameIndex != -1) {
                        fileName = cursor.getString(nameIndex);
                    }
                }
            } finally {
                if (cursor != null) cursor.close();
            }
        }

        // Fallback
        if (fileName == null) {
            fileName = uri.getLastPathSegment();
        }

        return fileName;
    }

    public static boolean isFileSizeValid(Context context, Uri uri, long MAX_FILE_SIZE) {
        long fileSize = getFileSizeFromUri(context, uri);

        if (fileSize <= 0) {
            Toast.makeText(context,
                    "Unable to determine file size",
                    Toast.LENGTH_SHORT).show();
            return false;
        }

        long tempFIle = MAX_FILE_SIZE * 1024 * 1024;

        if (fileSize > tempFIle) {
            Toast.makeText(context,
                    "File size exceeds" + String.valueOf(MAX_FILE_SIZE) +" MB",
                    Toast.LENGTH_SHORT).show();
            return false;
        }

        return true;
    }

    public static long getFileSizeFromUri(Context context, Uri uri) {
        long size = -1;

        Cursor cursor = context.getContentResolver()
                .query(uri, null, null, null, null);

        try {
            if (cursor != null && cursor.moveToFirst()) {
                int sizeIndex =
                        cursor.getColumnIndex(OpenableColumns.SIZE);
                if (sizeIndex != -1) {
                    size = cursor.getLong(sizeIndex);
                }
            }
        } finally {
            if (cursor != null) cursor.close();
        }

        return size;
    }


}
