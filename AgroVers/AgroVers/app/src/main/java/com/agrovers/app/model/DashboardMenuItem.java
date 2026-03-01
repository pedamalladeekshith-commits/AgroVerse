package com.agrovers.app.model;

public class DashboardMenuItem {
    private final int iconResId;
    private final String title;
    private final Class<?> targetActivity;

    public DashboardMenuItem(int iconResId, String title, Class<?> targetActivity) {
        this.iconResId = iconResId;
        this.title = title;
        this.targetActivity = targetActivity;
    }

    public int getIconResId() {
        return iconResId;
    }

    public String getTitle() {
        return title;
    }

    public Class<?> getTargetActivity() {
        return targetActivity;
    }
}

