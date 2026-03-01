import tensorflow as tf
from tensorflow import keras

# load model
model = keras.models.load_model("plant_model.keras")

# load validation dataset
val_ds = tf.keras.utils.image_dataset_from_directory(
    "p/New Plant Diseases Dataset(Augmented)/New Plant Diseases Dataset(Augmented)/valid",
    image_size=(224,224),
    batch_size=32,
    shuffle=False
)

# evaluate
loss, accuracy = model.evaluate(val_ds)

print("\nValidation Accuracy:", accuracy)
print("Validation Loss:", loss)
