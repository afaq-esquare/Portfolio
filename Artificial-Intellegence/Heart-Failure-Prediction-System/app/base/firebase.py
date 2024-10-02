from firebase_admin import firestore
from firebase_admin import credentials
import firebase_admin
from datetime import datetime
from flask import session

cred = credentials.Certificate("service_accont.json") 
firebase_admin.initialize_app(cred)

def get_db():
    database = firestore.client()

    return database

def insert_user(name, age, email):
    db = get_db()

    doc = db.collection('user').document()

    dictt = {
        "username":name,
        "age":age,
        "email":email,
        "id":doc.id
    }
    doc.set(dictt)

def get_data():

    db = get_db()
    docs = db.collection('user').stream()

    users = []
    for doc in docs:
        users.append(doc.to_dict())

    return users