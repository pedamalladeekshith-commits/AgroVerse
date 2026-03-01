package com.agrovers.app;

import android.os.Bundle;
import android.widget.TextView;

public class WeatherActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_weather);
        setupBottomNavigation(R.id.nav_home);

        TextView tvTemp = findViewById(R.id.tvWeatherTemp);
        TextView tvHumidity = findViewById(R.id.tvWeatherHumidity);
        TextView tvWind = findViewById(R.id.tvWeatherWind);
        TextView tvForecast = findViewById(R.id.tvWeatherForecast);

        tvTemp.setText(R.string.weather_temp);
        tvHumidity.setText(R.string.weather_humidity);
        tvWind.setText(R.string.weather_wind);
        tvForecast.setText(R.string.weather_forecast);
    }
}

