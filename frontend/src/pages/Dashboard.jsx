import React, { useEffect, useState } from 'react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { IndianRupee, Building, TrendingUp, MapPin } from 'lucide-react';
import { fetchStats, fetchFundingTrends, fetchTopCities } from '../api';

const USD_TO_INR = 83;

function formatCurrency(usdValue) {
  if (!usdValue) return '₹0';
  const inrValue = usdValue * USD_TO_INR;
  if (inrValue >= 1e7) return `₹${(inrValue / 1e7).toFixed(2)} Cr`;
  if (inrValue >= 1e5) return `₹${(inrValue / 1e5).toFixed(2)} L`;
  return `₹${inrValue.toLocaleString('en-IN')}`;
}

const StatCard = ({ title, value, subtext, icon: Icon, color }) => (
  <div className="glass-card animate-fade-in">
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
      <div>
        <p className="stat-card-label">{title}</p>
        <h3 className="stat-card-value text-gradient">{value}</h3>
        {subtext && <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '0.5rem' }}>{subtext}</p>}
      </div>
      <div style={{ background: `rgba(${color}, 0.1)`, padding: '1rem', borderRadius: '1rem' }}>
        <Icon size={24} color={`rgb(${color})`} />
      </div>
    </div>
  </div>
);

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [trends, setTrends] = useState([]);
  const [cities, setCities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        const [statsData, trendsData, citiesData] = await Promise.all([
          fetchStats(),
          fetchFundingTrends(),
          fetchTopCities()
        ]);
        setStats(statsData);
        setTrends(trendsData);
        setCities(citiesData);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  if (loading) return <div className="loader"></div>;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      
      {/* Top Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.5rem' }}>
        <StatCard 
          title="Total Funding" 
          value={formatCurrency(stats?.totals?.totalFundingAmount)} 
          subtext="Total capital raised 2020-2025"
          icon={IndianRupee} 
          color="59, 130, 246" 
        />
        <StatCard 
          title="Total Startups" 
          value={stats?.totals?.totalStartups || 0} 
          subtext="Unique funded startups"
          icon={Building} 
          color="139, 92, 246" 
        />
        <StatCard 
          title="Top Industry" 
          value={stats?.topIndustry?.Industry || 'N/A'} 
          subtext={formatCurrency(stats?.topIndustry?.Total_Funding_USD)}
          icon={TrendingUp} 
          color="16, 185, 129" 
        />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1.5rem' }}>
        
        {/* Chart */}
        <div className="glass-card animate-fade-in" style={{ animationDelay: '0.1s' }}>
          <h3 style={{ marginBottom: '1.5rem' }}>Yearly Funding Trend</h3>
          <div style={{ height: '350px', width: '100%' }}>
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={trends} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorAmount" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#3B82F6" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" vertical={false} />
                <XAxis dataKey="Year" stroke="var(--text-muted)" tick={{fill: 'var(--text-muted)'}} axisLine={false} tickLine={false} />
                <YAxis tickFormatter={(val) => `₹${(val * 83 / 1e7).toFixed(0)}Cr`} stroke="var(--text-muted)" tick={{fill: 'var(--text-muted)'}} axisLine={false} tickLine={false} />
                <Tooltip 
                  contentStyle={{ backgroundColor: 'var(--bg-card)', borderColor: 'var(--accent-card-border)', borderRadius: '8px', color: '#fff' }}
                  itemStyle={{ color: '#fff' }}
                  formatter={(value) => [formatCurrency(value), 'Funding']}
                />
                <Area type="monotone" dataKey="Total_Funding_USD" stroke="#3B82F6" strokeWidth={3} fillOpacity={1} fill="url(#colorAmount)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Top Cities */}
        <div className="glass-card animate-fade-in" style={{ animationDelay: '0.2s' }}>
          <h3 style={{ marginBottom: '1.5rem' }}>Top Cities by Funding</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {cities.slice(0, 5).map((city, idx) => (
              <div key={city.City} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '1rem', borderBottom: idx !== 4 ? '1px solid var(--accent-card-border)' : 'none' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: 'rgba(255,255,255,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <MapPin size={16} color="var(--accent-secondary)" />
                  </div>
                  <div>
                    <h4 style={{ fontSize: '1rem', color: 'var(--text-main)' }}>{city.City}</h4>
                    <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{city.Total_Startups} Startups</p>
                  </div>
                </div>
                <div style={{ fontWeight: 600, color: '#fff' }}>
                  {formatCurrency(city.Total_Funding_USD)}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

    </div>
  );
}
