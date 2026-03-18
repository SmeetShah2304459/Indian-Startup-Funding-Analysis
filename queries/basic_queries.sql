-- ============================================================
-- FILE: basic_queries.sql
-- PROJECT: Indian Startup Funding Intelligence System
-- DESCRIPTION:
--   Easy, beginner-friendly queries to explore the data.
--   Each query has a comment explaining WHAT it does and HOW.
-- ============================================================

USE StartupFundingDB;

-- ============================================================
-- QUERY 1: See all cities in our database
-- Simple SELECT from a single table
-- ============================================================
SELECT * FROM City;

-- ============================================================
-- QUERY 2: See all industries
-- ============================================================
SELECT * FROM Industry;

-- ============================================================
-- QUERY 3: List all startups with their city name
-- We JOIN Startup and City tables using city_id
-- ============================================================
SELECT
    s.startup_name   AS "Startup",
    c.city_name      AS "City"
FROM Startup s
JOIN City c ON s.city_id = c.city_id
ORDER BY s.startup_name;

-- ============================================================
-- QUERY 4: List all startups with Industry and SubVertical
-- We JOIN 3 tables at once
-- ============================================================
SELECT
    s.startup_name        AS "Startup",
    i.industry_name       AS "Industry",
    sv.sub_vertical_name  AS "Sub Vertical"
FROM Startup s
JOIN Industry i    ON s.industry_id     = i.industry_id
JOIN SubVertical sv ON s.sub_vertical_id = sv.sub_vertical_id
ORDER BY i.industry_name, s.startup_name;

-- ============================================================
-- QUERY 5: See all funding rounds with Startup name and Amount
-- Joins FundingRound with Startup
-- ============================================================
SELECT
    s.startup_name          AS "Startup",
    it.type_name            AS "Investment Type",
    fr.amount_usd           AS "Amount (USD)",
    fr.funding_date         AS "Date"
FROM FundingRound fr
JOIN Startup s        ON fr.startup_id         = s.startup_id
JOIN InvestmentType it ON fr.investment_type_id = it.investment_type_id
ORDER BY fr.funding_date DESC
LIMIT 20;

-- ============================================================
-- QUERY 6: Which investors participated in a specific round?
-- Shows how our junction table (RoundInvestor) works
-- ============================================================
SELECT
    fr.round_id             AS "Round ID",
    s.startup_name          AS "Startup",
    i.investor_name         AS "Investor"
FROM RoundInvestor ri
JOIN FundingRound fr ON ri.round_id    = fr.round_id
JOIN Investor i      ON ri.investor_id = i.investor_id
JOIN Startup s       ON fr.startup_id  = s.startup_id
ORDER BY fr.round_id
LIMIT 30;

-- ============================================================
-- QUERY 7: Count how many funding rounds each startup has
-- GROUP BY groups all rounds belonging to the same startup
-- ============================================================
SELECT
    s.startup_name          AS "Startup",
    COUNT(fr.round_id)      AS "Number of Funding Rounds"
FROM FundingRound fr
JOIN Startup s ON fr.startup_id = s.startup_id
GROUP BY s.startup_name
ORDER BY COUNT(fr.round_id) DESC;

-- ============================================================
-- QUERY 8: Total money raised by each startup (in USD)
-- SUM adds up all amounts for each startup
-- ============================================================
SELECT
    s.startup_name          AS "Startup",
    SUM(fr.amount_usd)      AS "Total Raised (USD)"
FROM FundingRound fr
JOIN Startup s ON fr.startup_id = s.startup_id
GROUP BY s.startup_name
ORDER BY SUM(fr.amount_usd) DESC
LIMIT 10;

-- ============================================================
-- QUERY 9: How many startups are in each city?
-- ============================================================
SELECT
    c.city_name             AS "City",
    COUNT(s.startup_id)     AS "Number of Startups"
FROM Startup s
JOIN City c ON s.city_id = c.city_id
GROUP BY c.city_name
ORDER BY COUNT(s.startup_id) DESC;

-- ============================================================
-- QUERY 10: All funding rounds for a specific startup (e.g. Groww)
-- Change 'Groww' to any startup name you want
-- ============================================================
SELECT
    s.startup_name          AS "Startup",
    it.type_name            AS "Stage",
    fr.amount_usd           AS "Amount (USD)",
    fr.funding_date         AS "Date"
FROM FundingRound fr
JOIN Startup s         ON fr.startup_id         = s.startup_id
JOIN InvestmentType it ON fr.investment_type_id  = it.investment_type_id
WHERE s.startup_name = 'Groww'
ORDER BY fr.funding_date;
