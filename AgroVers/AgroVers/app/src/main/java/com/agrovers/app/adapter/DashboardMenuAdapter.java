package com.agrovers.app.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.R;
import com.agrovers.app.model.DashboardMenuItem;

import java.util.List;

public class DashboardMenuAdapter extends RecyclerView.Adapter<DashboardMenuAdapter.VH> {

    public interface OnMenuClickListener {
        void onMenuClick(DashboardMenuItem item);
    }

    private final List<DashboardMenuItem> items;
    private final OnMenuClickListener listener;

    public DashboardMenuAdapter(List<DashboardMenuItem> items, OnMenuClickListener listener) {
        this.items = items;
        this.listener = listener;
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_dashboard_menu, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        DashboardMenuItem item = items.get(position);
        holder.title.setText(item.getTitle());
        holder.icon.setImageResource(item.getIconResId());
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onMenuClick(item);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items == null ? 0 : items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ImageView icon;
        final TextView title;

        VH(@NonNull View itemView) {
            super(itemView);
            icon = itemView.findViewById(R.id.ivMenuIcon);
            title = itemView.findViewById(R.id.tvMenuTitle);
        }
    }
}

