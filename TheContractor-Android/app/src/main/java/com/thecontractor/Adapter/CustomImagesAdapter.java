package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.nguyenhoanglam.imagepicker.model.Image;
import com.thecontractor.R;

import java.util.ArrayList;
import java.util.List;

public class CustomImagesAdapter extends RecyclerView.Adapter<CustomImagesAdapter.ImageViewHolder> {

    private Context context;
    private List<Image> images;
    private LayoutInflater inflater;
    private DeleteImage deleteImage;

    public CustomImagesAdapter(Context context , DeleteImage deleteImage) {
        this.context = context;
        inflater = LayoutInflater.from(context);
        images = new ArrayList<>();
        this.deleteImage = deleteImage;
    }

    @Override
    public ImageViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ImageViewHolder(inflater.inflate(R.layout.custom_image_row, parent, false));
    }

    @Override
    public void onBindViewHolder(ImageViewHolder holder, int position) {
        final Image image = images.get(position);
        Glide.with(context)
                //.load(image.getPath())
                .load(image.getUri())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(holder.imageView);

        holder.imageName.setText(image.getName());

    }

    @Override
    public int getItemCount() {
        return images.size();
    }

    public void setData(List<Image> images) {
        this.images.clear();
        if (images != null) {
            this.images.addAll(images);
        }
        notifyDataSetChanged();
    }

    class ImageViewHolder extends RecyclerView.ViewHolder {

        ImageView imageView , delete_image;
        TextView imageName;

        public ImageViewHolder(View itemView) {
            super(itemView);
            imageView = itemView.findViewById(R.id.image_thumbnail);
            delete_image = itemView.findViewById(R.id.delete_image);
            imageName = itemView.findViewById(R.id.imageName);


            delete_image.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    int pos = getAdapterPosition();

                    deleteImage.selectedImages(pos);

//                    images.remove(pos);
//                    notifyItemRemoved(pos);
//                    notifyItemRangeChanged(pos, images.size());

                }
            });
        }
    }

    public interface DeleteImage
    {
        void selectedImages(int pos);
    }
}
