import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Search, ChevronRight } from 'lucide-react';
import { fetchStartups } from '../api';

const USD_TO_INR = 83;

function formatCurrency(usdValue) {
  if (!usdValue) return '-';
  const inrValue = usdValue * USD_TO_INR;
  if (inrValue >= 1e7) return `₹${(inrValue / 1e7).toFixed(2)} Cr`;
  if (inrValue >= 1e5) return `₹${(inrValue / 1e5).toFixed(2)} L`;
  return `₹${inrValue.toLocaleString('en-IN')}`;
}

export default function Startups() {
  const [startups, setStartups] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    async function loadData() {
      try {
        const data = await fetchStartups(1, 100); // Fetching 100 for simplicity
        setStartups(data.data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  const filteredStartups = startups.filter(s => 
    s.startup_name.toLowerCase().includes(search.toLowerCase()) || 
    (s.industry_name && s.industry_name.toLowerCase().includes(search.toLowerCase()))
  );

  return (
    <div className="animate-fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
        <h2 style={{ fontSize: '1.5rem' }}>All Startups</h2>
        
        <div style={{ position: 'relative', width: '300px' }}>
          <Search size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)' }} />
          <input 
            type="text" 
            placeholder="Search by name or industry..." 
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{ 
              width: '100%', 
              background: 'var(--bg-secondary)', 
              border: '1px solid var(--accent-card-border)', 
              color: '#fff', 
              padding: '0.75rem 1rem 0.75rem 2.5rem',
              borderRadius: '999px',
              outline: 'none',
              fontFamily: 'var(--font-body)'
            }} 
          />
        </div>
      </div>

      {loading ? (
        <div className="loader"></div>
      ) : (
        <div className="data-table-container glass-card" style={{ padding: 0, overflow: 'hidden' }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>Startup Name</th>
                <th>Industry</th>
                <th>Sub-Vertical</th>
                <th>City</th>
                <th>Total Funding</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredStartups.map(startup => (
                <tr key={startup.startup_id}>
                  <td style={{ fontWeight: 500, color: '#fff' }}>{startup.startup_name}</td>
                  <td><span className="pill">{startup.industry_name || 'N/A'}</span></td>
                  <td>{startup.sub_vertical_name || '-'}</td>
                  <td>{startup.city_name || '-'}</td>
                  <td style={{ fontWeight: 600 }}>{formatCurrency(startup.total_funding)}</td>
                  <td>
                    <Link to={`/startups/${startup.startup_id}`} style={{ color: 'var(--accent-primary)', display: 'flex', alignItems: 'center', gap: '0.25rem', textDecoration: 'none', fontWeight: 500 }}>
                      View <ChevronRight size={16} />
                    </Link>
                  </td>
                </tr>
              ))}
              {filteredStartups.length === 0 && (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                    No startups found matching your search.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
