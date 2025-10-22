from flask import Flask, request, render_template_string, make_response
import sqlite3
import subprocess
import pickle
import base64
import os

app = Flask(__name__)

# ❌ Senhas hardcoded
ADMIN_PASSWORD = "senha_super_secreta_123"
DATABASE_URL = "sqlite:///app.db"
SECRET_KEY = "chave_muito_secreta_456"

@app.route('/')
def index():
    return '''
    <h1>🚨 API Python Vulnerável</h1>
    <ul>
        <li><a href="/search?q=teste">Busca Vulnerável</a></li>
        <li><a href="/user/admin">Perfil de Usuário</a></li>
        <li><a href="/ping?host=google.com">Ping</a></li>
    </ul>
    '''

# ❌ Vulnerabilidade: SQL Injection
@app.route('/user/<username>')
def get_user(username):
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    
    # ❌ SQL INJECTION
    query = f"SELECT * FROM users WHERE username = '{username}'"
    cursor.execute(query)
    user = cursor.fetchone()
    
    return f'Usuário: {user}'

# ❌ Vulnerabilidade: XSS
@app.route('/search')
def search():
    query = request.args.get('q', '')
    
    # ❌ XSS
    template = f'''
    <h1>Resultados para: {query}</h1>
    <p>Você buscou por: <strong>{query}</strong></p>
    <a href="/">Voltar</a>
    '''
    return render_template_string(template)

# ❌ Vulnerabilidade: Command Injection
@app.route('/ping')
def ping():
    host = request.args.get('host', '127.0.0.1')
    
    # ❌ COMMAND INJECTION
    result = subprocess.run(f"ping -c 1 {host}", shell=True, capture_output=True, text=True)
    return f'<pre>Resultado: {result.stdout}</pre>'

# ❌ Vulnerabilidade: Deserialização Insegura
@app.route('/load')
def load_data():
    data = request.args.get('data', '')
    
    try:
        # ❌ DESERIALIZAÇÃO INSEGURA
        decoded = base64.b64decode(data)
        loaded = pickle.loads(decoded)
        return f'Dados carregados: {loaded}'
    except Exception as e:
        return f'Erro: {str(e)}'

if __name__ == '__main__':
    # ❌ Debug mode ativado
    app.run(debug=True, host='0.0.0.0', port=5000)
