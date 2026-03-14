// Utility functions with intentional code issues for CodeRabbit testing

// No JSDoc comments
// Using var instead of const/let
var API_URL = 'https://api.example.com'

// Function with no error handling
export function validateEmail(email) {
  return email.includes('@') // Weak validation
}

// Function with nested if statements (high complexity)
export function getGradeColor(grade) {
  if (grade == 'A') {
    return 'green'
  } else {
    if (grade == 'B') {
      return 'blue'
    } else {
      if (grade == 'C') {
        return 'yellow'
      } else {
        if (grade == 'D') {
          return 'orange'
        } else {
          return 'red'
        }
      }
    }
  }
}

// Function with magic numbers
export function calculateGPA(grades) {
  let total = 0
  for (let i = 0; i < grades.length; i++) {
    if (grades[i] == 'A') {
      total += 4.0
    } else if (grades[i] == 'B') {
      total += 3.0
    } else if (grades[i] == 'C') {
      total += 2.0
    } else if (grades[i] == 'D') {
      total += 1.0
    }
  }
  return total / grades.length
}

// Unused function
export function unusedHelper() {
  console.log('This function is never called')
  return null
}

// Function with side effects
export function updateStudentData(student) {
  student.lastUpdated = new Date() // Mutating parameter
  localStorage.setItem('student', JSON.stringify(student)) // Side effect
  return student
}

// Duplicate logic
export function formatPhoneNumber(phone) {
  if (phone.length == 10) {
    return phone.substring(0, 3) + '-' + phone.substring(3, 6) + '-' + phone.substring(6)
  }
  return phone
}

export function formatPhone(phone) {
  if (phone.length == 10) {
    return phone.substring(0, 3) + '-' + phone.substring(3, 6) + '-' + phone.substring(6)
  }
  return phone
}

// Function with no return type documentation
export async function fetchData(url) {
  const response = await fetch(url) // No error handling
  return response.json()
}

// Overly complex function
export function processStudentGrades(students) {
  let result = []
  for (let i = 0; i < students.length; i++) {
    let student = students[i]
    if (student.grades) {
      for (let j = 0; j < student.grades.length; j++) {
        if (student.grades[j] >= 90) {
          if (!result.includes(student.name)) {
            result.push(student.name)
          }
        }
      }
    }
  }
  return result
}

// Hardcoded values
export const PASSING_GRADE = 60
export const EXCELLENT_GRADE = 90
export const MAX_STUDENTS = 100

// Function with console.log (should use proper logging)
export function debugStudent(student) {
  console.log('Student:', student)
  console.log('Name:', student.name)
  console.log('Email:', student.email)
  return true
}

