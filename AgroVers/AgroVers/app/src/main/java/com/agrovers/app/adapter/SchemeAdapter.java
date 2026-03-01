package com.agrovers.app.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.R;
import com.agrovers.app.model.SchemeItem;

import java.util.List;

public class SchemeAdapter extends RecyclerView.Adapter<SchemeAdapter.VH> {

    public interface OnApplyClickListener {
        void onApply(SchemeItem item);
    }

    private final List<SchemeItem> items;
    private final OnApplyClickListener listener;

    public SchemeAdapter(List<SchemeItem> items, OnApplyClickListener listener) {
        this.items = items;
        this.listener = listener;
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_scheme, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        SchemeItem item = items.get(position);
        holder.name.setText(item.getName());
        holder.description.setText(item.getDescription());
        holder.apply.setOnClickListener(v -> {
            if (listener != null) {
                listener.onApply(item);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items == null ? 0 : items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final TextView name;
        final TextView description;
        final Button apply;

        VH(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.tvSchemeName);
            description = itemView.findViewById(R.id.tvSchemeDescription);
            apply = itemView.findViewById(R.id.btnApplyScheme);
        }
    }
}

