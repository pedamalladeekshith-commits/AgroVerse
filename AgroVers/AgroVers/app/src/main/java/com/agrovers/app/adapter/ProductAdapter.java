package com.agrovers.app.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.R;
import com.agrovers.app.model.ProductItem;

import java.util.List;

public class ProductAdapter extends RecyclerView.Adapter<ProductAdapter.VH> {

    private final List<ProductItem> items;

    public ProductAdapter(List<ProductItem> items) {
        this.items = items;
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_product, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        ProductItem item = items.get(position);
        holder.name.setText(item.getName());
        holder.category.setText(item.getCategory());
        holder.price.setText(item.getPrice());
    }

    @Override
    public int getItemCount() {
        return items == null ? 0 : items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final TextView name;
        final TextView category;
        final TextView price;

        VH(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.tvProductName);
            category = itemView.findViewById(R.id.tvProductCategory);
            price = itemView.findViewById(R.id.tvProductPrice);
        }
    }
}

