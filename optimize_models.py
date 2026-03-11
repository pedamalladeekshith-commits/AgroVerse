import tensorflow as tf
import os

# Paths (Adjusted to be relative to root)
SOIL_MODEL_H5 = 'models/soil_model.h5'
PLANT_MODEL_KERAS = 'plant_model.keras'

# Output Paths
SOIL_TFLITE = 'models/soil_model.tflite'
PLANT_TFLITE = 'models/plant_model.tflite'

def convert_to_tflite(model_path, output_path):
    print(f"Converting {model_path} to {output_path}...")
    if not os.path.exists(model_path):
        print(f"Error: {model_path} not found.")
        return
    
    try:
        # Load model
        model = tf.keras.models.load_model(model_path, compile=False)
        
        # Convert
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        # Optimize for size
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
        
        # Save
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        print(f"Successfully saved to {output_path}")
    except Exception as e:
        print(f"Conversion failed: {e}")

if __name__ == "__main__":
    convert_to_tflite(SOIL_MODEL_H5, SOIL_TFLITE)
    convert_to_tflite(PLANT_MODEL_KERAS, PLANT_TFLITE)
