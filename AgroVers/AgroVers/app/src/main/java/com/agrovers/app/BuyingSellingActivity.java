package com.agrovers.app;

import android.os.Bundle;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.adapter.ProductAdapter;
import com.agrovers.app.model.ProductItem;

import java.util.ArrayList;
import java.util.List;

public class BuyingSellingActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_buying_selling);
        setupBottomNavigation(R.id.nav_home);

        RecyclerView rv = findViewById(R.id.rvProducts);
        rv.setLayoutManager(new LinearLayoutManager(this));

        List<ProductItem> products = new ArrayList<>();
        products.add(new ProductItem("Certified Wheat Seeds", "Seeds & Fertilizers", "₹ 1,200"));
        products.add(new ProductItem("Organic Neem Fertilizer", "Seeds & Fertilizers", "₹ 650"));
        products.add(new ProductItem("Fresh Tomatoes (10 kg)", "Fresh Produce", "₹ 320"));
        products.add(new ProductItem("Fresh Potatoes (10 kg)", "Fresh Produce", "₹ 280"));

        rv.setAdapter(new ProductAdapter(products));
    }
}

