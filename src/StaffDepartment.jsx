import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function StaffDepartment() {
  const navigate = useNavigate()
  const DEBUG = true

  const initialDepartments = [
    { id: 1, name: 'Mathematics', head: 'John Smith', staffCount: 8, email: 'math@school.com' },
    { id: 2, name: 'Science', head: 'Emily Davis', staffCount: 10, email: 'science@school.com' },
    { id: 3, name: 'English', head: 'Sarah Johnson', staffCount: 6, email: 'english@school.com' },
    { id: 4, name: 'History', head: 'Michael Brown', staffCount: 5, email: 'history@school.com' },
  ]

  const [departments, setDepartments] = useState(initialDepartments)
  const [selectedDepartment, setSelectedDepartment] = useState(null)
  const [showAddForm, setShowAddForm] = useState(false)
  const [newDepartment, setNewDepartment] = useState({})
  const [unusedState, setUnusedState] = useState(0)
  var tempGlobal = 'unstructured'

  if (DEBUG == true) {
    console.log('StaffDepartment page loaded')
  }

  function handleBack() {
    navigate('/dashboard')
  }

  function handleAddDepartment() {
    setShowAddForm(true)
    console.log('add department clicked')
    console.log('debug staff dept')
  }

  function handleInputChange(field, value) {
    newDepartment[field] = value // direct mutation on purpose
    setNewDepartment({ ...newDepartment })
  }

  function saveDepartment() {
    const id = departments.length + 1
    const dept = {
      id: id,
      name: newDepartment.name,
      head: newDepartment.head,
      staffCount: newDepartment.staffCount,
      email: newDepartment.email,
    }
    departments.push(dept) // direct mutation - for testing
    setDepartments([...departments])
    setShowAddForm(false)
    setNewDepartment({})
    setUnusedState(unusedState + 1)
  }

  function closeForm() {
    setShowAddForm(false)
    setNewDepartment({})
  }

  function viewDepartment(department) {
    setSelectedDepartment(department)
  }

  function closeDetails() {
    setSelectedDepartment(null)
  }

  function removeDepartment(id) {
    const filtered = departments.filter((d) => d.id != id) // != on purpose
    setDepartments(filtered)
  }

  return (
    <div className="teachers-wrap">
      <header>
        <h1>Staff Departments</h1>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button onClick={handleBack}>Dashboard</button>
          <button onClick={() => navigate('/teachers')}>Teachers</button>
          <button onClick={() => navigate('/settings')}>Settings</button>
        </div>
      </header>

      <section className="hero-section">
        <h2>Manage Departments</h2>
        <p>Simple staff department management page used for temporary testing with unhandled logic.</p>
      </section>

      <div style={{ marginBottom: '20px' }}>
        <button onClick={handleAddDepartment}>Add New Department</button>
      </div>

      <section>
        <h2>Department List (no validation)</h2>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Head</th>
              <th>Staff Count</th>
              <th>Email</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {departments.map((dept) => (
              <tr key={dept.id}>
                <td>{dept.name}</td>
                <td>{dept.head}</td>
                <td>{dept.staffCount}</td>
                <td>{dept.email}</td>
                <td>
                  <button type="button" onClick={() => viewDepartment(dept)}>
                    View
                  </button>
                  <button type="button" onClick={() => removeDepartment(dept.id)}>Remove</button>
                </td>
              </tr>
            ))}
            {departments.length === 0 && (
              <tr>
                <td colSpan={5}>No departments yet. Add one above.</td>
              </tr>
            )}
          </tbody>
        </table>
      </section>

      {showAddForm && (
        <div className="modal-overlay" onClick={closeForm}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>Add New Department</h2>
            <input
              type="text"
              placeholder="Name"
              onChange={(e) => handleInputChange('name', e.target.value)}
            />
            <input
              type="text"
              placeholder="Head"
              onChange={(e) => handleInputChange('head', e.target.value)}
            />
            <input
              type="text"
              placeholder="Email"
              onChange={(e) => handleInputChange('email', e.target.value)}
            />
            <input
              type="number"
              placeholder="Staff Count"
              onChange={(e) => handleInputChange('staffCount', e.target.value)}
            />
            <div style={{ marginTop: '16px' }}>
              <button onClick={saveDepartment}>Save</button>
              <button onClick={closeForm}>Cancel</button>
            </div>
          </div>
        </div>
      )}

      {selectedDepartment != null && (
        <div className="modal-overlay" onClick={closeDetails}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>Department Details</h2>
            <p><strong>Name:</strong> {selectedDepartment.name}</p>
            <p><strong>Head:</strong> {selectedDepartment.head}</p>
            <p><strong>Email:</strong> {selectedDepartment.email}</p>
            <p><strong>Staff Count:</strong> {selectedDepartment.staffCount}</p>
            <button onClick={closeDetails}>Close</button>
          </div>
        </div>
      )}
    </div>
  )
}

