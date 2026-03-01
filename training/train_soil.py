import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import os
import zipfile
import shutil

# Define paths
ZIP_PATH = 'soil-dataset.zip'
EXTRACT_PATH = 'soil_dataset_extracted'
MODEL_SAVE_PATH = 'soil_model.h5'
LABELS_SAVE_PATH = 'soil_labels.txt'

def extract_zip(zip_file, extract_to):
    """Extracts a zip file to a specified directory."""
    if not os.path.exists(extract_to):
        os.makedirs(extract_to)
    with zipfile.ZipFile(zip_file, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"Extracted {zip_file} to {extract_to}")

def prepare_dataset(base_dir, img_height=128, img_width=128, batch_size=32):
    """Loads and preprocesses image dataset."""
    # The dataset has an extra nested directory, so we need to adjust
    # E.g., soil_dataset_extracted/Soil Train/Soil Train/Alluvial Soil
    # We want to point image_dataset_from_directory to 'Soil Train' and 'Soil Test'
    train_dir = os.path.join(base_dir, 'Soil Train', 'Soil Train')
    test_dir = os.path.join(base_dir, 'Soil Test', 'Soil Test')

    if not os.path.exists(train_dir) or not os.path.exists(test_dir):
        print(f"Error: Training or testing directories not found in {base_dir}")
        print(f"Expected train_dir: {train_dir}")
        print(f"Expected test_dir: {test_dir}")
        exit()

    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir,
        labels='inferred',
        label_mode='int',
        image_size=(img_height, img_width),
        interpolation='nearest',
        batch_size=batch_size,
        shuffle=True
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        test_dir,
        labels='inferred',
        label_mode='int',
        image_size=(img_height, img_width),
        interpolation='nearest',
        batch_size=batch_size,
        shuffle=False # No need to shuffle validation data
    )
    
    return train_ds, val_ds

def build_model(num_classes, img_height=128, img_width=128):
    """Builds a simple CNN model."""
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

def train_model():
    """Main function to extract, train, and save the model."""
    # 1. Extract dataset
    extract_zip(ZIP_PATH, EXTRACT_PATH)

    # 2. Prepare dataset
    train_ds, val_ds = prepare_dataset(EXTRACT_PATH)

    # Get class names
    class_names = train_ds.class_names
    print(f"Detected class names: {class_names}")
    with open(LABELS_SAVE_PATH, 'w') as f:
        for name in class_names:
            f.write(f"{name}\n")
    print(f"Class names saved to {LABELS_SAVE_PATH}")

    # 3. Build model
    num_classes = len(class_names)
    model = build_model(num_classes)

    # 4. Compile and train
    model.compile(
        optimizer='adam',
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=False),
        metrics=['accuracy']
    )

    model.summary()

    # Train for a small number of epochs for demonstration.
    # In a real scenario, more epochs and callbacks would be used.
    epochs = 10
    history = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=epochs
    )

    # 5. Save model
    model.save(MODEL_SAVE_PATH)
    print(f"Model saved to {MODEL_SAVE_PATH}")

    # Clean up extracted files
    shutil.rmtree(EXTRACT_PATH)
    print(f"Cleaned up extracted directory: {EXTRACT_PATH}")

if __name__ == "__main__":
    train_model()
