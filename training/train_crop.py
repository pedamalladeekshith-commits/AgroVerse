import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import pickle
import os

# Define paths
DATASET_PATH = 'datasets/crop_recommendation/Crop_recommendation.csv'
MODEL_SAVE_PATH = 'models/crop_model.pkl'

def train_crop_model():
    """
    Loads the dataset, trains a Random Forest model, and saves it.
    """
    print("--- Starting Crop Recommendation Model Training ---")

    # 1. Load Data
    if not os.path.exists(DATASET_PATH):
        print(f"Error: Dataset not found at {DATASET_PATH}")
        exit()
        
    data = pd.read_csv(DATASET_PATH)
    print("Dataset loaded successfully.")
    
    # 2. Preprocessing
    X = data[['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']]
    y = data['label']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    print("Data split into training and testing sets.")

    # 3. Model Training
    print("Training Random Forest Classifier...")
    model = RandomForestClassifier(n_estimators=20, random_state=42)
    model.fit(X_train, y_train)
    print("Model training complete.")

    # 4. Evaluation
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Model Accuracy: {accuracy * 100:.2f}%")

    # 5. Save Model
    with open(MODEL_SAVE_PATH, 'wb') as f:
        pickle.dump(model, f)
    print(f"Model saved to {MODEL_SAVE_PATH}")
    
    print("--- Crop Recommendation Model Training Finished ---\n")

if __name__ == "__main__":
    train_crop_model()
