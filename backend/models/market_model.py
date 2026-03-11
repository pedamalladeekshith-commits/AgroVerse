from database.db import db
from datetime import datetime

class MarketPrice(db.Model):
    __tablename__ = 'market_prices'
    id = db.Column(db.Integer, primary_key=True)
    commodity = db.Column(db.String(100), nullable=False)
    market = db.Column(db.String(100), nullable=False)
    district = db.Column(db.String(100))
    state = db.Column(db.String(100))
    modal_price = db.Column(db.Integer, nullable=False)
    date = db.Column(db.DateTime, default=datetime.utcnow)
