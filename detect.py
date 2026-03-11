import cv2
import numpy as np
import os
import sys
import time

# --- Configuration ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Model Paths
SOIL_MODEL_PATH = os.path.join(BASE_DIR, 'models', 'soil_model.h5')
# Root contains plant_model.keras
PLANT_MODEL_PATH = os.path.join(BASE_DIR, 'plant_model.keras')

# Label Paths
SOIL_LABELS_PATH = os.path.join(BASE_DIR, 'datasets', 'soil', 'soil_labels.txt')
PLANT_LABELS_PATH = os.path.join(BASE_DIR, 'datasets', 'plant_disease', 'plant_labels.txt')

# Image settings (Must match training dimensions)
SOIL_IMG_SIZE = (128, 128)
PLANT_IMG_SIZE = (224, 224)

def load_resources():
    print("\n" + "="*50)
    print("      AgroVerse AI Resource Loader")
    print("="*50)
    
    print("1. Loading TensorFlow...")
    try:
        os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 
        import tensorflow as tf
        from PIL import Image
    except ImportError:
        print("❌ Error: TensorFlow or Pillow not installed.")
        return None, None, None, None, None, None

    try:
        # Load Soil Resources
        print("2. Loading Soil Model...")
        if not os.path.exists(SOIL_MODEL_PATH):
             raise FileNotFoundError(f"Missing: {SOIL_MODEL_PATH}")
        soil_model = tf.keras.models.load_model(SOIL_MODEL_PATH, compile=False)
        with open(SOIL_LABELS_PATH, 'r') as f:
            soil_labels = [line.strip() for line in f.readlines() if line.strip()]
        print(f"✓ Soil model ready.")

        # Load Plant Resources
        print("3. Loading Plant Model...")
        if not os.path.exists(PLANT_MODEL_PATH):
             # Try fallback to models/plant_model.h5 if it was a mistake
             PLANT_MODEL_PATH_ALT = os.path.join(BASE_DIR, 'models', 'plant_model.h5')
             if os.path.exists(PLANT_MODEL_PATH_ALT) and os.path.isfile(PLANT_MODEL_PATH_ALT):
                 print(f"Using fallback model path: {PLANT_MODEL_PATH_ALT}")
                 plant_model = tf.keras.models.load_model(PLANT_MODEL_PATH_ALT, compile=False)
             else:
                 raise FileNotFoundError(f"Missing plant model at {PLANT_MODEL_PATH}")
        else:
             plant_model = tf.keras.models.load_model(PLANT_MODEL_PATH, compile=False)
             
        with open(PLANT_LABELS_PATH, 'r') as f:
            plant_labels = [line.strip() for line in f.readlines() if line.strip()]
        print(f"✓ Plant model ready.")
        
        return tf, Image, soil_model, soil_labels, plant_model, plant_labels
    
    except Exception as e:
        print(f"\n❌ FATAL ERROR: {e}")
        return None, None, None, None, None, None

def preprocess_frame(tf, Image, frame, target_size):
    img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    image = Image.fromarray(img_rgb).resize(target_size)
    img_array = np.array(image, dtype=np.float32)
    img_array = np.expand_dims(img_array, axis=0)
    return tf.convert_to_tensor(img_array)

def run_detector():
    print("Initializing camera...")
    camera = cv2.VideoCapture(0)
    if not camera.isOpened():
        print("❌ Camera error. Please check your hardware.")
        return

    res = load_resources()
    if not res: 
        camera.release()
        return
    tf, Image, soil_model, soil_labels, plant_model, plant_labels = res

    current_mode = "soil"
    prediction_interval = 0.15 
    last_pred_time = 0
    
    predicted_class = "Scanning..."
    confidence = 0.0

    print("\n[LIVE] AgroVerse AI Active. Press 'q' to exit.")

    try:
        while True:
            success, frame = camera.read()
            if not success: break

            # Prediction Logic
            if time.time() - last_pred_time > prediction_interval:
                model, labels, size = (soil_model, soil_labels, SOIL_IMG_SIZE) if current_mode == "soil" else (plant_model, plant_labels, PLANT_IMG_SIZE)
                
                inp = preprocess_frame(tf, Image, frame, size)
                preds = model(inp, training=False).numpy()[0]
                idx = np.argmax(preds)
                confidence = float(preds[idx])
                predicted_class = labels[idx] if idx < len(labels) else "Unknown"
                last_pred_time = time.time()

            # UI Overlay
            color = (255, 120, 0) if current_mode == "soil" else (0, 255, 100)
            cv2.rectangle(frame, (15, 15), (420, 140), (0, 0, 0), -1)
            cv2.rectangle(frame, (15, 15), (420, 140), color, 2)
            
            cv2.putText(frame, f"MODE: {current_mode.upper()}", (30, 50), cv2.FONT_HERSHEY_DUPLEX, 0.7, color, 2)
            cv2.putText(frame, f"Match: {predicted_class}", (30, 90), cv2.FONT_HERSHEY_DUPLEX, 0.8, (255, 255, 255), 2)
            
            # Confidence Bar
            cv2.rectangle(frame, (30, 110), (380, 120), (40, 40, 40), -1)
            cv2.rectangle(frame, (30, 110), (30 + int(350 * confidence), 120), color, -1)
            cv2.putText(frame, f"{confidence:.0%}", (385, 120), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

            cv2.imshow("AgroVerse AI Detector", frame)

            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'): break
            elif key == ord('s'): 
                current_mode = "soil"
                predicted_class = "Analyzing..."
            elif key == ord('p'): 
                current_mode = "plant"
                predicted_class = "Analyzing..."

    except KeyboardInterrupt: pass
    finally:
        camera.release()
        cv2.destroyAllWindows()
        print("\n--- Application Closed ---")

if __name__ == "__main__":
    run_detector()
