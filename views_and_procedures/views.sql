-- ============================================================
-- FILE: views.sql
-- PROJECT: Indian Startup Funding Intelligence System
-- DESCRIPTION:
--   A VIEW is like a saved query that acts as a virtual table.
--   Once created, you can SELECT from it just like a real table!
--   Views make complex queries easy to reuse.
-- ============================================================

USE StartupFundingDB;

-- ============================================================
-- VIEW 1: v_CityFundingLeaderboard
-- Shows total funding stats per city.
-- After creating, just run: SELECT * FROM v_CityFundingLeaderboard;
-- ============================================================
CREATE OR REPLACE VIEW v_CityFundingLeaderboard AS
SELECT
    c.city_name                          AS City,
    COUNT(DISTINCT s.startup_id)         AS Total_Startups,
    COUNT(fr.round_id)                   AS Total_Rounds,
    SUM(fr.amount_usd)                   AS Total_Funding_USD,
    ROUND(AVG(fr.amount_usd), 0)         AS Avg_Deal_Size_USD
FROM FundingRound fr
JOIN Startup s ON fr.startup_id = s.startup_id
JOIN City c    ON s.city_id     = c.city_id
GROUP BY c.city_name;

-- How to USE this view:
SELECT * FROM v_CityFundingLeaderboard ORDER BY Total_Funding_USD DESC;

-- ============================================================
-- VIEW 2: v_IndustryFundingSummary
-- Shows which industries are getting the most money.
-- ============================================================
CREATE OR REPLACE VIEW v_IndustryFundingSummary AS
SELECT
    i.industry_name                      AS Industry,
    COUNT(DISTINCT s.startup_id)         AS Total_Startups,
    COUNT(fr.round_id)                   AS Total_Rounds,
    SUM(fr.amount_usd)                   AS Total_Funding_USD,
    ROUND(AVG(fr.amount_usd), 0)         AS Avg_Deal_Size_USD
FROM FundingRound fr
JOIN Startup s  ON fr.startup_id  = s.startup_id
JOIN Industry i ON s.industry_id  = i.industry_id
GROUP BY i.industry_name;

-- How to USE this view:
SELECT * FROM v_IndustryFundingSummary ORDER BY Total_Funding_USD DESC;

-- ============================================================
-- VIEW 3: v_YearlyFundingTrend
-- Shows year-wise growth of startup funding in India.
-- ============================================================
CREATE OR REPLACE VIEW v_YearlyFundingTrend AS
SELECT
    YEAR(fr.funding_date)                AS Year,
    COUNT(fr.round_id)                   AS Total_Rounds,
    SUM(fr.amount_usd)                   AS Total_Funding_USD,
    ROUND(AVG(fr.amount_usd), 0)         AS Avg_Deal_USD
FROM FundingRound fr
WHERE fr.funding_date IS NOT NULL
GROUP BY YEAR(fr.funding_date);

-- How to USE this view:
SELECT * FROM v_YearlyFundingTrend ORDER BY Year;

-- ============================================================
-- VIEW 4: v_FullFundingDetails
-- A complete view combining ALL tables — like a master report.
-- Very useful for reading all info in one shot.
-- ============================================================
CREATE OR REPLACE VIEW v_FullFundingDetails AS
SELECT
    fr.round_id                          AS Round_ID,
    s.startup_name                       AS Startup,
    i.industry_name                      AS Industry,
    sv.sub_vertical_name                 AS Sub_Vertical,
    c.city_name                          AS City,
    it.type_name                         AS Investment_Stage,
    fr.amount_usd                        AS Amount_USD,
    fr.funding_date                      AS Date
FROM FundingRound fr
JOIN Startup s         ON fr.startup_id         = s.startup_id
JOIN Industry i        ON s.industry_id          = i.industry_id
JOIN SubVertical sv    ON s.sub_vertical_id      = sv.sub_vertical_id
JOIN City c            ON s.city_id              = c.city_id
JOIN InvestmentType it ON fr.investment_type_id  = it.investment_type_id;

-- How to USE this view:
SELECT * FROM v_FullFundingDetails ORDER BY Date DESC LIMIT 20;

-- Filter the view for a specific industry:
SELECT * FROM v_FullFundingDetails WHERE Industry = 'FinTech' ORDER BY Amount_USD DESC;

-- ============================================================
-- VIEW 5: v_TopInvestors
-- Shows investors who are most active by number of deals.
-- ============================================================
CREATE OR REPLACE VIEW v_TopInvestors AS
SELECT
    inv.investor_name                    AS Investor,
    COUNT(ri.round_id)                   AS Rounds_Participated,
    SUM(fr.amount_usd)                   AS Total_Amount_Co_Invested
FROM RoundInvestor ri
JOIN Investor inv    ON ri.investor_id = inv.investor_id
JOIN FundingRound fr ON ri.round_id    = fr.round_id
GROUP BY inv.investor_name;

-- How to USE this view:
SELECT * FROM v_TopInvestors ORDER BY Rounds_Participated DESC LIMIT 10;
