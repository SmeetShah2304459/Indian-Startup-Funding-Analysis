const API_URL = 'http://localhost:5001/api';

export const fetchStats = async () => {
  const res = await fetch(`${API_URL}/stats`);
  if (!res.ok) throw new Error('Network response was not ok');
  return res.json();
};

export const fetchStartups = async (page = 1, limit = 20) => {
  const res = await fetch(`${API_URL}/startups?page=${page}&limit=${limit}`);
  if (!res.ok) throw new Error('Network response was not ok');
  return res.json();
};

export const fetchStartupDetails = async (id) => {
  const res = await fetch(`${API_URL}/startups/${id}`);
  if (!res.ok) throw new Error('Network response was not ok');
  return res.json();
};

export const fetchFundingTrends = async () => {
  const res = await fetch(`${API_URL}/funding/trends`);
  if (!res.ok) throw new Error('Network response was not ok');
  return res.json();
};

export const fetchTopCities = async () => {
  const res = await fetch(`${API_URL}/leaderboard/cities`);
  if (!res.ok) throw new Error('Network response was not ok');
  return res.json();
};

export const fetchTopIndustries = async () => {
  const res = await fetch(`${API_URL}/leaderboard/industries`);
  if (!res.ok) throw new Error('Network response was not ok');
  return res.json();
};
