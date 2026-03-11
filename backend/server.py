from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import joblib
import pandas as pd
import json
import os

# Services
from services.weather_service import get_seasonal_weather, get_weather_data
from services.market_service import get_market_prices, get_best_market, get_market_intelligence
from services.pest_service import detect_pest_risk
from services.location_service import analyze_regional_suitability
from services.schemes_service import get_all_schemes

app = Flask(__name__)
CORS(app) # Enable CORS for all routes

# --- Configuration ---
API_KEY_SECRET = "AGROVERSE_SECRET_TOKEN_2026"

def require_api_key(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('x-api-key')
        if api_key and api_key == API_KEY_SECRET:
            return f(*args, **kwargs)
        return jsonify({"error": "Unauthorized: Invalid API Key"}), 401
    return decorated

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(BASE_DIR, ".."))

SOIL_MODEL_PATH = os.path.join(PROJECT_ROOT, 'models', 'soil_model.h5')
PLANT_MODEL_PATH = os.path.join(PROJECT_ROOT, 'plant_model.keras')
CROP_MODEL_PATH = os.path.join(PROJECT_ROOT, 'models', 'crop_model.pkl')

SOIL_LABELS_PATH = os.path.join(PROJECT_ROOT, 'datasets', 'soil', 'soil_labels.txt')
PLANT_LABELS_PATH = os.path.join(PROJECT_ROOT, 'datasets', 'plant_disease', 'plant_labels.txt')
CROP_DETAILS_PATH = os.path.join(PROJECT_ROOT, 'crop_details.json')
FARM_LOG_PATH = os.path.join(PROJECT_ROOT, 'backend', 'database', 'farm_log.json')
COMMUNITY_PATH = os.path.join(PROJECT_ROOT, 'backend', 'database', 'community.json')

# --- Disease Treatment Database ---
TREATMENT_DB = {
    "Apple___Apple_scab": "Apply fungicides like captan or sulfur. Remove fallen leaves in autumn.",
    "Apple___Black_rot": "Prune out dead or diseased branches. Apply copper-based fungicides.",
    "Apple___Cedar_apple_rust": "Remove nearby juniper trees if possible. Apply fungicides at bud break.",
    "Apple___healthy": "No treatment needed. Continue regular monitoring and pruning.",
    "Blueberry___healthy": "No treatment needed. Maintain acidic soil pH.",
    "Cherry_(including_sour)___Powdery_mildew": "Apply sulfur or potassium bicarbonate fungicides. Improve air circulation.",
    "Cherry_(including_sour)___healthy": "No treatment needed. Keep area free of debris.",
    "Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot": "Use resistant hybrids. Apply foliar fungicides if disease pressure is high.",
    "Corn_(maize)___Common_rust": "Plant resistant varieties. Fungicides are rarely needed but available.",
    "Corn_(maize)___Northern_Leaf_Blight": "Rotate crops and use resistant hybrids. Apply fungicides if needed.",
    "Corn_(maize)___healthy": "No treatment needed. Ensure proper fertilization.",
    "Grape___Black_rot": "Prune vines to improve airflow. Apply fungicides from bud break to bloom.",
    "Grape___Esca_(Black_Measles)": "Prune out infected wood. Use wound protectants during pruning.",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": "Apply copper fungicides. Remove infected leaves.",
    "Grape___healthy": "No treatment needed. Prune annually for vine health.",
    "Orange___Haunglongbing_(Citrus_greening)": "Control Asian citrus psyllid. Remove infected trees to prevent spread.",
    "Peach___Bacterial_spot": "Plant resistant varieties. Apply copper sprays during dormancy.",
    "Peach___healthy": "No treatment needed. Thin fruit for better size and health.",
    "Pepper,_bell___Bacterial_spot": "Use pathogen-free seeds. Apply copper-based bactericides.",
    "Pepper,_bell___healthy": "No treatment needed. Maintain consistent watering.",
    "Potato___Early_blight": "Rotate crops. Apply fungicides like chlorothalonil or mancozeb.",
    "Potato___Late_blight": "Use certified seed potatoes. Apply fungicides regularly during wet weather.",
    "Potato___healthy": "No treatment needed. Hill potatoes to protect tubers.",
    "Raspberry___healthy": "No treatment needed. Prune floricanes after harvest.",
    "Soybean___healthy": "No treatment needed. Monitor for soybean aphid.",
    "Squash___Powdery_mildew": "Improve air circulation. Apply fungicides like neem oil or sulfur.",
    "Strawberry___Leaf_scorch": "Plant resistant cultivars. Remove older infected leaves.",
    "Strawberry___healthy": "No treatment needed. Mulch with straw to keep berries clean.",
    "Tomato___Bacterial_spot": "Use copper-based sprays. Avoid overhead irrigation.",
    "Tomato___Early_blight": "Apply fungicides. Rotate crops and remove lower leaves.",
    "Tomato___Late_blight": "Apply fungicides like copper or chlorothalonil. Destroy infected plants.",
    "Tomato___Leaf_Mold": "Improve greenhouse ventilation. Apply fungicides.",
    "Tomato___Septoria_leaf_spot": "Remove infected leaves. Apply fungicides. Mulch to prevent splash-back.",
    "Tomato___Spider_mites_Two-spotted_spider_mite": "Apply insecticidal soap or neem oil. Increase humidity.",
    "Tomato___Target_Spot": "Apply fungicides. Ensure proper spacing for airflow.",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus": "Control whiteflies with insecticides or reflective mulches.",
    "Tomato___Tomato_mosaic_virus": "Remove infected plants. Avoid handling plants after using tobacco.",
    "Tomato___healthy": "No treatment needed. Support plants with cages or stakes."
}

# --- Global Resources ---
models = {}
db = {}

def load_resources():
    print("\n" + "="*50 + "\n      AgroVerse Intelligence Server Booting\n" + "="*50)
    try:
        os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
        models['soil'] = tf.keras.models.load_model(SOIL_MODEL_PATH, compile=False)
        models['plant'] = tf.keras.models.load_model(PLANT_MODEL_PATH, compile=False)
        models['crop'] = joblib.load(CROP_MODEL_PATH)
        
        with open(SOIL_LABELS_PATH, 'r') as f: db['soil_labels'] = [l.strip() for l in f]
        with open(PLANT_LABELS_PATH, 'r') as f: db['plant_labels'] = [l.strip() for l in f]
        with open(CROP_DETAILS_PATH, 'r') as f: db['crops'] = json.load(f)
        
        print("✓ All AI Models and Knowledge Bases initialized.")
    except Exception as e:
        print(f"❌ Boot Error: {e}")

load_resources()

# --- API Endpoints ---

@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "status": "AgroVerse Intelligence Server is running", 
        "version": "1.0.0",
        "endpoints": ["/current_weather", "/market_prices", "/recommend_crop", "/predict_soil", "/predict_plant", "/schemes", "/farm_logs", "/posts"]
    })

@app.route("/current_weather", methods=["POST"])
@require_api_key
def current_weather():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data"}), 400
    
    from services.weather_service import get_weather_by_coords
    
    lat = data.get('lat')
    lon = data.get('lon')
    city = data.get('city')
    
    if lat and lon:
        weather, error = get_weather_by_coords(lat, lon)
    elif city:
        weather, error = get_weather_data(city)
    else:
        return jsonify({"error": "City or Coordinates required"}), 400
        
    if error:
        return jsonify({"error": error}), 503
    return jsonify(weather)

@app.route("/market_prices", methods=["POST"])
@require_api_key
def market_prices():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing input data"}), 400
    
    # Accept both 'commodity' and 'crop' keys
    commodity = data.get('commodity') or data.get('crop')
    
    if not commodity:
        return jsonify({"error": "Commodity or Crop is required"}), 400
    
    state = data.get('state')
    district = data.get('district')
    
    # For Profit Calculation
    try:
        farm_size = float(data.get('farm_size', 5.0))
        yield_per_acre = float(data.get('yield_per_acre', 2.0))
    except (ValueError, TypeError):
        farm_size = 5.0
        yield_per_acre = 2.0

    records, error = get_market_prices(commodity, state, district)
    
    # With mock fallback, records should always exist, but we keep the check for safety
    if error and not records:
        return jsonify({"error": error}), 503
    
    best = get_best_market(records)
    
    # Calculate revenue if we have a best market
    estimated_revenue = 0
    if best:
        modal_price = best.get('modal_price', 0)
        # Formula: Total Revenue = farm_size * yield_per_acre * modal_price * 10
        estimated_revenue = round(farm_size * yield_per_acre * modal_price * 10, 2)
        best['estimated_revenue'] = estimated_revenue
        best['farm_size'] = farm_size
        best['yield_per_acre'] = yield_per_acre

    return jsonify({
        "commodity": commodity.capitalize(),
        "best_market": best,
        "market_comparison": records,
        "estimated_revenue": estimated_revenue,
        "farm_size": farm_size,
        "yield_per_acre": yield_per_acre
    })

@app.route("/recommend_crop", methods=["POST"])
@require_api_key
def recommend_crop():
    data = request.get_json()
    if not data: return jsonify({"error": "Missing input data"}), 400

    city = data.get("city")
    if not city: return jsonify({"error": "City name is required"}), 400
    
    land_size = float(data.get("land_size", 1.0))

    weather, error = get_seasonal_weather(city)
    if error: return jsonify({"error": error}), 503

    try:
        feat_dict = {
            'N': float(data.get('N', 0)), 'P': float(data.get('P', 0)), 'K': float(data.get('K', 0)),
            'temperature': weather['avg_temp'], 'humidity': weather['avg_humidity'],
            'ph': float(data.get('ph', 6.5)), 'rainfall': weather['total_rainfall']
        }
        features_df = pd.DataFrame([feat_dict])
        prediction = models['crop'].predict(features_df)[0]
        crop_name = str(prediction).capitalize()

        state = weather.get('region', 'Karnataka')
        
        # Calculate yield based on crop details and land size
        crop_info = db['crops'].get(crop_name, {})
        yield_per_hectare = crop_info.get('yield_per_hectare', 2.5) # Default if missing
        acre_to_hectare = land_size / 2.47
        total_yield_tons = round(yield_per_hectare * acre_to_hectare, 2)
        
        market_intel, _ = get_market_intelligence(crop_name, state, yield_tons=total_yield_tons)

        # Dynamic Reasoning Logic
        reasoning = []
        if float(data.get('ph', 6.5)) >= 6.0 and float(data.get('ph', 6.5)) <= 7.0:
            reasoning.append(f"Your soil pH ({data.get('ph')}) is in the ideal neutral range.")
        if weather['avg_temp'] > 25:
            reasoning.append(f"The high average temperature ({weather['avg_temp']}°C) favors this tropical crop.")
        if weather['total_rainfall'] > 800:
            reasoning.append(f"Abundant seasonal rainfall ({weather['total_rainfall']}mm) provides natural irrigation.")

        explanation = " ".join(reasoning) if reasoning else f"AI suggests {crop_name} based on optimal soil nutrient levels."

        response = {
            "recommended_crop": crop_name,
            "confidence": f"{float(np.max(models['crop'].predict_proba(features_df)[0])):.0%}",
            "weather_summary": weather,
            "market_intelligence": market_intel,
            "pest_alerts": detect_pest_risk(weather['avg_temp'], weather['avg_humidity']),
            "regional_insight": analyze_regional_suitability(city, crop_name),
            "crop_details": crop_info,
            "land_size_acres": land_size,
            "estimated_yield_tons": total_yield_tons,
            "explanation": explanation
        }

        return jsonify(response)
    except Exception as e:
        return jsonify({"error": f"Advisory Pipeline Error: {str(e)}"}), 500

@app.route("/predict_soil", methods=["POST"])
@require_api_key
def predict_soil():
    file = request.files.get('file')
    if not file: return jsonify({"error": "No file"}), 400
    img = Image.open(io.BytesIO(file.read())).convert("RGB").resize((128, 128))
    arr = np.expand_dims(np.array(img, dtype=np.float32), 0)
    preds = models['soil'](arr, training=False).numpy()[0]
    idx = np.argmax(preds)
    return jsonify({"soil_type": db['soil_labels'][idx], "confidence": f"{preds[idx]:.1%}"})

@app.route("/predict_plant", methods=["POST"])
@require_api_key
def predict_plant():
    file = request.files.get('file')
    if not file: return jsonify({"error": "No file"}), 400
    img = Image.open(io.BytesIO(file.read())).convert("RGB").resize((224, 224))
    arr = np.expand_dims(np.array(img, dtype=np.float32), 0)
    preds = models['plant'](arr, training=False).numpy()[0]
    idx = np.argmax(preds)
    
    disease_name = db['plant_labels'][idx]
    treatment = TREATMENT_DB.get(disease_name, "Consult an agricultural expert for specific treatment.")
    
    return jsonify({
        "prediction": disease_name.replace("___", " ").replace("_", " "),
        "confidence": f"{preds[idx]:.1%}",
        "treatment": treatment
    })

@app.route("/schemes", methods=["GET"])
@require_api_key
def get_schemes():
    return jsonify(get_all_schemes())

@app.route("/farm_logs", methods=["GET"])
@require_api_key
def get_farm_logs():
    if not os.path.exists(FARM_LOG_PATH): return jsonify([])
    with open(FARM_LOG_PATH, 'r') as f:
        return jsonify(json.load(f))

@app.route("/add_farm_log", methods=["POST"])
@require_api_key
def add_farm_log():
    data = request.get_json()
    if not data: return jsonify({"error": "No data"}), 400
    logs = []
    if os.path.exists(FARM_LOG_PATH):
        with open(FARM_LOG_PATH, 'r') as f:
            logs = json.load(f)
    logs.append({
        "date": data.get("date", ""),
        "activity": data.get("activity", ""),
        "expense": data.get("expense", 0),
        "crop_stage": data.get("crop_stage", ""),
        "notes": data.get("notes", "")
    })
    with open(FARM_LOG_PATH, 'w') as f:
        json.dump(logs, f)
    return jsonify({"success": True})

@app.route("/posts", methods=["GET"])
@require_api_key
def get_posts():
    if not os.path.exists(COMMUNITY_PATH): return jsonify([])
    with open(COMMUNITY_PATH, 'r') as f:
        return jsonify(json.load(f))

@app.route("/add_post", methods=["POST"])
@require_api_key
def add_post():
    data = request.get_json()
    if not data: return jsonify({"error": "No data"}), 400
    posts = []
    if os.path.exists(COMMUNITY_PATH):
        with open(COMMUNITY_PATH, 'r') as f:
            posts = json.load(f)
    posts.append({
        "id": len(posts) + 1,
        "author": data.get("author", "Farmer"),
        "title": data.get("title", ""),
        "content": data.get("content", ""),
        "replies": []
    })
    with open(COMMUNITY_PATH, 'w') as f:
        json.dump(posts, f)
    return jsonify({"success": True})

@app.route("/add_reply", methods=["POST"])
@require_api_key
def add_reply():
    data = request.get_json()
    post_id = data.get("post_id")
    if not post_id: return jsonify({"error": "Missing post_id"}), 400
    posts = []
    if os.path.exists(COMMUNITY_PATH):
        with open(COMMUNITY_PATH, 'r') as f:
            posts = json.load(f)
    for post in posts:
        if post["id"] == post_id:
            post["replies"].append({
                "author": data.get("author", "Farmer"),
                "content": data.get("content", "")
            })
            break
    with open(COMMUNITY_PATH, 'w') as f:
        json.dump(posts, f)
    return jsonify({"success": True})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
