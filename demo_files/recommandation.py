#!/usr/bin/env python3
"""
AI Crop Recommendation System - Terminal Agent
An intelligent farming assistant that runs in the terminal
"""

import time
import sys
from datetime import datetime


class CropRecommendationAgent:
    def __init__(self):
        self.farmer_data = {}
        self.crop_database = self.load_crop_database()

    def load_crop_database(self):
        """Comprehensive crop database with all details"""
        return {
            'Rice': {
                'duration': '120-150 days',
                'water_req': 'High (1200-1500mm)',
                'soil_ph': '5.5-7.0',
                'temperature': '20-35°C',
                'suitable_soil': ['clay', 'loamy', 'alluvial'],
                'suitable_season': ['monsoon'],
                'water_need': ['high'],

                'costs': {
                    'seed': 2500, 'fertilizer': 8000, 'pesticide': 4000,
                    'labor': 15000, 'irrigation': 6000, 'misc': 3000
                },
                'yield_per_hectare': 4.5,
                'market_price_per_kg': 22,

                'rotation': [
                    'Wheat → Rice → Pulses',
                    'Rice → Mustard → Green Gram'
                ],

                'fertilizers': [
                    'Urea: 120 kg/hectare (Split: 40kg basal + 40kg tillering + 40kg panicle)',
                    'DAP: 60 kg/hectare (Apply at sowing)',
                    'Potash (MOP): 40 kg/hectare (Apply at sowing)',
                    'Zinc Sulphate: 25 kg/hectare (If deficiency observed)'
                ],

                'pesticides': [
                    'For Stem Borer: Chlorpyrifos 20% EC @ 2ml/liter',
                    'For Leaf Folder: Cartap Hydrochloride 50% SP @ 1g/liter',
                    'For BLB: Copper Oxychloride 50% WP @ 3g/liter',
                    'For Blast: Tricyclazole 75% WP @ 0.6g/liter'
                ],

                'key_steps': [
                    'Land Preparation: Puddle the field 2-3 times, level properly',
                    'Seed Treatment: Treat seeds with Carbendazim @ 2g/kg',
                    'Transplanting: 21-25 days old seedlings, 2-3 per hill, 20x15cm spacing',
                    'Water Management: Maintain 5cm water till flowering',
                    'Weed Control: First at 20-25 days, second at 40-45 days',
                    'Pest Monitoring: Weekly field inspection',
                    'Harvesting: When 80% grains turn golden yellow'
                ],

                'tips': [
                    'Use SRI method to save water and increase yield by 20-30%',
                    'Avoid continuous flooding to prevent methane emission',
                    'Use neem cake as organic alternative',
                    'Install pheromone traps @ 5/acre'
                ]
            },

            'Wheat': {
                'duration': '110-130 days',
                'water_req': 'Moderate (400-500mm)',
                'soil_ph': '6.0-7.5',
                'temperature': '15-25°C',
                'suitable_soil': ['loamy', 'clay', 'alluvial'],
                'suitable_season': ['winter'],
                'water_need': ['medium', 'high'],

                'costs': {
                    'seed': 3000, 'fertilizer': 7000, 'pesticide': 3000,
                    'labor': 12000, 'irrigation': 4000, 'misc': 2500
                },
                'yield_per_hectare': 4.0,
                'market_price_per_kg': 21,

                'rotation': [
                    'Wheat → Rice → Pulses',
                    'Wheat → Maize → Mustard'
                ],

                'fertilizers': [
                    'Urea: 100 kg/hectare (50kg at sowing + 50kg at CRI stage)',
                    'DAP: 100 kg/hectare (Full dose at sowing)',
                    'Potash (MOP): 30 kg/hectare (At sowing)',
                    'Zinc Sulphate: 25 kg/hectare (If leaves show yellowing)'
                ],

                'pesticides': [
                    'For Aphids: Imidacloprid 17.8% SL @ 0.5ml/liter',
                    'For Termites: Chlorpyrifos 20% EC @ 4 liter/hectare',
                    'For Rust: Propiconazole 25% EC @ 1ml/liter',
                    'For Loose Smut: Seed treatment with Vitavax @ 2.5g/kg'
                ],

                'key_steps': [
                    'Land Preparation: Deep plowing, apply FYM 5-10 tons/hectare',
                    'Seed Selection: Use certified seeds, 100kg/hectare',
                    'Sowing Time: November 1-20 (timely sowing crucial)',
                    'Sowing Method: Line sowing, 20cm row spacing, 5cm depth',
                    'First Irrigation: 20-25 days after sowing (CRI stage)',
                    'Subsequent Irrigation: Tillering, jointing, flowering stages',
                    'Harvesting: When grains are hard, moisture 20-25%'
                ],

                'tips': [
                    'Timely sowing crucial - delay reduces yield by 1% per week',
                    'Zero-till technology saves water and increases profit',
                    'Avoid over-irrigation to prevent lodging',
                    'Use Happy Seeder to manage crop residue'
                ]
            },

            'Cotton': {
                'duration': '150-180 days',
                'water_req': 'Moderate-High (700-1300mm)',
                'soil_ph': '6.0-8.0',
                'temperature': '25-35°C',
                'suitable_soil': ['black', 'loamy', 'alluvial'],
                'suitable_season': ['summer', 'monsoon'],
                'water_need': ['medium', 'high'],

                'costs': {
                    'seed': 4000, 'fertilizer': 10000, 'pesticide': 12000,
                    'labor': 20000, 'irrigation': 8000, 'misc': 5000
                },
                'yield_per_hectare': 2.75,
                'market_price_per_kg': 65,

                'rotation': [
                    'Cotton → Wheat → Green Gram',
                    'Cotton → Chickpea → Maize'
                ],

                'fertilizers': [
                    'Urea: 130 kg/hectare (Split in 3 doses)',
                    'DAP: 125 kg/hectare (Full dose at sowing)',
                    'Potash (MOP): 60 kg/hectare (Split in 2 doses)',
                    'Micronutrients: Foliar spray 19:19:19 @ 5g/liter'
                ],

                'pesticides': [
                    'For Pink Bollworm: Thiodicarb 75% WP @ 1.25g/liter',
                    'For Whitefly: Thiamethoxam 25% WG @ 0.3g/liter',
                    'For Aphids: Acetamiprid 20% SP @ 0.2g/liter',
                    'For Wilt: Carbendazim 12% + Mancozeb 63% WP @ 2g/liter'
                ],

                'key_steps': [
                    'Pre-Sowing: Deep summer plowing, apply FYM 10-12 tons',
                    'Seed Treatment: Imidacloprid 48% FS @ 7ml/kg',
                    'Sowing: April-May, spacing 90x45cm or 67.5x30cm',
                    'Thinning: Remove weak plants 15-20 days after sowing',
                    'Weed Management: 2-3 hand weeding',
                    'Picking: Start when 50% bolls open, 3-4 pickings total'
                ],

                'tips': [
                    'Plant Bt cotton varieties for bollworm resistance',
                    'Install yellow sticky traps @ 10/acre for whitefly',
                    'Drip irrigation saves 40-50% water',
                    'Leave 15cm stalk for easy removal'
                ]
            },

            'Tomato': {
                'duration': '70-90 days',
                'water_req': 'Moderate (600-800mm)',
                'soil_ph': '6.0-7.0',
                'temperature': '20-30°C',
                'suitable_soil': ['loamy', 'sandy', 'red'],
                'suitable_season': ['winter', 'summer'],
                'water_need': ['medium', 'high'],

                'costs': {
                    'seed': 5000, 'fertilizer': 12000, 'pesticide': 8000,
                    'labor': 25000, 'irrigation': 5000, 'misc': 4000
                },
                'yield_per_hectare': 30,
                'market_price_per_kg': 15,

                'rotation': [
                    'Tomato → Onion → Cabbage',
                    'Tomato → Cauliflower → Cucumber'
                ],

                'fertilizers': [
                    'FYM: 25-30 tons/hectare (15 days before planting)',
                    'Urea: 220 kg/hectare (Split in 4 doses)',
                    'DAP: 350 kg/hectare (Basal dose)',
                    'Potash (MOP): 170 kg/hectare (Split in 2 doses)'
                ],

                'pesticides': [
                    'For Early Blight: Mancozeb 75% WP @ 2.5g/liter',
                    'For Late Blight: Metalaxyl 8% + Mancozeb 64%',
                    'For Fruit Borer: Emamectin Benzoate 5% SG @ 0.5g/liter',
                    'For Whitefly: Diafenthiuron 50% WP @ 1g/liter'
                ],

                'key_steps': [
                    'Nursery Raising: 25-30 days for transplanting',
                    'Land Preparation: Raised beds 15cm high, 60cm wide',
                    'Transplanting: Evening time, spacing 60x45cm',
                    'Staking: Install within 15 days',
                    'Mulching: Black plastic mulch to control weeds',
                    'Harvesting: Pick when fruits fully colored but firm'
                ],

                'tips': [
                    'Use drip irrigation with fertigation for 30-40% higher yield',
                    'Mulching reduces water requirement by 30%',
                    'Remove diseased plants immediately',
                    'Hybrid varieties give 25-30% more yield'
                ]
            },

            'Maize': {
                'duration': '90-110 days',
                'water_req': 'Moderate (500-800mm)',
                'soil_ph': '5.5-7.5',
                'temperature': '18-32°C',
                'suitable_soil': ['loamy', 'sandy', 'alluvial'],
                'suitable_season': ['monsoon', 'winter'],
                'water_need': ['medium'],

                'costs': {
                    'seed': 3500, 'fertilizer': 8000, 'pesticide': 4000,
                    'labor': 10000, 'irrigation': 4500, 'misc': 2000
                },
                'yield_per_hectare': 6,
                'market_price_per_kg': 18,

                'rotation': [
                    'Maize → Wheat → Green Gram',
                    'Maize → Mustard → Potato'
                ],

                'fertilizers': [
                    'Urea: 240 kg/hectare (Split in 3 doses)',
                    'DAP: 120 kg/hectare (Full dose at sowing)',
                    'Potash (MOP): 60 kg/hectare (At sowing)',
                    'Zinc Sulphate: 25 kg/hectare (If white bud observed)'
                ],

                'pesticides': [
                    'For Stem Borer: Carbofuran 3% CG @ 33kg/hectare',
                    'For Fall Armyworm: Emamectin Benzoate @ 0.5g/liter',
                    'For Aphids: Imidacloprid 17.8% SL @ 0.3ml/liter',
                    'For Blight: Mancozeb 75% WP @ 2.5g/liter'
                ],

                'key_steps': [
                    'Seed Treatment: Thiram @ 3g/kg',
                    'Sowing: June-July, spacing 60x20cm, 2 seeds/hill',
                    'Thinning: Remove weak seedlings at 15-20 days',
                    'Earthing Up: At knee-high stage',
                    'Weed Control: Critical first 30-40 days',
                    'Harvesting: When husk turns brown, moisture 25-30%'
                ],

                'tips': [
                    'Inter-cropping with legumes improves soil nitrogen',
                    'Use composite varieties for normal farming',
                    'Crop rotation reduces fertilizer cost by 20-25%',
                    'Baby corn gives quicker returns (50-60 days)'
                ]
            },

            'Groundnut': {
                'duration': '100-120 days',
                'water_req': 'Low-Moderate (500-600mm)',
                'soil_ph': '6.0-7.0',
                'temperature': '25-30°C',
                'suitable_soil': ['sandy', 'loamy', 'red'],
                'suitable_season': ['summer', 'monsoon'],
                'water_need': ['low', 'medium'],

                'costs': {
                    'seed': 6000, 'fertilizer': 5000, 'pesticide': 4000,
                    'labor': 12000, 'irrigation': 3000, 'misc': 2500
                },
                'yield_per_hectare': 2.25,
                'market_price_per_kg': 55,

                'rotation': [
                    'Groundnut → Wheat → Maize',
                    'Groundnut → Mustard → Green Gram'
                ],

                'fertilizers': [
                    'DAP: 100 kg/hectare (Full dose at sowing)',
                    'Potash (MOP): 50 kg/hectare (At sowing)',
                    'Gypsum: 400 kg/hectare (At flowering - crucial)',
                    'Rhizobium culture: Seed treatment for N-fixation'
                ],

                'pesticides': [
                    'For Leaf Miner: Monocrotophos 36% SL @ 1.5ml/liter',
                    'For Aphids: Dimethoate 30% EC @ 2ml/liter',
                    'For Tikka Disease: Carbendazim 50% WP @ 1g/liter',
                    'For Collar Rot: Captan @ 3g/kg seed treatment'
                ],

                'key_steps': [
                    'Seed Treatment: Thiram 75% WS @ 3g/kg + Rhizobium',
                    'Sowing: June-July, spacing 30x10cm, depth 5cm',
                    'Weeding: Critical first 45 days',
                    'Gypsum Application: 45-50 days during flowering',
                    'Irrigation: Critical at flowering and pod development',
                    'Harvesting: When leaves turn yellow, 70-80% pods mature'
                ],

                'tips': [
                    'Groundnut fixes nitrogen - saves fertilizer cost',
                    'Gypsum application crucial for pod filling',
                    'Avoid water stress during flowering',
                    'Sun-dry pods for 3-4 days before storage'
                ]
            },

            'Potato': {
                'duration': '90-120 days',
                'water_req': 'Moderate (500-700mm)',
                'soil_ph': '5.5-6.5',
                'temperature': '15-25°C',
                'suitable_soil': ['loamy', 'sandy'],
                'suitable_season': ['winter'],
                'water_need': ['medium', 'high'],

                'costs': {
                    'seed': 35000, 'fertilizer': 15000, 'pesticide': 10000,
                    'labor': 30000, 'irrigation': 6000, 'misc': 5000
                },
                'yield_per_hectare': 25,
                'market_price_per_kg': 12,

                'rotation': [
                    'Potato → Maize → Mustard',
                    'Potato → Onion → Cabbage'
                ],

                'fertilizers': [
                    'FYM: 20-25 tons/hectare (15 days before planting)',
                    'Urea: 180 kg/hectare (Split dose)',
                    'DAP: 300 kg/hectare (Basal)',
                    'Potash (MOP): 150 kg/hectare (For tuber quality)'
                ],

                'pesticides': [
                    'For Late Blight: Mancozeb 75% WP @ 2.5g/liter',
                    'For Aphids: Imidacloprid 17.8% SL @ 0.5ml/liter',
                    'For Cutworm: Chlorpyrifos 20% EC @ 2.5ml/liter',
                    'For Tuber Rot: Seed treatment with Mancozeb'
                ],

                'key_steps': [
                    'Seed Selection: Certified disease-free tubers, 25-50g',
                    'Seed Treatment: Mancozeb @ 2.5g/kg, dry in shade',
                    'Planting: October-November, spacing 60x20cm',
                    'Earthing Up: 30 days after planting - critical',
                    'Haulm Cutting: 10 days before harvest',
                    'Harvesting: When haulm dries, avoid tuber damage'
                ],

                'tips': [
                    'Late blight biggest threat - start preventive spray early',
                    'Hill up soil properly - exposed tubers turn green',
                    'Use drip irrigation for better quality',
                    'Cold storage essential for off-season selling'
                ]
            }
        }

    def print_banner(self):
        """Display welcome banner"""
        print("\nCrop Recommendation\n")

    def run(self):
        """Run the crop recommendation agent"""
        self.print_banner()

    def get_input(self, prompt, options=None):
        """Get user input with validation"""
        while True:
            print(f"\n{prompt}")
            if options:
                for i, option in enumerate(options, 1):
                    print(f"  {i}. {option}")
                choice = input(
                    f"\nEnter your choice (1-{len(options)}): ").strip()
                try:
                    idx = int(choice) - 1
                    if 0 <= idx < len(options):
                        return options[idx].split(' (')[0].split(': ')[-1].lower()
                    print("Invalid choice! Please try again.")
                except ValueError:
                    print("Please enter a number!")
            else:
                value = input("Enter value: ").strip()
                if value:
                    return value
                print("This field cannot be empty!")

    def collect_soil_data(self):
        """Collect soil information"""
        print("\n📊 STEP 1: SOIL ANALYSIS")

        print("Let's analyze your soil conditions...")

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

        print("\n✓ Soil data collected successfully!")

    def collect_water_data(self):
        """Collect water availability information"""
        print("\n💧 STEP 2: WATER RESOURCES")

        print("Now let's understand your water availability...")

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

        print("\n✓ Water data collected successfully!")

    def collect_climate_data(self):
        """Collect climate and farm information"""
        print("\n🌡️ STEP 3: CLIMATE & FARM DETAILS")

        print("Almost there! Just need some climate info...")

        self.farmer_data['location'] = self.get_input(
            "Enter your location/state (e.g., Punjab, Maharashtra):"
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
            "Enter your land size in acres:"
        )

        try:
            self.farmer_data['land_size'] = float(
                self.farmer_data['land_size'])
        except ValueError:
            print("Invalid land size, using default 5 acres")
            self.farmer_data['land_size'] = 5.0

        print("\n✓ All data collected successfully!")

    def analyze_and_recommend(self):
        """AI logic to recommend crop"""
        print("\n🤖 AI ANALYSIS IN PROGRESS...\n")

        print("Analyzing soil composition...")
        print("Evaluating water availability...")
        print("Checking climate conditions...")
        print("Computing optimal crop match...")

        # AI recommendation logic
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
            recommended_crops = [('Wheat', 0)]

        recommended_crops.sort(key=lambda x: x[1], reverse=True)

        return recommended_crops[0][0], [c[0] for c in recommended_crops[1:3]]

    def display_recommendation(self, primary_crop, alternative_crops):
        """Display comprehensive recommendation"""
        crop = self.crop_database[primary_crop]

        print("\n✅ RECOMMENDATION READY!\n")

        # Primary Recommendation
        print(f"🌾 RECOMMENDED CROP: {primary_crop.upper()}")
        if alternative_crops:
            print(f"Alternative Options: {', '.join(alternative_crops)}")

        print("\nQuick Overview:")
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
        print(
            f"\n💰 FINANCIAL PROJECTION ({self.farmer_data['land_size']} acres)")

        # Convert to hectare (1 hectare = 2.47 acres)
        acre_conversion = self.farmer_data['land_size'] / 2.47

        costs = crop['costs']
        total_cost = sum(costs.values()) * acre_conversion

        print("\nCost Breakdown:")
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
        print(
            f"  Total Estimated Cost: ₹{int(total_cost):>10,}")

        yield_per_hectare = crop['yield_per_hectare'] * 1000  # tons to kg
        total_yield = yield_per_hectare * acre_conversion

        market_price = crop['market_price_per_kg']
        total_revenue = total_yield * market_price

        profit = total_revenue - total_cost

        print("\nRevenue Projection:")
        print(
            f"  Expected Yield:   {int(total_yield):>10,} kg")
        print(
            f"  Market Price:     ₹{market_price:>10,}/kg")
        print(f"  {'-'*40}")
        print(
            f"  Total Revenue:      ₹{int(total_revenue):>10,}")

        print(f"\nProjected Profit: ₹{int(profit):,}")

    def display_crop_rotation(self, crop):
        """Display crop rotation suggestions"""
        print("\n🔄 CROP ROTATION PLAN")
        print("Crop rotation improves soil health and reduces pests.")
        for i, rotation in enumerate(crop['rotation'], 1):
            print(f"  Option {i}: {rotation}")

    def display_fertilizers(self, crop):
        """Display fertilizer schedule"""
        print("\n🌱 FERTILIZER SCHEDULE")
        print("Apply these fertilizers for optimal growth:")
        for fertilizer in crop['fertilizers']:
            print(f"  - {fertilizer}")

    def display_pesticides(self, crop):
        """Display pest management plan"""
        print("\n🐞 PEST MANAGEMENT")
        print("Protect your crop from common pests:")
        for pesticide in crop['pesticides']:
            print(f"  - {pesticide}")

    def display_growing_guide(self, crop):
        """Display key steps for growing"""
        print("\n📖 STEP-BY-STEP GROWING GUIDE")
        for i, step in enumerate(crop['key_steps'], 1):
            print(
                f"  {i}. {step.split(':')[0]}: {step.split(':')[1].strip()}")

    def display_expert_tips(self, crop):
        """Display pro tips"""
        print("\n💡 EXPERT TIPS FOR HIGHER YIELD")
        for tip in crop['tips']:
            print(f"  ⭐ {tip}")
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
