import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import db from './db.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// -----------------------------------------------------------------
// 1. GET /api/stats : Overall statistics from views
// -----------------------------------------------------------------
app.get('/api/stats', async (req, res) => {
  try {
    // Quick overall totals query
    const [totals] = await db.query(`
      SELECT 
        COUNT(DISTINCT startup_id) as totalStartups,
        COUNT(round_id) as totalFundingRounds,
        SUM(amount_usd) as totalFundingAmount
      FROM FundingRound
    `);
    
    // Top city
    const [topCity] = await db.query(`
      SELECT City, Total_Funding_USD 
      FROM v_CityFundingLeaderboard 
      ORDER BY Total_Funding_USD DESC LIMIT 1
    `);

    // Top industry
    const [topIndustry] = await db.query(`
      SELECT Industry, Total_Funding_USD 
      FROM v_IndustryFundingSummary 
      ORDER BY Total_Funding_USD DESC LIMIT 1
    `);

    res.json({
      totals: totals[0],
      topCity: topCity[0] || null,
      topIndustry: topIndustry[0] || null
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// -----------------------------------------------------------------
// 2. GET /api/startups : List of all startups with basic info
// -----------------------------------------------------------------
app.get('/api/startups', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    
    // Using simple query joining Startup tables, or summarizing directly
    const [rows] = await db.query(`
      SELECT 
        s.startup_id,
        s.startup_name,
        c.city_name,
        i.industry_name,
        sv.sub_vertical_name,
        (SELECT SUM(amount_usd) FROM FundingRound WHERE startup_id = s.startup_id) as total_funding
      FROM Startup s
      LEFT JOIN City c ON s.city_id = c.city_id
      LEFT JOIN Industry i ON s.industry_id = i.industry_id
      LEFT JOIN SubVertical sv ON s.sub_vertical_id = sv.sub_vertical_id
      ORDER BY total_funding DESC 
      LIMIT ? OFFSET ?
    `, [limit, offset]);
    
    const [countResult] = await db.query('SELECT COUNT(*) as total FROM Startup');
    const totalStartups = countResult[0].total;
    
    res.json({
      data: rows,
      pagination: {
        total: totalStartups,
        page,
        limit,
        totalPages: Math.ceil(totalStartups / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching startups:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// -----------------------------------------------------------------
// 3. GET /api/startups/:id : Details of a specific startup
// -----------------------------------------------------------------
app.get('/api/startups/:id', async (req, res) => {
  const { id } = req.params;
  try {
    // Basic startup info
    const [startupRows] = await db.query(`
      SELECT 
        s.startup_id, s.startup_name, c.city_name, i.industry_name, sv.sub_vertical_name
      FROM Startup s
      LEFT JOIN City c ON s.city_id = c.city_id
      LEFT JOIN Industry i ON s.industry_id = i.industry_id
      LEFT JOIN SubVertical sv ON s.sub_vertical_id = sv.sub_vertical_id
      WHERE s.startup_id = ?
    `, [id]);

    if (startupRows.length === 0) {
      return res.status(404).json({ error: 'Startup not found' });
    }
    
    const startup = startupRows[0];
    
    // Get its funding rounds
    const [roundsRows] = await db.query(`
      SELECT 
        fr.round_id, it.type_name, fr.amount_usd, fr.funding_date
      FROM FundingRound fr
      LEFT JOIN InvestmentType it ON fr.investment_type_id = it.investment_type_id
      WHERE fr.startup_id = ?
      ORDER BY fr.funding_date DESC
    `, [id]);
    
    // Get investors for each round
    for (const round of roundsRows) {
      const [investors] = await db.query(`
        SELECT inv.investor_name 
        FROM RoundInvestor ri
        JOIN Investor inv ON ri.investor_id = inv.investor_id
        WHERE ri.round_id = ?
      `, [round.round_id]);
      round.investors = investors.map(i => i.investor_name);
    }
    
    startup.funding_rounds = roundsRows;
    startup.total_funding = roundsRows.reduce((sum, r) => sum + (r.amount_usd || 0), 0);
    
    res.json(startup);
  } catch (error) {
    console.error('Error fetching startup details:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// -----------------------------------------------------------------
// 4. GET /api/funding/trends : Yearly trends
// -----------------------------------------------------------------
app.get('/api/funding/trends', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM v_YearlyFundingTrend ORDER BY Year');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching funding trends:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// -----------------------------------------------------------------
// 5. GET /api/leaderboard/cities : Top cities
// -----------------------------------------------------------------
app.get('/api/leaderboard/cities', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM v_CityFundingLeaderboard ORDER BY Total_Funding_USD DESC LIMIT 10');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching city leaderboard:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// -----------------------------------------------------------------
// 6. GET /api/leaderboard/industries : Top industries
// -----------------------------------------------------------------
app.get('/api/leaderboard/industries', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM v_IndustryFundingSummary ORDER BY Total_Funding_USD DESC LIMIT 10');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching industry leaderboard:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
