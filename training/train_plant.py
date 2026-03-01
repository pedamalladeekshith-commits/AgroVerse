import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import os
import zipfile
import shutil

# Paths
ZIP_PATH = 'datasets/plant_disease/new-plant-diseases-dataset.zip'
EXTRACT_PATH = 'p'
MODEL_SAVE_PATH = 'plant_model.keras'
LABELS_SAVE_PATH = 'datasets/plant_disease/plant_labels.txt'
TRAIN_DIR_NAME = 'New Plant Diseases Dataset(Augmented)/New Plant Diseases Dataset(Augmented)/train'
VALID_DIR_NAME = 'New Plant Diseases Dataset(Augmented)/New Plant Diseases Dataset(Augmented)/valid'

IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 20


def extract_zip(zip_file, extract_to):
    if not os.path.exists(extract_to):
        os.makedirs(extract_to)

    with zipfile.ZipFile(zip_file, 'r') as zip_ref:
        zip_ref.extractall(extract_to)

    print("Dataset extracted.")


def prepare_dataset(base_dir):

    train_dir = os.path.join(base_dir, TRAIN_DIR_NAME)
    valid_dir = os.path.join(base_dir, VALID_DIR_NAME)

    print("Preparing datasets...")

    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        shuffle=True
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        valid_dir,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        shuffle=False
    )

    # ✅ Grab class names BEFORE prefetch
    class_names = train_ds.class_names

    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.prefetch(AUTOTUNE)
    val_ds = val_ds.prefetch(AUTOTUNE)

    return train_ds, val_ds, class_names


def build_model(num_classes):

    augmentation = keras.Sequential([
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.12),
        layers.RandomZoom(0.12),
    ])

    base_model = keras.applications.MobileNetV2(
        input_shape=(IMG_SIZE, IMG_SIZE, 3),
        include_top=False,
        weights="imagenet"
    )

    base_model.trainable = False

    model = keras.Sequential([
        augmentation,
        layers.Rescaling(1./255),
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.Dropout(0.4),
        layers.Dense(num_classes, activation='softmax')
    ])

    return model


def train_plant_model():

    extract_zip(ZIP_PATH, EXTRACT_PATH)

    # ✅ updated return values
    train_ds, val_ds, class_names = prepare_dataset(EXTRACT_PATH)

    print(f"Detected {len(class_names)} classes.")

    with open(LABELS_SAVE_PATH, 'w') as f:
        for name in class_names:
            f.write(name + "\n")

    model = build_model(len(class_names))

    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.0001),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"]
    )

    model.summary()

    early_stop = keras.callbacks.EarlyStopping(
        monitor="val_loss",
        patience=4,
        restore_best_weights=True
    )

    print("\n--- Training Started ---")

    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS,
        callbacks=[early_stop]
    )

    print("\n--- Training Finished ---")

    model.save(MODEL_SAVE_PATH)
    print(f"Model saved → {MODEL_SAVE_PATH}")

    print("Cleaning extracted files...")
    shutil.rmtree(EXTRACT_PATH)
    print("Done.")


if __name__ == "__main__":
    train_plant_model()
