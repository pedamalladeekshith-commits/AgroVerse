import os
from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import pickle
import pandas as pd
from utils import preprocess_image # Assuming preprocess_image will be in utils.py

app = Flask(__name__)

# --- Model and Label Paths ---
SOIL_MODEL_PATH = 'models/soil_model.h5'
PLANT_MODEL_PATH = 'models/plant_model.h5'
CROP_MODEL_PATH = 'models/crop_model.pkl'

SOIL_LABELS_PATH = 'datasets/soil/soil_labels.txt'
PLANT_LABELS_PATH = 'datasets/plant_disease/plant_labels.txt'

# --- Load Models and Labels ---
print("Loading models and labels...")
try:
    # Soil Model
    soil_model = tf.keras.models.load_model(SOIL_MODEL_PATH)
    with open(SOIL_LABELS_PATH, 'r') as f:
        soil_labels = [line.strip() for line in f.readlines()]
    print("Soil model loaded successfully.")

    # Plant Model
    plant_model = tf.keras.models.load_model(PLANT_MODEL_PATH)
    with open(PLANT_LABELS_PATH, 'r') as f:
        plant_labels = [line.strip() for line in f.readlines()]
    print("Plant model loaded successfully.")

    # Crop Recommendation Model
    with open(CROP_MODEL_PATH, 'rb') as f:
        crop_model = pickle.load(f)
    print("Crop recommendation model loaded successfully.")

except Exception as e:
    print(f"Error loading models: {e}")
    # Exit if models can't be loaded, as the app is not functional.
    exit()

# --- Image Prediction Endpoints ---

@app.route("/predict_soil", methods=["POST"])
def predict_soil():
    """Endpoint to predict soil type from an image."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        image = Image.open(io.BytesIO(file.read()))
        processed_image = preprocess_image(image, (128, 128)) # Use util function
        
        prediction = soil_model.predict(processed_image)
        score = tf.nn.softmax(prediction[0])
        predicted_class = soil_labels[np.argmax(score)]
        confidence = float(np.max(score))

        return jsonify({"soil_type": predicted_class, "confidence": confidence})
    except Exception as e:
        return jsonify({'error': f'Prediction failed: {str(e)}'}), 500

@app.route("/predict_plant", methods=["POST"])
def predict_plant():
    """Endpoint to predict plant disease from an image."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        image = Image.open(io.BytesIO(file.read()))
        processed_image = preprocess_image(image, (128, 128)) # Use util function

        prediction = plant_model.predict(processed_image)
        score = tf.nn.softmax(prediction[0])
        predicted_class = plant_labels[np.argmax(score)]
        confidence = float(np.max(score))

        return jsonify({"plant_prediction": predicted_class, "confidence": confidence})
    except Exception as e:
        return jsonify({'error': f'Prediction failed: {str(e)}'}), 500

# --- Crop Recommendation Endpoint ---

@app.route("/recommend_crop", methods=["POST"])
def recommend_crop():
    """
    Endpoint for recommending a crop based on environmental factors.
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid input"}), 400

    try:
        # Create a pandas DataFrame from the input
        input_df = pd.DataFrame([data])
        
        # Ensure the order of columns matches the training data
        input_df = input_df[['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']]

        # Make prediction
        prediction = crop_model.predict(input_df)
        
        return jsonify({"recommended_crop": prediction[0]})
    except KeyError as e:
        return jsonify({"error": f"Missing feature in input data: {e}"}), 400
    except Exception as e:
        return jsonify({"error": f"Recommendation failed: {str(e)}"}), 500

if __name__ == "__main__":
    # Use 0.0.0.0 to make the server accessible from the local network
    app.run(host="0.0.0.0", port=5000, debug=True)
