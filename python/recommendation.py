import os
from datetime import datetime
import pandas as pd
import numpy as np
import joblib
import sys
import time
import json

# Add project root to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
try:
    from backend.weather_service import get_weather_data
    from backend.market_service import get_mandi_price
except ImportError:
    get_weather_data = get_mandi_price = None

class Colors:
    HEADER, BLUE, CYAN, GREEN, YELLOW, RED, BOLD, UNDERLINE, END = \
    '\033[95m', '\033[94m', '\033[96m', '\033[92m', '\033[93m', '\033[91m', '\033[1m', '\033[4m', '\033[0m'

class CropRecommendationAgent:
    def __init__(self):
        self.farmer_data = {}
        self.base_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        try:
            with open(os.path.join(self.base_path, 'crop_details.json'), 'r') as f: self.crop_db = json.load(f)
            sum_p = os.path.join(self.base_path, 'knowledge', 'district_yield_summary.json')
            self.hist_db = json.load(open(sum_p)) if os.path.exists(sum_p) else None
        except Exception: self.crop_db, self.hist_db = {}, None
        
        try: self.model = joblib.load(os.path.join(self.base_path, 'backend', 'models', 'crop_model.pkl'))
        except Exception: self.model = None

    def get_input(self, prompt, type_func=str, min_val=None, max_val=None, options=None):
        while True:
            print(f"\n{Colors.YELLOW}{prompt}{Colors.END}")
            if options:
                for i, opt in enumerate(options, 1): print(f"  {Colors.CYAN}{i}.{Colors.END} {opt}")
                val = input(f"{Colors.BOLD}Select (1-{len(options)}): {Colors.END}").strip()
            else: val = input(f"{Colors.BOLD}Enter value: {Colors.END}").strip()
            if not val: continue
            try:
                v = type_func(val)
                if options and not (1 <= v <= len(options)): continue
                if min_val is not None and v < min_val: continue
                if max_val is not None and v > max_val: continue
                return v
            except ValueError: print(f"{Colors.RED}Invalid!{Colors.END}")

    def collect_data(self):
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}\n      🌾 AGROVERSE AI SMART ADVISOR 🌾\n{'='*70}{Colors.END}")
        self.farmer_data['N'] = self.get_input("Nitrogen (N) level (0-140):", float, 0, 140)
        self.farmer_data['P'] = self.get_input("Phosphorus (P) level (5-145):", float, 5, 145)
        self.farmer_data['K'] = self.get_input("Potassium (K) level (5-205):", float, 5, 205)
        self.farmer_data['ph'] = self.get_input("Soil pH level (3-10):", float, 3, 10)
        
        print(f"\n{Colors.HEADER}{Colors.BOLD}🌡️ STEP 2: CLIMATE & LOCATION{Colors.END}")
        mode = self.get_input("Provide climate data via:", int, options=["Automatic (Weather API)", "Manual Entry"])
        
        if mode == 1:
            city = self.get_input("Enter City Name (e.g. Bangalore):")
            weather, _ = get_weather_data(city) if get_weather_data else (None, None)
            if weather:
                self.farmer_data.update(weather)
                print(f"\n{Colors.GREEN}✓ Live Weather Loaded for {weather['city']}: {weather['temperature']}°C{Colors.END}")
            else:
                print(f"{Colors.RED}API Failed. Switching to manual.{Colors.END}")
                self._manual_climate()
        else: self._manual_climate()
        
        self.farmer_data['land'] = self.get_input("Total Land Size (Acres):", float, 0.1)

    def _manual_climate(self):
        self.farmer_data['temperature'] = self.get_input("Temp (°C):", float, -10, 60)
        self.farmer_data['humidity'] = self.get_input("Humidity (%):", float, 0, 100)
        self.farmer_data['rainfall'] = self.get_input("Rainfall (mm):", float, 0, 1000)
        self.farmer_data['city'] = "Manual"

    def analyze(self):
        print(f"\n{Colors.HEADER}{Colors.BOLD}🤖 AI ANALYSIS IN PROGRESS...{Colors.END}")
        time.sleep(1)
        feats = pd.DataFrame([{
            'N': self.farmer_data['N'], 'P': self.farmer_data['P'], 'K': self.farmer_data['K'],
            'temperature': self.farmer_data['temperature'], 'humidity': self.farmer_data['humidity'],
            'ph': self.farmer_data['ph'], 'rainfall': self.farmer_data['rainfall']
        }])
        pred = self.model.predict(feats)[0].capitalize() if self.model else "Wheat"
        
        # 1. Prediction
        print(f"\n{Colors.GREEN}{Colors.BOLD}✅ AI RECOMMENDED CROP: {pred.upper()}{Colors.END}")
        
        # 2. Market Price
        price, _ = get_mandi_price(pred, self.farmer_data.get('region')) if get_mandi_price else (None, None)
        if price:
            print(f"\n{Colors.YELLOW}{Colors.BOLD}💰 LIVE MARKET DATA:{Colors.END}")
            print(f"  • Mandi Rate: ₹{price['modal_price']} / quintal (100kg)")
            crop_info = self.crop_db.get(pred, {})
            if 'yield_per_hectare' in crop_info:
                acre_conv = self.farmer_data['land'] / 2.47
                total_qtl = crop_info['yield_per_hectare'] * 10 * acre_conv
                revenue = total_qtl * price['modal_price']
                print(f"  • Estimated Revenue: {Colors.GREEN}₹{int(revenue):,}{Colors.END} ({self.farmer_data['land']} acres)")

        # 3. Regional History
        if self.hist_db and self.farmer_data.get('city'):
            dist = self.farmer_data['city'].upper().strip()
            d_data = self.hist_db['district_data'].get(dist)
            if d_data:
                mapped = self.hist_db['mapping'].get(pred.lower(), pred.lower())
                h_yield = d_data.get(mapped.lower())
                print(f"\n{Colors.BLUE}{Colors.BOLD}📜 REGIONAL HISTORY ({dist}):{Colors.END}")
                if h_yield: print(f"  • {pred} avg yield: {h_yield} t/h")
                print(f"  • Highest yielding crop here: {max(d_data, key=d_data.get).capitalize()}")

        # 4. Growing Guide
        info = self.crop_db.get(pred)
        if info:
            print(f"\n{Colors.BOLD}📖 QUICK FARMING GUIDE:{Colors.END}")
            print(f"  - Duration: {info.get('duration')} | Soil pH: {info.get('soil_ph')}")
            if 'tips' in info: print(f"\n{Colors.YELLOW}💡 TIP: {info['tips'][0]}{Colors.END}")

    def run(self):
        try:
            self.collect_data()
            self.analyze()
            print(f"\n{'Happy Farming!':^70}\n")
        except KeyboardInterrupt:
            print(f"\n\n{Colors.RED}>> Application interrupted by user. Goodbye!{Colors.END}\n")

if __name__ == "__main__":
    agent = CropRecommendationAgent()
    agent.run()
