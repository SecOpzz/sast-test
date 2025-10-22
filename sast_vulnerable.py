#!/usr/bin/env python3
"""
CÓDIGO VULNERÁVEL PARA SAST - APENAS DEMONSTRAÇÃO
Vulnerabilidades para Static Application Security Testing
"""

import os
import pickle
import base64
import subprocess
import sqlite3
from flask import Flask, request, render_template_string, session
import hashlib
import jwt
import yaml

app = Flask(__name__)

# ❌ VULNERABILIDADE: Hardcoded Secrets
SECRET_KEY = "my_super_secret_key_123456"
DATABASE_PASSWORD = "admin123!"
API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"

# ❌ VULNERABILIDADE: Weak Crypto
def hash_password(password):
    return hashlib.md5(password.encode()).hexdigest()  # ❌ MD5 is broken

# ❌ VULNERABILIDADE: SQL Injection
def get_user_data(user_id):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    
    # ❌ SQL Injection direto
    query = f"SELECT * FROM users WHERE id = {user_id}"
    cursor.execute(query)
    return cursor.fetchall()

# ❌ VULNERABILIDADE: Command Injection
def execute_system_command(cmd):
    # ❌ Command Injection com shell=True
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout

# ❌ VULNERABILIDADE: Insecure Deserialization
def load_user_data(serialized_data):
    # ❌ Pickle sem validação
    return pickle.loads(base64.b64decode(serialized_data))

# ❌ VULNERABILIDADE: XSS
@app.route('/profile')
def user_profile():
    username = request.args.get('name', 'Guest')
    
    # ❌ XSS com template string
    template = f"""
    <h1>Perfil de {username}</h1>
    <div>Bem-vindo, {username}!</div>
    """
    return render_template_string(template)

# ❌ VULNERABILIDADE: Path Traversal
@app.route('/files')
def read_file():
    filename = request.args.get('file', '')
    
    # ❌ Path Traversal
    filepath = f"/home/user/files/{filename}"
    with open(filepath, 'r') as f:
        return f.read()

# ❌ VULNERABILIDADE: JWT Issues
def verify_jwt(token):
    # ❌ Algorithm confusion potential
    try:
        decoded = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return decoded
    except:
        return None

# ❌ VULNERABILIDADE: YAML Unsafe Load
def load_config(yaml_data):
    # ❌ YAML load inseguro
    return yaml.load(yaml_data)  # ❌ yaml.load instead of yaml.safe_load

# ❌ VULNERABILIDADE: Insecure Random
def generate_password():
    import random
    return str(random.randint(1000, 9999))  # ❌ Previsível

# ❌ VULNERABILIDADE: Logging Sensitive Data
def process_payment(card_number, amount):
    # ❌ Logging dados sensíveis
    print(f"Processing payment: {card_number} - ${amount}")
    return True

# ❌ VULNERABILIDADE: Mass Assignment
@app.route('/update_user', methods=['POST'])
def update_user():
    user_data = request.json
    # ❌ Atribuição em massa sem whitelist
    user = User(**user_data)
    user.save()
    return "User updated"

if __name__ == "__main__":
    # ❌ Debug em "produção"
    app.run(debug=True, host='0.0.0.0', port=5000, ssl_context='adhoc')
