package com.agrovers.app;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;

public class ProfileActivity extends BaseActivity {

    private static final String PREFS = "agrovers_prefs";
    private static final String KEY_PHONE = "phone";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        setupBottomNavigation(R.id.nav_profile);

        TextView tvPhone = findViewById(R.id.tvProfilePhone);
        Button btnLogout = findViewById(R.id.btnLogout);

        SharedPreferences sp = getSharedPreferences(PREFS, MODE_PRIVATE);
        String phone = sp.getString(KEY_PHONE, "");
        tvPhone.setText(phone.isEmpty() ? "Not set" : phone);

        btnLogout.setOnClickListener(v -> {
            sp.edit().remove(KEY_PHONE).apply();
            Intent intent = new Intent(ProfileActivity.this, LoginActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        });
    }
}

