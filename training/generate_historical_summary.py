import pandas as pd
import json
import os

DATASET_PATH = 'datasets/crop_production_india.csv'
SUMMARY_PATH = 'knowledge/district_yield_summary.json'

# Mapping AgroVerse Model names -> Historical Dataset names
CROP_MAPPING = {
    "mungbean": "Moong(Green Gram)",
    "pigeonpeas": "Arhar/Tur",
    "blackgram": "Urad",
    "lentil": "Masoor",
    "jute": "Jute",
    "rice": "Rice",
    "maize": "Maize",
    "wheat": "Wheat",
    "cotton": "Cotton(lint)",
    "banana": "Banana",
    "coconut": "Coconut ",
    "papaya": "Papaya",
    "orange": "Orange",
    "mango": "Mango",
    "grapes": "Grapes"
}

def generate_yield_summary():
    if not os.path.exists(DATASET_PATH):
        print("CSV not found.")
        return

    print("Analyzing historical production data...")
    df = pd.read_csv(DATASET_PATH)
    
    # Calculate Yield (Production / Area)
    # Filter out zeros to avoid division issues
    df = df[df['Area'] > 0]
    df['Yield'] = df['Production'] / df['Area']
    
    # Group by District and Crop to get Average Yield
    summary = df.groupby(['District_Name', 'Crop'])['Yield'].mean().reset_index()
    
    # Convert to a nested dictionary for fast lookup: { "DISTRICT": { "crop": yield } }
    district_map = {}
    for _, row in summary.iterrows():
        dist = row['District_Name'].upper().strip()
        crop = row['Crop'].strip().lower()
        
        if dist not in district_map:
            district_map[dist] = {}
        district_map[dist][crop] = round(float(row['Yield']), 2)

    # Save to knowledge folder
    os.makedirs('knowledge', exist_ok=True)
    with open(SUMMARY_PATH, 'w') as f:
        json.dump({
            "district_data": district_map,
            "mapping": CROP_MAPPING
        }, f, indent=4)
    
    print(f"✓ Created yield summary for {len(district_map)} districts.")

if __name__ == "__main__":
    generate_yield_summary()
