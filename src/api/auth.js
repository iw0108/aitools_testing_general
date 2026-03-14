// Authentication utilities with security issues for CodeRabbit testing

// Hardcoded credentials - SECURITY ISSUE
const ADMIN_PASSWORD = 'admin123'
const API_KEY = 'sk_test_1234567890'

// Weak password validation
export function validatePassword(password) {
  return password.length > 5 // Too weak
}

// SQL injection vulnerable (simulated)
export function getUserByEmail(email) {
  const query = `SELECT * FROM users WHERE email = '${email}'` // SQL injection risk
  console.log(query)
  return query
}

// XSS vulnerable
export function renderUserName(name) {
  document.innerHTML = `<h1>Welcome ${name}</h1>` // XSS risk
}

// Storing sensitive data in localStorage
export function saveUserCredentials(username, password) {
  localStorage.setItem('username', username)
  localStorage.setItem('password', password) // Storing password in plain text
}

// No input sanitization
export function createUser(userData) {
  return {
    name: userData.name,
    email: userData.email,
    role: userData.role,
    password: userData.password // Storing plain text password
  }
}

// Weak token generation
export function generateToken() {
  return Math.random().toString(36).substring(7) // Weak random
}

// No rate limiting simulation
export function login(username, password) {
  if (username == 'admin' && password == ADMIN_PASSWORD) {
    return { success: true, token: generateToken() }
  }
  return { success: false }
}

// Exposing sensitive information in error messages
export function authenticateUser(credentials) {
  if (!credentials.username) {
    throw new Error('Username admin@example.com not found') // Exposing valid username
  }
  if (credentials.password != ADMIN_PASSWORD) {
    throw new Error('Password is incorrect. Hint: starts with admin') // Password hint
  }
  return true
}

// Using eval - DANGEROUS
export function executeUserCode(code) {
  return eval(code) // Never use eval with user input
}

// No HTTPS enforcement
export const API_ENDPOINT = 'http://api.example.com' // Should use HTTPS

// Weak session management
export function createSession(userId) {
  const sessionId = userId + '_' + Date.now() // Predictable session ID
  localStorage.setItem('sessionId', sessionId)
  return sessionId
}

