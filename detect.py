import cv2
import numpy as np
import tensorflow as tf
from PIL import Image
from utils import preprocess_image  # Use the centralized preprocess function

# --- Configuration ---
# Model and Label Paths
SOIL_MODEL_PATH = 'models/soil_model.h5'
PLANT_MODEL_PATH = 'plant_model.keras'
SOIL_LABELS_PATH = 'datasets/soil/soil_labels.txt'
PLANT_LABELS_PATH = 'datasets/plant_disease/plant_labels.txt'

# Image settings
IMG_HEIGHT = 224
IMG_WIDTH = 224

# --- Load Models and Labels ---
print("Loading models and labels...")
try:
    soil_model = tf.keras.models.load_model(SOIL_MODEL_PATH)
    with open(SOIL_LABELS_PATH, 'r') as f:
        soil_labels = [line.strip() for line in f.readlines()]
    print("Soil model loaded.")

    plant_model = tf.keras.models.load_model(PLANT_MODEL_PATH)
    with open(PLANT_LABELS_PATH, 'r') as f:
        plant_labels = [line.strip() for line in f.readlines()]
    print("Plant model loaded.")
except Exception as e:
    print(f"Error loading models: {e}")
    exit()

# --- Main Application ---


def run_detector():
    camera = cv2.VideoCapture(0)
    if not camera.isOpened():
        print("Error: Could not open camera.")
        return

    # Start in 'soil' mode
    current_mode = "soil"

    print("\n--- Real-time Detector Started ---")
    print("Press 's' for Soil Mode")
    print("Press 'p' for Plant Mode")
    print("Press 'q' to quit")

    while True:
        success, frame = camera.read()
        if not success:
            break

        # --- Key press handling for mode switching ---
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('s'):
            current_mode = "soil"
            print("Switched to Soil Detection Mode")
        elif key == ord('p'):
            current_mode = "plant"
            print("Switched to Plant Detection Mode")

        # --- Prediction based on mode ---
        display_text = "Mode: " + current_mode.upper()

        # Convert frame to PIL image for preprocessing
        img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image = Image.fromarray(img_rgb)

        processed_image = preprocess_image(image, (IMG_WIDTH, IMG_HEIGHT))

        if current_mode == "soil":
            model = soil_model
            labels = soil_labels
            prefix = "Soil"
        else:  # plant mode
            model = plant_model
            labels = plant_labels
            prefix = "Plant"

        # Predict
        # Ensure the image has 3 channels for models that expect RGB
        if processed_image.shape[-1] == 1:
            # Repeat the single channel 3 times to create a 3-channel image
            processed_image = np.repeat(processed_image, 3, axis=-1)

        prediction = model.predict(processed_image, verbose=0)
        score = tf.nn.softmax(prediction[0])
        predicted_class = labels[np.argmax(score)]
        confidence = float(np.max(score))

        # Prepare text for display
        prediction_text = f"{prefix}: {predicted_class} ({confidence:.2f})"

        # --- Display results on frame ---
        # Display Mode
        cv2.putText(frame, display_text, (10, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
        # Display Prediction
        cv2.putText(frame, prediction_text, (10, 100),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

        cv2.imshow("AgroVerse Real-time Detector", frame)

    camera.release()
    cv2.destroyAllWindows()
    print("--- Detector Stopped ---")


if __name__ == "__main__":
    run_detector()
