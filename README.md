# AgroVerse

AgroVerse is a Flutter mobile app with a Flask backend for crop advisory, market insights, plant disease detection, soil prediction, schemes, farm logs, and community posts.

## Project Base

Use the `NEW` folder as the active app base.

## Backend Run

1. Create and activate a Python 3.10 environment.
2. Install dependencies:

```powershell
pip install -r requirements.txt
```

3. Start the API:

```powershell
gunicorn --chdir backend server:app --workers 1 --threads 1 --timeout 240
```

For local development, you can also run:

```powershell
python backend/server.py
```

The API health endpoint is:

```text
GET /health
```

## Backend Environment Variables

- `AGROVERSE_API_SECRET`
- `WEATHER_API_KEY`
- `MARKET_API_KEY`
- `PORT`

If you do not set the API secret, the app defaults to `myAgroversePrivateKey2026`.

## Flutter Run

Install packages:

```powershell
flutter pub get
```

Run locally against a local backend:

```powershell
flutter run --dart-define=AGROVERSE_API_BASE_URL=http://10.0.2.2:5000
```

Run against Render:

```powershell
flutter run --dart-define=AGROVERSE_API_BASE_URL=https://YOUR-RENDER-SERVICE.onrender.com
```

Current deployed backend:

```text
https://agroverse-1fed.onrender.com
```

If you change the backend secret, also pass:

```powershell
flutter run --dart-define=AGROVERSE_API_BASE_URL=https://YOUR-RENDER-SERVICE.onrender.com --dart-define=AGROVERSE_API_KEY=YOUR_SECRET
```

## Render Deployment

This repo includes:

- `Procfile`
- `render.yaml`

Recommended Render setup:

1. Create a new Web Service from this repo.
2. Confirm build command: `pip install -r requirements.txt`
3. Confirm start command: `gunicorn --chdir backend server:app --workers 1 --threads 1 --timeout 240`
4. Set environment variables for API keys and secret.

## Notes

- Login is local and does not require Firebase setup.
- Government schemes use a bundled fallback dataset so the app stays usable in deployment.
- The Flutter API base URL is deployment-safe and controlled with `--dart-define`.
