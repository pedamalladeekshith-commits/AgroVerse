#!/usr/bin/env python3
"""
AI Crop Recommendation System - Terminal Agent
An intelligent farming assistant that runs in the terminal
"""

import json # Import json for loading crop details
import time
import sys
import joblib # Import joblib for loading .pkl models
import numpy as np # Import numpy for numerical operations
import pandas as pd # Import pandas, common for feature preparation
from datetime import datetime


class Colors:
    """ANSI color codes for terminal output"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'


class CropRecommendationAgent:
    def __init__(self):
        self.farmer_data = {}
        # Load crop details from JSON file
        try:
            with open('crop_details.json', 'r') as f:
                self.crop_database = json.load(f)
            print("Crop details loaded from crop_details.json.")
        except FileNotFoundError:
            print(f"{Colors.RED}Error: crop_details.json not found. Using empty crop database.{Colors.END}")
            self.crop_database = {}
        except json.JSONDecodeError as e:
            print(f"{Colors.RED}Error decoding crop_details.json: {e}. Using empty crop database.{Colors.END}")
            self.crop_database = {}

        # Define model path
        self.CROP_MODEL_PATH = 'models/crop_model.pkl'

        # Load the ML crop recommendation model
        print("Loading AI Crop Recommendation Model...")
        try:
            self.crop_model = joblib.load(self.CROP_MODEL_PATH)
            print("AI Crop Recommendation Model loaded successfully.")
        except Exception as e:
            print(f"{Colors.RED}Error loading crop model: {e}. Falling back to rule-based recommendations.{Colors.END}")
            self.crop_model = None # Indicate model failed to load

        # Define a mapping for model output to crop names
        # IMPORTANT: This mapping assumes the order of classes the model was trained on.
        # If the model's output indices do not correspond to this order, predictions will be incorrect.
        self.model_crop_labels = [
            'Cotton', 'Groundnut', 'Maize', 'Potato', 'Rice', 'Tomato', 'Wheat'
        ]

        # Define mappings for features that were likely used in training
        # These are assumptions based on the collected data
        self.soil_type_encoding = {
            'clay': 0, 'sandy': 1, 'loamy': 2, 'black': 3, 'red': 4, 'alluvial': 5
        }
        self.soil_ph_encoding = {
            'acidic': 0, 'neutral': 1, 'alkaline': 2
        }
        self.water_availability_encoding = {
            'low': 0, 'medium': 1, 'high': 2
        }
        self.season_encoding = {
            'summer/zaid': 0, 'monsoon/kharif': 1, 'winter/rabi': 2
        }
        # Assuming other potential features if your model used them (e.g., N, P, K levels)
        # For this example, we'll only use what's collected and encoded.



    def print_banner(self):
        """Display welcome banner"""
        print("\n" + "="*70)
        print(
            f"{Colors.BOLD}{Colors.GREEN}{'🌾 AI CROP RECOMMENDATION SYSTEM 🌾':^70}{Colors.END}")
        print("="*70)
        print(f"{Colors.CYAN}{'Smart Farming Decisions Powered by AI':^70}{Colors.END}")
        print("="*70 + "\n")
        time.sleep(0.5)

    def slow_print(self, text, color=Colors.END, delay=0.03):
        """Print text with typing effect"""
        for char in text:
            sys.stdout.write(color + char + Colors.END)
            sys.stdout.flush()
            time.sleep(delay)
        print()

    def get_input(self, prompt, options=None):
        """Get user input with validation"""
        while True:
            print(f"\n{Colors.YELLOW}{prompt}{Colors.END}")
            if options:
                for i, option in enumerate(options, 1):
                    print(f"  {Colors.CYAN}{i}.{Colors.END} {option}")
                choice = input(
                    f"\n{Colors.BOLD}Enter your choice (1-{len(options)}): {Colors.END}").strip()
                try:
                    idx = int(choice) - 1
                    if 0 <= idx < len(options):
                        # Extract the key part and convert to lower for consistent mapping
                        return options[idx].split(' (')[0].split(': ')[-1].lower()
                    print(
                        f"{Colors.RED}Invalid choice! Please try again.{Colors.END}")
                except ValueError:
                    print(f"{Colors.RED}Please enter a number!{Colors.END}")
            else:
                value = input(
                    f"{Colors.BOLD}Enter value: {Colors.END}").strip()
                if value:
                    return value
                print(f"{Colors.RED}This field cannot be empty!{Colors.END}")

    def collect_soil_data(self):
        """Collect soil information"""
        print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}📊 STEP 1: SOIL ANALYSIS{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")

        self.slow_print("Let's analyze your soil conditions...", Colors.GREEN)

        self.farmer_data['soil_type'] = self.get_input(
            "What is your soil type?",
            [
                "Clay Soil (Heavy, water-retaining)",
                "Sandy Soil (Light, well-draining)",
                "Loamy Soil (Ideal balanced soil)",
                "Black Soil (Cotton soil, moisture retaining)",
                "Red Soil (Iron-rich, well-aerated)",
                "Alluvial Soil (Fertile river deposits)"
            ]
        )

        self.farmer_data['soil_ph'] = self.get_input(
            "What is your soil pH level?",
            [
                "Acidic (pH < 6.0)",
                "Neutral (pH 6.0-7.5)",
                "Alkaline (pH > 7.5)"
            ]
        )

        print(f"\n{Colors.GREEN}✓ Soil data collected successfully!{Colors.END}")
        time.sleep(0.5)

    def collect_water_data(self):
        """Collect water availability information"""
        print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}💧 STEP 2: WATER RESOURCES{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")

        self.slow_print(
            "Now let's understand your water availability...", Colors.BLUE)

        self.farmer_data['water_source'] = self.get_input(
            "What is your primary water source?",
            [
                "Borewell",
                "Canal",
                "River",
                "Pond/Tank",
                "Rainfall Only"
            ]
        )

        self.farmer_data['water_availability'] = self.get_input(
            "How much water is available?",
            [
                "High (Year-round availability)",
                "Medium (Seasonal availability)",
                "Low (Limited water)"
            ]
        )

        print(f"\n{Colors.BLUE}✓ Water data collected successfully!{Colors.END}")
        time.sleep(0.5)

    def collect_climate_data(self):
        """Collect climate and farm information"""
        print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")
        print(
            f"{Colors.HEADER}{Colors.BOLD}🌡️ STEP 3: CLIMATE & FARM DETAILS{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")

        self.slow_print(
            "Almost there! Just need some climate info...", Colors.YELLOW)

        self.farmer_data['location'] = self.get_input(
            "Enter your location/state (e.g., Punjab, Maharashtra):",
            None
        )

        self.farmer_data['season'] = self.get_input(
            "Which season are you planning to grow?",
            [
                "Summer/Zaid (March-June)",
                "Monsoon/Kharif (June-October)",
                "Winter/Rabi (October-March)"
            ]
        )

        self.farmer_data['land_size'] = self.get_input(
            "Enter your land size in acres:",
            None
        )

        try:
            self.farmer_data['land_size'] = float(
                self.farmer_data['land_size'])
        except ValueError:
            print(f"{Colors.RED}Invalid land size, using default 5 acres{Colors.END}")
            self.farmer_data['land_size'] = 5.0

        print(f"\n{Colors.YELLOW}✓ All data collected successfully!{Colors.END}")
        time.sleep(0.5)

    def _prepare_crop_features(self):
        """
        Prepares the collected farmer data into a feature vector suitable for crop_model.pkl.
        Assumes the model expects features in a specific order and encoding.
        """
        # Default values for features in case some data is missing or unexpected
        # These defaults should ideally reflect the most common or neutral values from the training data.
        soil_type_encoded = self.soil_type_encoding.get(self.farmer_data.get('soil_type', 'loamy').lower(), 2) # Default to 'loamy'
        soil_ph_encoded = self.soil_ph_encoding.get(self.farmer_data.get('soil_ph', 'neutral').lower(), 1) # Default to 'neutral'
        water_availability_encoded = self.water_availability_encoding.get(self.farmer_data.get('water_availability', 'medium').lower(), 1) # Default to 'medium'
        season_encoded = self.season_encoding.get(self.farmer_data.get('season', 'monsoon/kharif').lower(), 1) # Default to 'monsoon/kharif'
        land_size_acres = self.farmer_data.get('land_size', 5.0) # Default to 5.0

        # Create a feature vector. The order here MUST match the order of features
        # the crop_model.pkl was trained on.
        # This is a crucial assumption.
        feature_vector = np.array([
            soil_type_encoded,
            soil_ph_encoded,
            water_availability_encoded,
            season_encoded,
            land_size_acres
            # Add other features like N, P, K, humidity etc. if the model was trained with them.
            # For now, we only use the collected and encoded data.
        ]).reshape(1, -1) # Reshape for single prediction

        # If the model expects a pandas DataFrame with specific column names:
        # feature_df = pd.DataFrame([features_dict])
        # return feature_df

        return feature_vector


    def analyze_and_recommend(self):
        """AI logic to recommend crop using the loaded ML model"""
        print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}🤖 AI ANALYSIS IN PROGRESS...{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.END}\n")

        self.slow_print("Analyzing soil composition...", Colors.CYAN, 0.02)
        time.sleep(0.3)
        self.slow_print("Evaluating water availability...", Colors.CYAN, 0.02)
        time.sleep(0.3)
        self.slow_print("Checking climate conditions...", Colors.CYAN, 0.02)
        time.sleep(0.3)
        self.slow_print("Consulting AI model for optimal crop match...", Colors.CYAN, 0.02)
        time.sleep(0.5)

        primary_crop = "Wheat" # Default fallback
        alternative_crops = []

        if self.crop_model:
            try:
                features = self._prepare_crop_features()
                # Assuming the model returns a single prediction (class index)
                prediction_index = self.crop_model.predict(features)[0]
                primary_crop = self.model_crop_labels[prediction_index]

                # For alternative crops, we might need probabilities or top-k predictions
                # For simplicity, if the model provides probabilities, we can get top N.
                # If not, we can fall back to a simple rule or an arbitrary set.
                if hasattr(self.crop_model, 'predict_proba'):
                    probabilities = self.crop_model.predict_proba(features)[0]
                    top_indices = probabilities.argsort()[-3:][::-1] # Top 3
                    alternative_crops_indices = [idx for idx in top_indices if idx != prediction_index]
                    alternative_crops = [self.model_crop_labels[idx] for idx in alternative_crops_indices[:2]]
                else:
                     # Fallback for models without predict_proba or if we just want a simple alternative
                    # For example, select a few crops from the static database that are "close" by rule-based.
                    # For now, let's keep it simple and pick from a predefined list or similar conditions.
                    # Or, as a placeholder, return a couple of crops from the existing db.
                    all_crops = list(self.crop_database.keys())
                    if primary_crop in all_crops:
                        all_crops.remove(primary_crop)
                    
                    num_alternatives = min(2, len(all_crops))
                    if num_alternatives > 0:
                        alternative_crops = np.random.choice(all_crops, num_alternatives, replace=False).tolist()
                    else:
                        alternative_crops = []

            except Exception as e:
                print(f"{Colors.RED}Error during model prediction: {e}. Falling back to rule-based recommendations.{Colors.END}")
                # Fallback to the original rule-based logic if ML prediction fails
                primary_crop, alternative_crops = self._analyze_and_recommend_rule_based()
        else:
            # Fallback to the original rule-based logic if model was not loaded
            primary_crop, alternative_crops = self._analyze_and_recommend_rule_based()

        return primary_crop, alternative_crops

    def _analyze_and_recommend_rule_based(self):
        """Original rule-based AI logic to recommend crop (fallback)"""
        soil = self.farmer_data['soil_type']
        water = self.farmer_data['water_availability']
        season = self.farmer_data['season']

        recommended_crops = []

        for crop_name, crop_data in self.crop_database.items():
            score = 0

            if soil in crop_data['suitable_soil']:
                score += 3

            if season in crop_data['suitable_season']:
                score += 3

            if water in crop_data['water_need']:
                score += 2

            if score >= 5:
                recommended_crops.append((crop_name, score))

        if not recommended_crops:
            recommended_crops = [('Wheat', 0)] # Fallback default

        recommended_crops.sort(key=lambda x: x[1], reverse=True)

        return recommended_crops[0][0], [c[0] for c in recommended_crops[1:3]]


    def display_recommendation(self, primary_crop, alternative_crops):
        """Display comprehensive recommendation"""
        # Ensure the recommended crop is in the database for details, fallback if not
        crop = self.crop_database.get(primary_crop)
        if not crop:
            print(f"{Colors.RED}Warning: Recommended crop '{primary_crop}' not found in detailed database. Displaying default information for 'Wheat'.{Colors.END}")
            primary_crop = 'Wheat'
            crop = self.crop_database.get(primary_crop)
            if not crop:
                print(f"{Colors.RED}Error: Default crop 'Wheat' not found in database. Cannot display recommendation.{Colors.END}")
                return

        print(f"\n{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}✅ RECOMMENDATION READY!{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}\n")

        # Primary Recommendation
        print(
            f"{Colors.BOLD}{Colors.GREEN}🌾 RECOMMENDED CROP: {primary_crop.upper()}{Colors.END}")
        if alternative_crops:
            print(
                f"{Colors.CYAN}Alternative Options: {', '.join(alternative_crops)}{Colors.END}")

        print(f"\n{Colors.UNDERLINE}Quick Overview:{Colors.END}")
        print(f"  Duration: {crop['duration']}")
        print(f"  Water Requirement: {crop['water_req']}")
        print(f"  Optimal Temperature: {crop['temperature']}")
        print(f"  Soil pH: {crop['soil_ph']}")

        # Financial Analysis
        self.display_financial_analysis(crop)

        # Crop Rotation
        self.display_crop_rotation(crop)

        # Fertilizer Schedule
        self.display_fertilizers(crop)

        # Pest Management
        self.display_pesticides(crop)

        # Growing Guide
        self.display_growing_guide(crop)

        # Expert Tips
        self.display_expert_tips(crop)

    def display_financial_analysis(self, crop):
        """Display detailed financial breakdown"""
        print(f"\n{Colors.YELLOW}{Colors.BOLD}{'='*70}{Colors.END}")
        print(
            f"{Colors.YELLOW}{Colors.BOLD}💰 FINANCIAL PROJECTION ({self.farmer_data['land_size']} acres){Colors.END}")
        print(f"{Colors.YELLOW}{Colors.BOLD}{'='*70}{Colors.END}")

        # Convert to hectare (1 hectare = 2.47 acres)
        acre_conversion = self.farmer_data['land_size'] / 2.47

        costs = crop['costs']
        total_cost = sum(costs.values()) * acre_conversion

        print(f"\n{Colors.UNDERLINE}Cost Breakdown:{Colors.END}")
        print(
            f"  Seed Cost:        ₹{int(costs['seed'] * acre_conversion):>10,}")
        print(
            f"  Fertilizer Cost:  ₹{int(costs['fertilizer'] * acre_conversion):>10,}")
        print(
            f"  Pesticide Cost:   ₹{int(costs['pesticide'] * acre_conversion):>10,}")
        print(
            f"  Labor Cost:       ₹{int(costs['labor'] * acre_conversion):>10,}")
        print(
            f"  Irrigation Cost:  ₹{int(costs['irrigation'] * acre_conversion):>10,}")
        print(
            f"  Miscellaneous:    ₹{int(costs['misc'] * acre_conversion):>10,}")
        print(f"  {'-'*40}")
        print(f"  {Colors.BOLD}  Total Estimated Cost: ₹{int(total_cost):>10,}{Colors.END}")

        yield_per_hectare = crop['yield_per_hectare'] * 1000  # tons to kg
        total_yield = yield_per_hectare * acre_conversion

        market_price = crop['market_price_per_kg']
        total_revenue = total_yield * market_price

        profit = total_revenue - total_cost

        print(f"\n{Colors.UNDERLINE}Revenue Projection:{Colors.END}")
        print(
            f"  Expected Yield:   {int(total_yield):>10,} kg")
        print(
            f"  Market Price:     ₹{market_price:>10,}/kg")
        print(f"  {'-'*40}")
        print(
            f"  {Colors.BOLD}Total Revenue:      ₹{int(total_revenue):>10,}{Colors.END}")

        profit_color = Colors.GREEN if profit >= 0 else Colors.RED
        print(f"\n{Colors.BOLD}{profit_color}Projected Profit: ₹{int(profit):,}{Colors.END}")

    def display_crop_rotation(self, crop):
        """Display crop rotation suggestions"""
        print(f"\n{Colors.CYAN}{Colors.BOLD}🔄 CROP ROTATION PLAN{Colors.END}")
        self.slow_print("Crop rotation improves soil health and reduces pests.", Colors.CYAN)
        for i, rotation in enumerate(crop['rotation'], 1):
            print(f"  {Colors.CYAN}Option {i}:{Colors.END} {rotation}")

    def display_fertilizers(self, crop):
        """Display fertilizer schedule"""
        print(f"\n{Colors.BLUE}{Colors.BOLD}🌱 FERTILIZER SCHEDULE{Colors.END}")
        self.slow_print("Apply these fertilizers for optimal growth:", Colors.BLUE)
        for fertilizer in crop['fertilizers']:
            print(f"  {Colors.BLUE}- {fertilizer}{Colors.END}")

    def display_pesticides(self, crop):
        """Display pest management plan"""
        print(f"\n{Colors.RED}{Colors.BOLD}🐞 PEST MANAGEMENT{Colors.END}")
        self.slow_print("Protect your crop from common pests:", Colors.RED)
        for pesticide in crop['pesticides']:
            print(f"  {Colors.RED}- {pesticide}{Colors.END}")

    def display_growing_guide(self, crop):
        """Display key steps for growing"""
        print(f"\n{Colors.GREEN}{Colors.BOLD}📖 STEP-BY-STEP GROWING GUIDE{Colors.END}")
        for i, step in enumerate(crop['key_steps'], 1):
            # Split only on the first colon to handle steps with colons in description
            parts = step.split(':', 1)
            if len(parts) > 1:
                print(f"  {Colors.GREEN}{i}. {parts[0]}:{Colors.END} {parts[1].strip()}")
            else:
                print(f"  {Colors.GREEN}{i}.{Colors.END} {step}")


    def display_expert_tips(self, crop):
        """Display pro tips"""
        print(f"\n{Colors.YELLOW}{Colors.BOLD}💡 EXPERT TIPS FOR HIGHER YIELD{Colors.END}")
        for tip in crop['tips']:
            print(f"  {Colors.YELLOW}⭐ {tip}{Colors.END}")
        print("\n")

    def run(self):
        """Run the crop recommendation agent"""
        self.print_banner()
        self.collect_soil_data()
        self.collect_water_data()
        self.collect_climate_data()

        primary_crop, alternative_crops = self.analyze_and_recommend()

        self.display_recommendation(primary_crop, alternative_crops)

        print(f"\n{'Happy Farming!':^70}\n")


if __name__ == "__main__":
    agent = CropRecommendationAgent()
    agent.run()