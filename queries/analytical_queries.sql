-- ============================================================
-- FILE: analytical_queries.sql
-- PROJECT: Indian Startup Funding Intelligence System
-- DESCRIPTION:
--   Intermediate to advanced queries for data analysis.
--   These are the kind of queries that impress in a portfolio!
-- ============================================================

USE StartupFundingDB;

-- ============================================================
-- QUERY 1: TOP 10 MOST FUNDED STARTUPS
-- Shows which startups raised the most money overall
-- ============================================================
SELECT
    s.startup_name                      AS "Startup",
    c.city_name                         AS "City",
    i.industry_name                     AS "Industry",
    COUNT(fr.round_id)                  AS "Total Rounds",
    SUM(fr.amount_usd)                  AS "Total Raised (USD)",
    ROUND(AVG(fr.amount_usd), 0)        AS "Avg Round Size (USD)"
FROM FundingRound fr
JOIN Startup s      ON fr.startup_id  = s.startup_id
JOIN City c         ON s.city_id      = c.city_id
JOIN Industry i     ON s.industry_id  = i.industry_id
GROUP BY s.startup_name, c.city_name, i.industry_name
ORDER BY SUM(fr.amount_usd) DESC
LIMIT 10;

-- ============================================================
-- QUERY 2: CITY-WISE FUNDING LEADERBOARD
-- Which city attracted the most investor money?
-- ============================================================
SELECT
    c.city_name                         AS "City",
    COUNT(DISTINCT s.startup_id)        AS "No. of Startups",
    COUNT(fr.round_id)                  AS "Total Rounds",
    SUM(fr.amount_usd)                  AS "Total Funding (USD)",
    ROUND(AVG(fr.amount_usd), 0)        AS "Avg Deal Size (USD)"
FROM FundingRound fr
JOIN Startup s ON fr.startup_id = s.startup_id
JOIN City c    ON s.city_id     = c.city_id
GROUP BY c.city_name
ORDER BY SUM(fr.amount_usd) DESC;

-- ============================================================
-- QUERY 3: YEAR-WISE FUNDING TREND (2020 to 2025)
-- How did startup funding change each year?
-- YEAR() extracts the year from a date column
-- ============================================================
SELECT
    YEAR(fr.funding_date)               AS "Year",
    COUNT(fr.round_id)                  AS "Number of Rounds",
    SUM(fr.amount_usd)                  AS "Total Funding (USD)",
    ROUND(AVG(fr.amount_usd), 0)        AS "Avg Deal Size (USD)"
FROM FundingRound fr
WHERE fr.funding_date IS NOT NULL
GROUP BY YEAR(fr.funding_date)
ORDER BY Year ASC;

-- ============================================================
-- QUERY 4: INDUSTRY-WISE FUNDING ANALYSIS
-- Which sectors attracted the most investment?
-- ============================================================
SELECT
    i.industry_name                     AS "Industry",
    COUNT(DISTINCT s.startup_id)        AS "No. of Startups",
    COUNT(fr.round_id)                  AS "Total Rounds",
    SUM(fr.amount_usd)                  AS "Total Funding (USD)"
FROM FundingRound fr
JOIN Startup s  ON fr.startup_id  = s.startup_id
JOIN Industry i ON s.industry_id  = i.industry_id
GROUP BY i.industry_name
ORDER BY SUM(fr.amount_usd) DESC;

-- ============================================================
-- QUERY 5: AVERAGE DEAL SIZE PER INVESTMENT STAGE
-- Seed rounds are small, Series D rounds are huge — let's prove it!
-- ============================================================
SELECT
    it.type_name                        AS "Investment Stage",
    COUNT(fr.round_id)                  AS "Number of Rounds",
    ROUND(AVG(fr.amount_usd), 0)        AS "Avg Amount (USD)",
    MAX(fr.amount_usd)                  AS "Largest Round (USD)",
    MIN(fr.amount_usd)                  AS "Smallest Round (USD)"
FROM FundingRound fr
JOIN InvestmentType it ON fr.investment_type_id = it.investment_type_id
GROUP BY it.type_name
ORDER BY AVG(fr.amount_usd) DESC;

-- ============================================================
-- QUERY 6: TOP INVESTORS BY NUMBER OF ROUNDS PARTICIPATED
-- Who are the most active investors?
-- ============================================================
SELECT
    inv.investor_name                   AS "Investor",
    COUNT(ri.round_id)                  AS "Rounds Participated"
FROM RoundInvestor ri
JOIN Investor inv ON ri.investor_id = inv.investor_id
GROUP BY inv.investor_name
ORDER BY COUNT(ri.round_id) DESC
LIMIT 15;

-- ============================================================
-- QUERY 7: WHICH INVESTORS PREFER WHICH INDUSTRY?
-- Great for showing JOINs across 4 tables
-- ============================================================
SELECT
    inv.investor_name                   AS "Investor",
    i.industry_name                     AS "Preferred Industry",
    COUNT(ri.round_id)                  AS "Deals in this Industry"
FROM RoundInvestor ri
JOIN Investor inv    ON ri.investor_id  = inv.investor_id
JOIN FundingRound fr ON ri.round_id     = fr.round_id
JOIN Startup s       ON fr.startup_id   = s.startup_id
JOIN Industry i      ON s.industry_id   = i.industry_id
GROUP BY inv.investor_name, i.industry_name
ORDER BY inv.investor_name, COUNT(ri.round_id) DESC;

-- ============================================================
-- QUERY 8: HOTTEST SECTORS IN 2024 AND 2025
-- Recent investment trends — what is hot right now?
-- ============================================================
SELECT
    i.industry_name                     AS "Industry",
    COUNT(fr.round_id)                  AS "Deals in 2024-2025",
    SUM(fr.amount_usd)                  AS "Total Funding (USD)"
FROM FundingRound fr
JOIN Startup s  ON fr.startup_id  = s.startup_id
JOIN Industry i ON s.industry_id  = i.industry_id
WHERE YEAR(fr.funding_date) IN (2024, 2025)
GROUP BY i.industry_name
ORDER BY COUNT(fr.round_id) DESC;

-- ============================================================
-- QUERY 9: STARTUPS WITH MULTIPLE FUNDING ROUNDS
-- Which startups kept coming back for more funding?
-- HAVING is like WHERE but used after GROUP BY
-- ============================================================
SELECT
    s.startup_name                      AS "Startup",
    i.industry_name                     AS "Industry",
    COUNT(fr.round_id)                  AS "Number of Rounds"
FROM FundingRound fr
JOIN Startup s  ON fr.startup_id  = s.startup_id
JOIN Industry i ON s.industry_id  = i.industry_id
GROUP BY s.startup_name, i.industry_name
HAVING COUNT(fr.round_id) > 3
ORDER BY COUNT(fr.round_id) DESC;

-- ============================================================
-- QUERY 10: LARGEST SINGLE FUNDING ROUNDS EVER
-- The biggest deals in our dataset
-- ============================================================
SELECT
    s.startup_name                      AS "Startup",
    it.type_name                        AS "Stage",
    fr.amount_usd                       AS "Amount (USD)",
    fr.funding_date                     AS "Date"
FROM FundingRound fr
JOIN Startup s         ON fr.startup_id         = s.startup_id
JOIN InvestmentType it ON fr.investment_type_id  = it.investment_type_id
ORDER BY fr.amount_usd DESC
LIMIT 10;

-- ============================================================
-- QUERY 11: COMPARE BENGALURU VS MUMBAI FUNDING
-- Direct city comparison using WHERE with IN
-- ============================================================
SELECT
    c.city_name                         AS "City",
    COUNT(fr.round_id)                  AS "Total Rounds",
    SUM(fr.amount_usd)                  AS "Total Funding (USD)"
FROM FundingRound fr
JOIN Startup s ON fr.startup_id = s.startup_id
JOIN City c    ON s.city_id     = c.city_id
WHERE c.city_name IN ('Bengaluru', 'Mumbai')
GROUP BY c.city_name;

-- ============================================================
-- QUERY 12: SUBQUERY EXAMPLE — Startups that raised MORE than
--           the average funding amount
-- ============================================================
SELECT
    s.startup_name                      AS "Startup",
    SUM(fr.amount_usd)                  AS "Total Raised (USD)"
FROM FundingRound fr
JOIN Startup s ON fr.startup_id = s.startup_id
GROUP BY s.startup_name
HAVING SUM(fr.amount_usd) > (
    -- This inner query calculates the overall average
    SELECT AVG(total)
    FROM (
        SELECT SUM(amount_usd) AS total
        FROM FundingRound
        GROUP BY startup_id
    ) AS avg_table
)
ORDER BY SUM(fr.amount_usd) DESC;
