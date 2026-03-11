import json
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(BASE_DIR, "..", ".."))
SCHEMES_PATH = os.path.join(PROJECT_ROOT, 'datasets', 'farming_schemes.json')

def get_all_schemes():
    if not os.path.exists(SCHEMES_PATH):
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
