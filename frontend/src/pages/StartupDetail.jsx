import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, MapPin, Building, Briefcase } from 'lucide-react';
import { fetchStartupDetails } from '../api';

const USD_TO_INR = 83;

function formatCurrency(usdValue) {
  if (!usdValue) return '-';
  const inrValue = usdValue * USD_TO_INR;
  if (inrValue >= 1e7) return `₹${(inrValue / 1e7).toFixed(2)} Cr`;
  if (inrValue >= 1e5) return `₹${(inrValue / 1e5).toFixed(2)} L`;
  return `₹${inrValue.toLocaleString('en-IN')}`;
}

function formatDate(dateString) {
  if (!dateString) return '-';
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  return new Date(dateString).toLocaleDateString(undefined, options);
}

export default function StartupDetail() {
  const { id } = useParams();
  const [startup, setStartup] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        const data = await fetchStartupDetails(id);
        setStartup(data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, [id]);

  if (loading) return <div className="loader"></div>;
  if (!startup) return <div style={{ textAlign: 'center', marginTop: '3rem' }}>Startup not found</div>;

  return (
    <div className="animate-fade-in">
      <Link to="/startups" style={{ display: 'inline-flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-muted)', textDecoration: 'none', marginBottom: '1.5rem' }}>
        <ArrowLeft size={16} /> Back to Startups
      </Link>

      <div className="glass-card" style={{ marginBottom: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="text-gradient" style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>{startup.startup_name}</h1>
          <div style={{ display: 'flex', gap: '1.5rem', color: 'var(--text-muted)' }}>
             <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><MapPin size={16} /> {startup.city_name || 'N/A'}</span>
             <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Briefcase size={16} /> {startup.industry_name || 'N/A'}</span>
             <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Building size={16} /> {startup.sub_vertical_name || 'N/A'}</span>
          </div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <p className="stat-card-label">Total Funding Raised</p>
          <h2 style={{ fontSize: '2.5rem', color: '#fff', fontFamily: 'var(--font-heading)' }}>{formatCurrency(startup.total_funding)}</h2>
        </div>
      </div>

      <h3 style={{ marginBottom: '1rem', fontSize: '1.25rem' }}>Funding Rounds History</h3>
      <div className="data-table-container glass-card" style={{ padding: 0, overflow: 'hidden' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Investment Stage</th>
              <th>Amount Raised</th>
              <th>Participating Investors</th>
            </tr>
          </thead>
          <tbody>
            {startup.funding_rounds && startup.funding_rounds.length > 0 ? (
              startup.funding_rounds.map((round) => (
                <tr key={round.round_id}>
                  <td>{formatDate(round.funding_date)}</td>
                  <td><span className="pill success">{round.type_name || 'Undisclosed'}</span></td>
                  <td style={{ fontWeight: 600, color: '#fff' }}>{formatCurrency(round.amount_usd)}</td>
                  <td style={{ color: 'var(--text-muted)', lineHeight: '1.6' }}>
                    {round.investors?.length > 0 ? round.investors.join(', ') : '-'}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="4" style={{ textAlign: 'center', padding: '2rem' }}>No funding rounds recorded.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

    </div>
  );
}
