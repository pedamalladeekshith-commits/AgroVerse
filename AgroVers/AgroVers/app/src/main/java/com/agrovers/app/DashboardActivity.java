package com.agrovers.app;

import android.content.Intent;
import android.os.Bundle;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.adapter.DashboardMenuAdapter;
import com.agrovers.app.model.DashboardMenuItem;

import java.util.ArrayList;
import java.util.List;

public class DashboardActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);
        setupBottomNavigation(R.id.nav_home);

        RecyclerView rv = findViewById(R.id.rvDashboard);
        rv.setLayoutManager(new GridLayoutManager(this, 2));

        List<DashboardMenuItem> items = new ArrayList<>();
        items.add(new DashboardMenuItem(R.drawable.ic_crop, "Crop Recommendation", CropRecommendationActivity.class));
        items.add(new DashboardMenuItem(R.drawable.ic_pest, "Pest & Disease Detection", PestDiseaseActivity.class));
        items.add(new DashboardMenuItem(R.drawable.ic_market, "Buying & Selling", BuyingSellingActivity.class));
        items.add(new DashboardMenuItem(R.drawable.ic_schemes, "Crop Schemes", CropSchemesActivity.class));
        items.add(new DashboardMenuItem(R.drawable.ic_soil, "Soil Monitoring", SoilMonitoringActivity.class));
        items.add(new DashboardMenuItem(R.drawable.ic_weather, "Weather", WeatherActivity.class));

        DashboardMenuAdapter adapter = new DashboardMenuAdapter(items, item -> {
            Intent intent = new Intent(DashboardActivity.this, item.getTargetActivity());
            startActivity(intent);
        });
        rv.setAdapter(adapter);
    }
}

