from database.db import db

class PestAlert(db.Model):
    __tablename__ = 'pest_alerts'
    id = db.Column(db.Integer, primary_key=True)
    crop = db.Column(db.String(100))
    risk_level = db.Column(db.String(50), nullable=False)
    pest_name = db.Column(db.String(100), nullable=False)
    recommended_action = db.Column(db.Text)
