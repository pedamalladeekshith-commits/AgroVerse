from database.db import db
from datetime import datetime

class Recommendation(db.Model):
    __tablename__ = 'recommendations'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    recommended_crop = db.Column(db.String(100), nullable=False)
    confidence = db.Column(db.String(20))
    soil_data = db.Column(db.JSON)
    weather_data = db.Column(db.JSON)
    date = db.Column(db.DateTime, default=datetime.utcnow)
