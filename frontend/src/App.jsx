import { BrowserRouter as Router, Routes, Route, Link, useLocation } from 'react-router-dom';
import { Rocket, LayoutDashboard, Database, Building2, Info } from 'lucide-react';
import Dashboard from './pages/Dashboard';
import Startups from './pages/Startups';
import StartupDetail from './pages/StartupDetail';

function Navigation() {
  const location = useLocation();

  const navItems = [
    { path: '/', label: 'Dashboard', icon: LayoutDashboard },
    { path: '/startups', label: 'Startups', icon: Building2 },
  ];

  return (
    <nav style={{ width: '250px', backgroundColor: 'var(--bg-secondary)', borderRight: '1px solid var(--accent-card-border)', padding: '2rem 1.5rem', display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '3rem' }}>
        <div style={{ background: 'var(--accent-gradient)', padding: '0.5rem', borderRadius: 'var(--radius-md)' }}>
          <Rocket color="#fff" size={24} />
        </div>
        <h2 style={{ fontSize: '1.25rem' }}>Funding<span className="text-gradient">DB</span></h2>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path || (item.path !== '/' && location.pathname.startsWith(item.path));
          return (
            <Link key={item.path} to={item.path} className={`nav-link ${isActive ? 'active' : ''}`}>
              <Icon size={20} />
              {item.label}
            </Link>
          );
        })}
      </div>

      <div style={{ marginTop: 'auto', padding: '1.5rem', background: 'var(--bg-card)', borderRadius: 'var(--radius-lg)', border: '1px solid var(--accent-card-border)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
          <Database size={16} color="var(--accent-success)" />
          <h4 style={{ fontSize: '0.9rem' }}>MySQL Connected</h4>
        </div>
        <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Using fully normalized schema (3NF) containing 1,100+ funding rounds.</p>
      </div>
    </nav>
  );
}

function App() {
  return (
    <Router>
      <div className="app-container">
        <Navigation />
        <main className="main-content">
          <header style={{ marginBottom: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1 className="text-gradient" style={{ fontSize: '2rem', marginBottom: '0.25rem' }}>Indian Startup Intelligence</h1>
              <p style={{ color: 'var(--text-muted)' }}>Analyzing investment trends from 2020 to 2025</p>
            </div>
            
            <div className="glass-card" style={{ padding: '0.5rem 1rem', display: 'flex', alignItems: 'center', gap: '0.5rem', borderRadius: '999px' }}>
               <Info size={16} color="var(--accent-primary)" />
               <span style={{ fontSize: '0.85rem', fontWeight: 500 }}>Build with React & Node.js</span>
            </div>
          </header>

          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/startups" element={<Startups />} />
            <Route path="/startups/:id" element={<StartupDetail />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
