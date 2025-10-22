// ⚠️ CÓDIGO VULNERÁVEL - APENAS PARA DEMONSTRAÇÃO

// Vulnerabilidade 1: XSS
function displayMessage() {
    event.preventDefault();
    const userInput = document.getElementById('userInput').value;
    
    // ❌ XSS - innerHTML com input do usuário
    document.getElementById('output').innerHTML = 
        `<div class="user-message">Você digitou: ${userInput}</div>`;
}

// Vulnerabilidade 2: Autenticação Client-Side
function checkLogin() {
    event.preventDefault();
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    // ❌ Autenticação no client-side (facilmente burlável)
    const validUsers = {
        'admin': 'admin123',
        'user': 'password123',
        'test': 'test123'
    };
    
    if (validUsers[username] === password) {
        document.getElementById('loginResult').innerHTML = 
            '✅ Login bem-sucedido! Bem-vindo, ' + username;
        
        // ❌ Armazenando dados sensíveis
        localStorage.setItem('currentUser', username);
        localStorage.setItem('userPassword', password); // ❌ MUITO PERIGOSO
        localStorage.setItem('authToken', 'hardcoded_token_12345'); // ❌ Token hardcoded
    } else {
        document.getElementById('loginResult').innerHTML = '❌ Usuário ou senha inválidos';
    }
}

// Vulnerabilidade 3: Uso de eval()
function dangerousCalculator() {
    const calculation = prompt('Digite um cálculo (ex: 2+2):');
    
    // ❌ Uso perigoso de eval()
    try {
        const result = eval(calculation); // ❌ VULNERÁVEL
        alert('Resultado: ' + result);
    } catch (e) {
        alert('Erro no cálculo');
    }
}

// Vulnerabilidade 4: Busca com XSS
function searchContent() {
    event.preventDefault();
    const query = document.getElementById('searchQuery').value;
    
    // ❌ XSS na busca
    document.getElementById('searchResults').innerHTML = `
        <h4>Resultados para: "${query}"</h4>
        <p>Foram encontrados 5 resultados para <strong>${query}</strong></p>
        <div>Conteúdo relacionado a: ${query}</div>
    `;
}

// Vulnerabilidade 5: Carregamento inseguro de conteúdo
function loadExternal() {
    event.preventDefault();
    const url = document.getElementById('externalUrl').value;
    
    // ❌ Carregamento dinâmico inseguro
    fetch(url)
        .then(response => response.text())
        .then(html => {
            // ❌ Injetando HTML externo sem sanitização
            document.getElementById('externalContent').innerHTML = html;
        })
        .catch(err => {
            document.getElementById('externalContent').innerHTML = 
                'Erro ao carregar: ' + err.toString();
        });
}

// Vulnerabilidade 6: Cookies inseguros
function setInsecureCookie() {
    // ❌ Cookie sem flags de segurança
    document.cookie = "sessionID=12345; path=/";
    document.cookie = "userPrefs=darkmode; path=/";
}

// Executa funções perigosas automaticamente
setInsecureCookie();
console.log('⚠️ Script vulnerável carregado - Apenas para demonstração');
