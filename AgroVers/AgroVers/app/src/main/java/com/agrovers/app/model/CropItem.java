package com.agrovers.app.model;

public class CropItem {
    private final String name;
    private final String note;

    public CropItem(String name, String note) {
        this.name = name;
        this.note = note;
    }

    public String getName() {
        return name;
    }

    public String getNote() {
        return note;
    }
}

