import json
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Attempt to find datasets folder in common locations
SCHEMES_PATH = os.path.abspath(os.path.join(BASE_DIR, "..", "..", "datasets", "farming_schemes.json"))

if not os.path.exists(SCHEMES_PATH):
    # Fallback for different deployment structures
    SCHEMES_PATH = os.path.abspath(os.path.join(os.getcwd(), "datasets", "farming_schemes.json"))

def get_all_schemes():
    if not os.path.exists(SCHEMES_PATH):
        print(f"Warning: Schemes file not found at {SCHEMES_PATH}")
        return []
    try:
        with open(SCHEMES_PATH, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Schemes Service Error: {e}")
        return []

def get_schemes_by_category(category):
    schemes = get_all_schemes()
    return [s for s in schemes if s.get('category') == category]
