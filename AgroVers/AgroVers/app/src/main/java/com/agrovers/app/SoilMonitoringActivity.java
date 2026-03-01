package com.agrovers.app;

import android.os.Bundle;
import android.widget.TextView;

public class SoilMonitoringActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_soil_monitoring);
        setupBottomNavigation(R.id.nav_analysis);

        TextView tvMoisture = findViewById(R.id.tvMoistureValue);
        TextView tvTemp = findViewById(R.id.tvTemperatureValue);
        TextView tvPh = findViewById(R.id.tvPhValue);
        TextView tvReco = findViewById(R.id.tvSoilRecommendation);

        int moisture = 62;
        double temperature = 28.0;
        double ph = 6.6;

        tvMoisture.setText(getString(R.string.soil_monitoring_moisture, moisture));
        tvTemp.setText(getString(R.string.soil_monitoring_temperature, (int) temperature));
        tvPh.setText(String.valueOf(ph));

        String reco;
        if (moisture < 40) {
            reco = getString(R.string.soil_reco_moisture_low);
        } else if (moisture > 80) {
            reco = getString(R.string.soil_reco_moisture_high);
        } else {
            reco = getString(R.string.soil_reco_moisture_good);
        }

        if (ph < 6.0) {
            reco += getString(R.string.soil_reco_ph_acidic);
        } else if (ph > 7.5) {
            reco += getString(R.string.soil_reco_ph_alkaline);
        } else {
            reco += getString(R.string.soil_reco_ph_optimal);
        }

        tvReco.setText(reco);
    }
}

