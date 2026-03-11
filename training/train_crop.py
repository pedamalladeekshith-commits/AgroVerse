import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, confusion_matrix
import pickle
import os

# Paths according to the new structure
DATASET_PATH = 'datasets/Crop_recommendation.csv'
MODEL_SAVE_PATH = 'models/crop_model.pkl'

def train_model():
    print("Loading dataset...")
    # Check if we need to copy the dataset from the old location
    if not os.path.exists(DATASET_PATH):
        old_path = 'datasets/crop_recommendation/Crop_recommendation.csv'
        if os.path.exists(old_path):
            import shutil
            shutil.copy(old_path, DATASET_PATH)
        else:
            print(f"Error: Dataset not found at {DATASET_PATH} or {old_path}")
            return

    data = pd.read_csv(DATASET_PATH)
    
    X = data[['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']]
    y = data['label']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    print("Training Random Forest Classifier (200 estimators)...")
    model = RandomForestClassifier(n_estimators=200, random_state=42)
    model.fit(X_train, y_train)

    print("Evaluating Model...")
    y_pred = model.predict(X_test)
    
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted', zero_division=0)
    recall = recall_score(y_test, y_pred, average='weighted', zero_division=0)
    conf_matrix = confusion_matrix(y_test, y_pred)

    print("\n--- Evaluation Results ---")
    print(f"Accuracy: {accuracy * 100:.2f}%")
    print(f"Precision: {precision * 100:.2f}%")
    print(f"Recall: {recall * 100:.2f}%")
    print("\nConfusion Matrix:")
    print(conf_matrix)
    print("--------------------------\n")

    os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True)
    with open(MODEL_SAVE_PATH, 'wb') as f:
        pickle.dump(model, f)
    
    print(f"Model successfully saved to {MODEL_SAVE_PATH}")

if __name__ == "__main__":
    train_model()
