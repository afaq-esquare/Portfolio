from app.home import blueprint
from flask import render_template, redirect, url_for, request, jsonify
from flask_login import login_required, current_user
from app import login_manager
from jinja2 import TemplateNotFound
from functions.Heart_Prediction_Model import LogisticRegressionModel
from sklearn.preprocessing import LabelEncoder
from PIL import Image
import pytesseract
import torch
import numpy as np
import torch
import joblib
from firebase_admin import db
from firebase_admin import firestore
from firebase_admin import credentials
import firebase_admin
import random

cred = credentials.Certificate("service_accont.json") 
firebase_admin.initialize_app(cred)
db = firestore.client()


label_encoders = joblib.load('label_encoders.pkl')  

input_dim = 11  
model = LogisticRegressionModel(input_dim)
model.load_state_dict(torch.load('model.pkl'))
model.eval()
scaler = joblib.load('scaler.pkl')

@blueprint.route('/index', methods=['GET'])
@login_required
def index():
    user_collection = db.collection('user_details')
    query = user_collection.order_by('timestamp', direction=firestore.Query.DESCENDING).limit(1)
    documents = query.stream()

    latest_user_data = None

    for doc in documents:
        latest_user_data = doc.to_dict()
        print("Latest User Data: %s", latest_user_data) 

    return render_template('index.html', latest_user_data=latest_user_data)

@blueprint.route('/heart')
def heart():
    return render_template('heartprediction.html')

@blueprint.route('/image', methods=['GET', 'POST'])
def image():
    if request.method == 'POST':
        if 'image' not in request.files:
            return render_template('image.html', uploaded_image=uploaded_image, extraction_result="Error: No image uploaded.")

        image = request.files['image']

        image_path = "uploads/user_image.jpg"
        image.save(image_path)

        print(f"Image uploaded: {image_path}")

        uploaded_image = url_for('static', filename='uploads/user_image.jpg')

        extracted_text = extract_text_from_image(image_path)

        return render_template('image_text.html', extraction_result=extracted_text)

    return render_template('image.html', extraction_result=None)

def extract_text_from_image(image_path):
    img = Image.open(image_path)
    extracted_text = pytesseract.image_to_string(img)
    print('Extraxted text is : ', extracted_text)
    return extracted_text

def process_extracted_text(extracted_text):
    lines = extracted_text.split('\n')

    age = sex = chestpain_type = resting_bp = cholesterol = fasting_bp = resting_ecg = max_hr = exercise_angina = old_peak = st_slope = None

    for line in lines:
        if "Age:" in line:
            age = line.split(':')[-1].strip()
        elif "Sex type:" in line:
            sex = line.split(':')[-1].strip()
        elif "Chest Pain:" in line:
            chestpain_type = line.split(':')[-1].strip()
        elif "Resting Bp:" in line:
            resting_bp = line.split(':')[-1].strip()
        elif "Cholesterol:" in line:
            cholesterol = line.split(':')[-1].strip()
        elif "Feasting Bp:" in line:
            fasting_bp = line.split(':')[-1].strip()
        elif "Resting ECG:" in line:
            resting_ecg = line.split(':')[-1].strip()
        elif "Max HR:" in line:
            max_hr = line.split(':')[-1].strip()
        elif "Exercise Angina:" in line:
            exercise_angina = line.split(':')[-1].strip()
        elif "Old Peak:" in line:
            old_peak = line.split(':')[-1].strip()
        elif "St Slope:" in line:
            st_slope = line.split(':')[-1].strip()

    return {
        'age': age,
        'sex': sex,
        'chestpain_type': chestpain_type,
        'resting_bp': resting_bp,
        'cholesterol': cholesterol,
        'fasting_bp': fasting_bp,
        'resting_ecg': resting_ecg,
        'max_hr': max_hr,
        'exercise_angina': exercise_angina,
        'old_peak': old_peak,
        'st_slope': st_slope
    }

image_path = "uploads/user_image.jpg"
extracted_text = extract_text_from_image(image_path)
extracted_values = process_extracted_text(extracted_text)
print(extracted_values)


@blueprint.route('/predict', methods=['POST'])
def predict():
    if request.method == 'POST':
        age = float(request.form['age'])
        sex_encoded = label_encoders['Sex'].transform([request.form['sex']])
        chestpain_type_encoded = label_encoders['ChestPainType'].transform([request.form['chestpain_type']])
        resting_bp = float(request.form['resting_bp'])
        cholesterol = float(request.form['cholesterol'])
        fasting_bp_encoded = label_encoders['FastingBS'].transform([request.form['fasting_bp']])
        resting_ecg_encoded = label_encoders['RestingECG'].transform([request.form['resting_ecg']])
        max_hr = float(request.form['max_hr'])
        exercise_angina_encoded = label_encoders['ExerciseAngina'].transform([request.form['exercise_angina']])
        old_peak = float(request.form['old_peak'])
        st_slope_encoded = label_encoders['ST_Slope'].transform([request.form['st_slope']])

        input_data = [
            age,
            sex_encoded[0],
            chestpain_type_encoded[0],
            resting_bp,
            cholesterol,
            fasting_bp_encoded[0],
            resting_ecg_encoded[0],
            max_hr,
            exercise_angina_encoded[0],
            old_peak,
            st_slope_encoded[0]
        ]

        user_input = np.array(input_data).reshape(1, -1)
        scaled_input = scaler.transform(user_input)

        input_tensor = torch.tensor(scaled_input, dtype=torch.float32)
        with torch.no_grad():
            prediction = model(input_tensor).item()

        threshold = 0.5

        if prediction >= threshold:
            prediction_label = "Positive"
        else:
            prediction_label = "Negative"

        user_data = {
            "age": age,
            "sex": request.form['sex'],
            # "chestpain_type": chestpain_type,

            "chestpain_type": request.form['chestpain_type'],
            "resting_bp": resting_bp,
            "cholesterol": cholesterol,
            "fasting_bp": request.form['fasting_bp'],
            "resting_ecg": request.form['resting_ecg'],
            "max_hr": max_hr,
            "exercise_angina": request.form['exercise_angina'],
            "old_peak": old_peak,
            "st_slope": request.form['st_slope'],
            "timestamp": firestore.SERVER_TIMESTAMP
        }

        user_collection = db.collection('user_details')

        new_user_ref = user_collection.add(user_data)

        document_ref = new_user_ref[1]

        user_id = document_ref.id


        recommendations = {
            "Positive": [
                "You have a higher risk of heart disease. It's important to consult a healthcare professional for further evaluation and follow their advice.",
                "Don't smoke or use tobacco. Chemicals in tobacco can damage the heart and blood vessels.",
                "Get moving: Aim for at least 30 to 60 minutes of activity daily. Regular, daily physical activity can lower the risk of heart disease. Physical activity helps control your weight.",
                "Get quality sleep. People who don't get enough sleep have a higher risk of obesity, high blood pressure, heart attack, diabetes and depression.",
                "Get regular health screening tests. High blood pressure and high cholesterol can damage the heart and blood vessels.",
                "Monitor your blood pressure and cholesterol levels regularly.",
                "Schedule regular check-ups and consultations with a healthcare provider. Follow medical advice and treatment plans diligently.",
                "Consume a balanced diet rich in fruits, vegetables, whole grains, and lean proteins. Limit intake of saturated fats, trans fats, and sodium.",
                "Engage in moderate-intensity aerobic exercise for at least 150 minutes per week. Incorporate strength training exercises 2-3 times per week.",
                "Practice stress-reducing techniques such as meditation, deep breathing, or yoga. Establish a healthy work-life balance.",
                "If you smoke, seek support to quit smoking. Avoid exposure to secondhand smoke.",
                "Consume alcohol in moderation, Limit to one drink per day. Limit to two drinks per day.",
                "Achieve and maintain a healthy body weight. Consult with a healthcare professional for weight management guidance.",
                "Regularly check and manage blood pressure. Follow prescribed medications and lifestyle modifications.",
                "Control blood sugar levels through medication, diet, and exercise. Attend regular diabetes check-ups.",
                "Moderate caffeine consumption. Be mindful of caffeine sources, including coffee, tea, and energy drinks.",
                "Aim for 7-9 hours of quality sleep per night. Establish a consistent sleep schedule.",
                "Drink an adequate amount of water throughout the day. Limit sugary and high-calorie beverages.",
                "Reduce intake of processed and packaged foods. Choose fresh, whole foods whenever possible.",
                "Monitor and manage cholesterol levels. Limit intake of high-cholesterol foods.",
                "Undergo regular screenings for heart-related risk factors. Include lipid profiles, EKGs, and other relevant tests.",
                "Foster positive social connections and relationships. Stay connected with friends and family.",
                "Practice mindful eating by paying attention to hunger and fullness cues. Avoid emotional eating.",
                "Limit consumption of red and processed meats. Choose lean protein sources such as poultry, fish, and legumes."
            ],
            "Negative": [
                "Your risk of heart disease is relatively low, but it's still essential to maintain a healthy lifestyle and regular check-ups to prevent future risks.",
                "A balanced diet and regular exercise can help maintain your heart health.",
                "Don't forget to manage stress and get enough sleep for overall well-being.",
                "Avoid smoking and excessive alcohol consumption for a healthier heart.",
                "Stay hydrated and consume plenty of fruits and vegetables for good heart health.",
                "Regularly check your family history for heart disease to stay proactive about your health.",
                "Engage in regular physical activity for at least 150 minutes per week. Include a mix of aerobic and strength-training exercises.",
                "Consume a balanced diet rich in fruits, vegetables, whole grains, and lean proteins. Limit processed and high-fat foods.",
                "Drink plenty of water throughout the day to stay well-hydrated.",
                "Aim for 7-9 hours of quality sleep per night. Maintain a consistent sleep schedule.",
                "Practice stress-reducing techniques, such as meditation or deep breathing. Maintain a healthy work-life balance.",
                "Schedule regular health check-ups and screenings. Monitor blood pressure, cholesterol, and other relevant indicators.",
                "Avoid smoking and exposure to secondhand smoke. Seek support to quit smoking if needed.",
                "Maintain a healthy body weight through a balanced diet and regular exercise.",
                "Practice good oral hygiene. Schedule regular dental check-ups.",
                "Foster positive relationships with friends and family. Stay socially connected.",
                "Minimize intake of processed and packaged foods. Choose whole, nutrient-dense foods.",
                "Stay informed about overall health and wellness through reputable sources.",
                "Consume caffeine in moderation. Be mindful of caffeine sources and intake.",
                "Protect the skin from excessive sun exposure. Use sunscreen and wear protective clothing.",
                "Schedule regular eye exams. Follow eye health recommendations.",
                "Manage financial stress and plan for long-term financial well-being.",
                "Enjoy outdoor activities for physical and mental well-being. Incorporate nature walks, hiking, or biking.",
                "Be mindful of sodium intake by avoiding high-salt foods. Use herbs and spices for flavor."
            ],
        }

        recommendation = random.sample(recommendations[prediction_label], 5)

        return render_template('prediction.html', prediction=prediction_label, recommendation=recommendation)


@blueprint.route('/predict_from_image', methods=['POST'])
def predict_from_image():
    if request.method == 'POST':
        extracted_text = extract_text_from_image("uploads/user_image.jpg")
        processed_values = process_extracted_text(extracted_text)

        age = float(processed_values['age'])
        sex_encoded = label_encoders['Sex'].transform([processed_values['sex']])
        chestpain_type_encoded = label_encoders['ChestPainType'].transform([processed_values['chestpain_type']])
        resting_bp = float(processed_values['resting_bp'])
        cholesterol = float(processed_values['cholesterol'])
        fasting_bp_encoded = label_encoders['FastingBS'].transform([processed_values['fasting_bp']])
        resting_ecg_encoded = label_encoders['RestingECG'].transform([processed_values['resting_ecg']])
        max_hr = float(processed_values['max_hr'])
        exercise_angina_encoded = label_encoders['ExerciseAngina'].transform([processed_values['exercise_angina']])
        old_peak = float(processed_values['old_peak'])
        st_slope_encoded = label_encoders['ST_Slope'].transform([processed_values['st_slope']])

        input_data = [
            age,
            sex_encoded[0],
            chestpain_type_encoded[0],
            resting_bp,
            cholesterol,
            fasting_bp_encoded[0],
            resting_ecg_encoded[0],
            max_hr,
            exercise_angina_encoded[0],
            old_peak,
            st_slope_encoded[0]
        ]

        user_input = np.array(input_data).reshape(1, -1)
        scaled_input = scaler.transform(user_input)

        input_tensor = torch.tensor(scaled_input, dtype=torch.float32)
        with torch.no_grad():
            prediction = model(input_tensor).item()

        threshold = 0.5

        if prediction >= threshold:
            prediction_label = "Positive"
        else:
            prediction_label = "Negative"

        recommendations = {
            "Positive": [
                "You have a higher risk of heart disease. It's important to consult a healthcare professional for further evaluation and follow their advice.",
                "Don't smoke or use tobacco. Chemicals in tobacco can damage the heart and blood vessels.",
                "Get moving: Aim for at least 30 to 60 minutes of activity daily. Regular, daily physical activity can lower the risk of heart disease. Physical activity helps control your weight.",
                "Get quality sleep. People who don't get enough sleep have a higher risk of obesity, high blood pressure, heart attack, diabetes and depression.",
                "Get regular health screening tests. High blood pressure and high cholesterol can damage the heart and blood vessels.",
                "Monitor your blood pressure and cholesterol levels regularly."

            ],
            "Positive": [
                "Schedule regular check-ups and consultations with a healthcare provider. Follow medical advice and treatment plans diligently.",
                "Consume a balanced diet rich in fruits, vegetables, whole grains, and lean proteins. Limit intake of saturated fats, trans fats, and sodium.",
                "Engage in moderate-intensity aerobic exercise for at least 150 minutes per week. Incorporate strength training exercises 2-3 times per week.",
                "Practice stress-reducing techniques such as meditation, deep breathing, or yoga. Establish a healthy work-life balance.",
                "If you smoke, seek support to quit smoking. Avoid exposure to secondhand smoke.",
                "Consume alcohol in moderation, Limit to one drink per day. Limit to two drinks per day."

            ],
            "Positive": [
                "Achieve and maintain a healthy body weight. Consult with a healthcare professional for weight management guidance.",
                "Regularly check and manage blood pressure. Follow prescribed medications and lifestyle modifications.",
                "Control blood sugar levels through medication, diet, and exercise. Attend regular diabetes check-ups.",
                "Moderate caffeine consumption. Be mindful of caffeine sources, including coffee, tea, and energy drinks.",
                "Aim for 7-9 hours of quality sleep per night. Establish a consistent sleep schedule.",
                "Drink an adequate amount of water throughout the day. Limit sugary and high-calorie beverages."

            ],
            "Positive": [
                "Reduce intake of processed and packaged foods. Choose fresh, whole foods whenever possible.",
                "Monitor and manage cholesterol levels. Limit intake of high-cholesterol foods.",
                "Undergo regular screenings for heart-related risk factors. Include lipid profiles, EKGs, and other relevant tests.",
                "Foster positive social connections and relationships. Stay connected with friends and family.",
                "Practice mindful eating by paying attention to hunger and fullness cues. Avoid emotional eating.",
                "Limit consumption of red and processed meats. Choose lean protein sources such as poultry, fish, and legumes."

            ],
            "Negative": [
                "Your risk of heart disease is relatively low, but it's still essential to maintain a healthy lifestyle and regular check-ups to prevent future risks.",
                "A balanced diet and regular exercise can help maintain your heart health.",
                "Don't forget to manage stress and get enough sleep for overall well-being.",
                "Avoid smoking and excessive alcohol consumption for a healthier heart.",
                "Stay hydrated and consume plenty of fruits and vegetables for good heart health.",
                "Regularly check your family history for heart disease to stay proactive about your health."
            ],
            "Negative": [
                "Engage in regular physical activity for at least 150 minutes per week. Include a mix of aerobic and strength-training exercises.",
                "Consume a balanced diet rich in fruits, vegetables, whole grains, and lean proteins. Limit processed and high-fat foods.",
                "Drink plenty of water throughout the day to stay well-hydrated.",
                "Aim for 7-9 hours of quality sleep per night. Maintain a consistent sleep schedule.",
                "Practice stress-reducing techniques, such as meditation or deep breathing. Maintain a healthy work-life balance.",
                "Schedule regular health check-ups and screenings. Monitor blood pressure, cholesterol, and other relevant indicators."
            ],
            "Negative": [
                "Avoid smoking and exposure to secondhand smoke. Seek support to quit smoking if needed.",
                "Maintain a healthy body weight through a balanced diet and regular exercise.",
                "Practice good oral hygiene. Schedule regular dental check-ups.",
                "Foster positive relationships with friends and family. Stay socially connected.",
                "Minimize intake of processed and packaged foods. Choose whole, nutrient-dense foods.",
                "Stay informed about overall health and wellness through reputable sources."
            ],
            "Negative": [
                "Consume caffeine in moderation. Be mindful of caffeine sources and intake.",
                "Protect the skin from excessive sun exposure. Use sunscreen and wear protective clothing.",
                "Schedule regular eye exams. Follow eye health recommendations.",
                "Manage financial stress and plan for long-term financial well-being.",
                "Enjoy outdoor activities for physical and mental well-being. Incorporate nature walks, hiking, or biking.",
                "Be mindful of sodium intake by avoiding high-salt foods. Use herbs and spices for flavor."
            ]
        }

        # positive_recommendations = recommendations["Positive"]
        # negative_recommendations = recommendations["Negative"]

        # if prediction_label == "Positive":
        #     recommendation = random.choice(positive_recommendations)
        # else:
        #     recommendation = random.choice(negative_recommendations)

        recommendation = recommendations[prediction_label]

        return render_template('image_prediction.html', prediction=prediction_label, recommendation=recommendation)

@blueprint.route('/table')
def show_table():
    users_ref = db.collection('user_details')
    user_details = users_ref.stream() 

    data = []
    for user in user_details:
        data.append(user.to_dict())
    
    print("User details : ", data)

    return render_template('table.html', data=data)



@blueprint.route('/<template>')
def route_template(template):

    if not current_user.is_authenticated:
        return redirect(url_for('base_blueprint.login'))

    try:

        return render_template(template + '.html')

    except TemplateNotFound:
        return render_template('page-404.html'), 404
    
    except:
        return render_template('page-500.html'), 500
