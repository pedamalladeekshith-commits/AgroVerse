import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import os
import zipfile
import shutil

# Paths adjusted for NEW structure
ZIP_PATH = 'datasets/soil/soil-dataset.zip'
EXTRACT_PATH = 'soil_dataset_extracted'
MODEL_SAVE_PATH = 'backend/models/soil_model.h5'
LABELS_SAVE_PATH = 'backend/models/soil_labels.txt'

def extract_zip(zip_file, extract_to):
    if not os.path.exists(extract_to):
        os.makedirs(extract_to)
    with zipfile.ZipFile(zip_file, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"Extracted {zip_file} to {extract_to}")

def prepare_dataset(base_dir, img_height=128, img_width=128, batch_size=32):
    train_dir = os.path.join(base_dir, 'Soil Train', 'Soil Train')
    test_dir = os.path.join(base_dir, 'Soil Test', 'Soil Test')

    if not os.path.exists(train_dir) or not os.path.exists(test_dir):
        print(f"Error: Training or testing directories not found in {base_dir}")
        return None, None

    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir,
        image_size=(img_height, img_width),
        batch_size=batch_size,
        shuffle=True
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        test_dir,
        image_size=(img_height, img_width),
        batch_size=batch_size,
        shuffle=False
    )
    
    return train_ds, val_ds

def build_model(num_classes, img_height=128, img_width=128):
    model = keras.Sequential([
        layers.Rescaling(1./255, input_shape=(img_height, img_width, 3)),
        layers.Conv2D(32, 3, activation='relu'),
        layers.MaxPooling2D(),
        layers.Conv2D(64, 3, activation='relu'),
        layers.MaxPooling2D(),
        layers.Conv2D(128, 3, activation='relu'),
        layers.MaxPooling2D(),
        layers.Flatten(),
        layers.Dense(128, activation='relu'),
        layers.Dense(num_classes, activation='softmax')
    ])
    return model

def train_soil_model():
    if not os.path.exists(ZIP_PATH):
        print(f"Error: Soil dataset zip not found at {ZIP_PATH}")
        return

    extract_zip(ZIP_PATH, EXTRACT_PATH)
    train_ds, val_ds = prepare_dataset(EXTRACT_PATH)

    if train_ds is None: return

    class_names = train_ds.class_names
    os.makedirs(os.path.dirname(LABELS_SAVE_PATH), exist_ok=True)
    with open(LABELS_SAVE_PATH, 'w') as f:
        for name in class_names:
            f.write(f"{name}\n")

    model = build_model(len(class_names))
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    
    model.fit(train_ds, validation_data=val_ds, epochs=10)

    os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True)
    model.save(MODEL_SAVE_PATH)
    shutil.rmtree(EXTRACT_PATH)
    print(f"Soil model saved to {MODEL_SAVE_PATH}")

if __name__ == "__main__":
    train_soil_model()
