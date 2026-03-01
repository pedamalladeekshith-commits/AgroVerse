package com.agrovers.app.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.R;
import com.agrovers.app.model.CropItem;

import java.util.List;

public class CropAdapter extends RecyclerView.Adapter<CropAdapter.VH> {

    private final List<CropItem> items;

    public CropAdapter(List<CropItem> items) {
        this.items = items;
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_crop, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        CropItem item = items.get(position);
        holder.name.setText(item.getName());
        holder.note.setText(item.getNote());
    }

    @Override
    public int getItemCount() {
        return items == null ? 0 : items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final TextView name;
        final TextView note;

        VH(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.tvCropName);
            note = itemView.findViewById(R.id.tvCropNote);
        }
    }
}

