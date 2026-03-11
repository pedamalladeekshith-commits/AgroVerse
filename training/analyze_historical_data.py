import pandas as pd
import os

# Path to the new dataset
DATASET_PATH = 'datasets/crop_production_india.csv'

def analyze_data():
    if not os.path.exists(DATASET_PATH):
        print(f"Error: {DATASET_PATH} not found.")
        return

    # Load the dataset
    print(f"Loading {DATASET_PATH}...")
    df = pd.read_csv(DATASET_PATH)

    # Basic Info
    print("\n--- Dataset Overview ---")
    print(f"Total Records: {len(df)}")
    print(f"Columns: {df.columns.tolist()}")

    # Unique Values
    print("\n--- Unique Categories ---")
    print(f"States:    {df['State_Name'].nunique()}")
    print(f"Districts: {df['District_Name'].nunique()}")
    print(f"Seasons:   {df['Season'].unique().tolist()}")
    print(f"Crops:     {df['Crop'].nunique()}")

    # Top 10 Crops by frequency in the dataset
    print("\n--- Top 10 Most Common Crops in Dataset ---")
    print(df['Crop'].value_counts().head(10))

    # Our currently supported 22 crops
    supported_crops = [
        'rice', 'maize', 'chickpea', 'kidneybeans', 'pigeonpeas', 
        'mothbeans', 'mungbean', 'blackgram', 'lentil', 'pomegranate', 
        'banana', 'mango', 'grapes', 'watermelon', 'muskmelon', 'apple', 
        'orange', 'papaya', 'coconut', 'cotton', 'jute', 'coffee'
    ]

    # Check for overlap
    print("\n--- Alignment with AgroVerse AI Model ---")
    dataset_crops_lower = [c.strip().lower() for c in df['Crop'].unique()]
    found = []
    missing = []
    
    for crop in supported_crops:
        if crop in dataset_crops_lower:
            found.append(crop)
        else:
            missing.append(crop)
            
    print(f"Crops found in historical data: {len(found)}/22")
    if missing:
        print(f"Crops missing from historical data: {missing}")

    # Example: Search for a specific district
    print("\n--- Example: Most successful crops in NICOBARS ---")
    nicobar_data = df[df['District_Name'] == 'NICOBARS'].copy()
    if not nicobar_data.empty:
        # Calculate yield (Production/Area)
        nicobar_data['Yield'] = nicobar_data['Production'] / nicobar_data['Area']
        top_yields = nicobar_data.groupby('Crop')['Yield'].mean().sort_values(ascending=False).head(5)
        print(top_yields)

if __name__ == "__main__":
    analyze_data()
