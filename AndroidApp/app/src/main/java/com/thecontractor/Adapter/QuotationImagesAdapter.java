package com.thecontractor.Adapter;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.nguyenhoanglam.imagepicker.model.Image;
import com.thecontractor.Fragments.FullScreenImageFragment;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.QuotationImages;
import com.thecontractor.R;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class QuotationImagesAdapter extends RecyclerView.Adapter<QuotationImagesAdapter.ImageViewHolder> {

    private Context context;
    private List<QuotationImages> images;
    private LayoutInflater inflater;

    public QuotationImagesAdapter(Context context) {
        this.context = context;
        inflater = LayoutInflater.from(context);
        images = new ArrayList<>();
    }

    @Override
    public ImageViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ImageViewHolder(inflater.inflate(R.layout.quotation_image_row, parent, false));
    }

    @Override
    public void onBindViewHolder(ImageViewHolder holder, int position) {
        final QuotationImages image = images.get(position);
        Glide.with(context)
                .load(ApiUrls.QUOTATION_IMAGE_URL + image.getImage_path())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(holder.imageView);

        holder.imageName.setText(image.getImage_path());

        holder.imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Bundle bundle = new Bundle();
                bundle.putSerializable("images", (Serializable) images);
                bundle.putInt("position", position);

                FragmentTransaction ft = ((AppCompatActivity)context).getSupportFragmentManager().beginTransaction();
                FullScreenImageFragment newFragment = FullScreenImageFragment.newInstance();
                newFragment.setArguments(bundle);
                newFragment.show(ft, "slideshow");

            }
        });
    }

    @Override
    public int getItemCount() {
        return images.size();
    }

    public void setData(List<QuotationImages> images) {
        this.images.clear();
        if (images != null) {
            this.images.addAll(images);
        }
        notifyDataSetChanged();
    }

    class ImageViewHolder extends RecyclerView.ViewHolder {

        ImageView imageView;
        TextView imageName;

        public ImageViewHolder(View itemView) {
            super(itemView);
            imageView = itemView.findViewById(R.id.image_thumbnail);
            imageName = itemView.findViewById(R.id.imageName);



        }
    }
}
