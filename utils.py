import numpy as np

def preprocess_image(image, target_size):
    """
    Preprocesses a PIL image for model prediction.
    - Resizes the image.
    - Converts it to a numpy array.
    - Ensures it has 3 channels.
    - Adds a batch dimension.
    """
    if image.mode != "RGB":
        image = image.convert("RGB")
        
    image = image.resize(target_size)
    img_array = np.array(image)
    
    # Normalize if the model expects it (our models do via Rescaling layer)
    # img_array = img_array / 255.0 
    
    img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension
    return img_array