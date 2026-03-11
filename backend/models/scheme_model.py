from database.db import db

class Scheme(db.Model):
    __tablename__ = 'schemes'
    id = db.Column(db.Integer, primary_key=True)
    scheme_name = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    benefit = db.Column(db.String(255))
    link = db.Column(db.String(255))
    category = db.Column(db.String(100))
