package com.agrovers.app.model;

public class SchemeItem {
    private final String name;
    private final String description;

    public SchemeItem(String name, String description) {
        this.name = name;
        this.description = description;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }
}

