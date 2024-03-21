from flask import Flask, request, jsonify
import numpy as np
import pickle
from flask_cors import CORS  # Import CORS extension

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes in the app

# Load models
try:
    dtr = pickle.load(open('dtr.pkl', 'rb'))
    preprocessor = pickle.load(open('preprocessor.pkl', 'rb'))
except FileNotFoundError:
    print("Error: Model files not found. Check file paths.")

@app.route('/predict', methods=['POST'])
def predict():
    if request.method == 'POST':
        try:
            data = request.json  # Receive JSON data from Flutter app
            print("Received data:", data)

            # Extract features from JSON data
            Year = data.get('Year')
            average_rain_fall_mm_per_year = data.get('average_rain_fall_mm_per_year')
            pesticides_tonnes = data.get('pesticides_tonnes')
            avg_temp = data.get('avg_temp')
            Area = data.get('Area')
            Item = data.get('Item')

            # Check for missing or incorrect data
            if None in [Year, average_rain_fall_mm_per_year, pesticides_tonnes, avg_temp, Area, Item]:
                return jsonify({'error': 'Missing or incorrect data fields'})

            # Prepare features for prediction
            features = np.array([[Year, average_rain_fall_mm_per_year, pesticides_tonnes, avg_temp, Area, Item]], dtype=object)
            transformed_features = preprocessor.transform(features)

            # Make prediction
            prediction = dtr.predict(transformed_features).tolist()

            # Return prediction as JSON response
            return jsonify({'prediction': prediction})
        except Exception as e:
            print("Error:", e)
            return jsonify({'error': 'An error occurred during prediction'})
    else:
        return jsonify({'error': 'Unsupported HTTP method'})

if __name__ == '__main__':
    app.run(debug=True)
