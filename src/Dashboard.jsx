export default function Dashboard({ onLogout }) {
  const tableData = [
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User' },
    { id: 3, name: 'Bob Wilson', email: 'bob@example.com', role: 'User' },
    { id: 4, name: 'Alice Brown', email: 'alice@example.com', role: 'Editor' },
    { id: 5, name: 'Charlie Davis', email: 'charlie@example.com', role: 'User' },
    { id: 6, name: 'Eva Miller', email: 'eva@example.com', role: 'Admin' },
    { id: 7, name: 'Frank Lee', email: 'frank@example.com', role: 'User' },
  ]

  return (
    <div className="dashboard-wrap">
      <header>
        <h1>Dashboard</h1>
        <button onClick={onLogout}>Logout</button>
      </header>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
          </tr>
        </thead>
        <tbody>
          {tableData.map((row) => (
            <tr key={row.id}>
              <td>{row.id}</td>
              <td>{row.name}</td>
              <td>{row.email}</td>
              <td>{row.role}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
