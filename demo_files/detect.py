import cv2
import numpy as np
import tensorflow as tf
from PIL import Image # Needed for preprocess_image consistency

# --- Configuration ---
PLANT_MODEL_PATH = '../models/plant_model.h5' # Adjusted path
PLANT_LABELS_PATH = '../datasets/plant_disease/plant_labels.txt' # Adjusted path
PLANT_IMG_SIZE = (224, 224) # As per plant model summary

# --- Load Model and Labels ---
print("Loading plant model and labels...")
try:
    plant_model = tf.keras.models.load_model(PLANT_MODEL_PATH)
    with open(PLANT_LABELS_PATH, 'r') as f:
        plant_labels = [line.strip() for line in f.readlines()]
    print("Plant model loaded.")
except Exception as e:
    print(f"Error loading plant model or labels: {e}")
    # Fallback to dummy data if model loading fails
    plant_model = None
    plant_labels = ["Healthy", "Leaf Blight", "Leaf Spot", "Powdery Mildew", "Rust"]
    print("Proceeding with dummy plant detection due to model loading error.")


def preprocess_image(frame, target_size=PLANT_IMG_SIZE):
    """
    Preprocesses a video frame for plant model prediction.
    - Converts frame to PIL Image for consistency with utils.py logic.
    - Resizes the image.
    - Converts it to a numpy array.
    - Adds a batch dimension.
    (Normalization / 255.0 is assumed to be handled by the model's preprocessing layers)
    """
    # Convert OpenCV BGR frame to PIL RGB image
    image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    
    image = image.resize(target_size)
    img_array = np.array(image)
    
    img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension
    return img_array

def main():
    """
    Main function to capture video from the webcam, perform plant disease detection,
    and display the results.
    """
    camera = cv2.VideoCapture(0)

    if not camera.isOpened():
        print("Error: Could not open camera.")
        return

    print("\n--- Real-time Plant Disease Detector Started ---")
    print("Press 'q' to quit")

    while True:
        success, frame = camera.read()
        if not success:
            print("Error: Could not read frame from camera.")
            break

        processed_image = preprocess_image(frame)

        # --- Real Prediction using loaded model ---
        if plant_model:
            prediction = plant_model.predict(processed_image, verbose=0)
            score = tf.nn.softmax(prediction[0])
            predicted_class = plant_labels[np.argmax(score)]
            confidence = float(np.max(score))
            prediction_text = f"Prediction: {predicted_class} ({confidence:.2f})"
        else:
            # Fallback to dummy if model failed to load
            predicted_class = np.random.choice(plant_labels)
            prediction_text = f"Prediction (Dummy): {predicted_class}"
        # ------------------------

        # --- Display Results ---
        # Put the predicted disease name on the frame.
        cv2.putText(
            frame,
            prediction_text,
            (10, 40),  # Position of the text
            cv2.FONT_HERSHEY_SIMPLEX,  # Font style
            1.0,  # Font scale
            (0, 255, 0),  # Color in BGR (Green)
            2  # Thickness of the text
        )

        # Show the frame in a window.
        cv2.imshow("Plant Disease Detector", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # --- Cleanup ---
    camera.release()
    cv2.destroyAllWindows()
    print("--- Detector Stopped ---")

if __name__ == "__main__":
    main()