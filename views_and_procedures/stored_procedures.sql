-- ============================================================
-- FILE: stored_procedures.sql
-- PROJECT: Indian Startup Funding Intelligence System
-- DESCRIPTION:
--   A STORED PROCEDURE is a saved set of SQL statements.
--   You call it with CALL procedure_name(); and it runs.
--   Useful for tasks you do repeatedly.
-- HOW TO RUN THIS FILE:
--   Run everything in this file to CREATE the procedures.
--   Then use CALL procedure_name(); to execute them.
-- ============================================================

USE StartupFundingDB;

-- Change the delimiter so MySQL doesn't confuse semicolons
-- inside the procedure body with end-of-statement
DELIMITER //

-- ============================================================
-- PROCEDURE 1: GetStartupDetails
-- INPUT: A startup name (text)
-- OUTPUT: All funding rounds for that startup
-- USAGE: CALL GetStartupDetails('Groww');
-- ============================================================
CREATE PROCEDURE GetStartupDetails(IN p_startup_name VARCHAR(200))
BEGIN
    SELECT
        s.startup_name                  AS Startup,
        i.industry_name                 AS Industry,
        c.city_name                     AS City,
        it.type_name                    AS Stage,
        fr.amount_usd                   AS Amount_USD,
        fr.funding_date                 AS Date
    FROM FundingRound fr
    JOIN Startup s         ON fr.startup_id         = s.startup_id
    JOIN Industry i        ON s.industry_id          = i.industry_id
    JOIN City c            ON s.city_id              = c.city_id
    JOIN InvestmentType it ON fr.investment_type_id  = it.investment_type_id
    WHERE s.startup_name = p_startup_name
    ORDER BY fr.funding_date;
END //

-- ============================================================
-- PROCEDURE 2: GetCitySummary
-- INPUT: A city name (text)
-- OUTPUT: All startups and their total funding in that city
-- USAGE: CALL GetCitySummary('Bengaluru');
-- ============================================================
CREATE PROCEDURE GetCitySummary(IN p_city_name VARCHAR(100))
BEGIN
    SELECT
        s.startup_name                  AS Startup,
        i.industry_name                 AS Industry,
        COUNT(fr.round_id)              AS Total_Rounds,
        SUM(fr.amount_usd)              AS Total_Raised_USD
    FROM FundingRound fr
    JOIN Startup s  ON fr.startup_id = s.startup_id
    JOIN City c     ON s.city_id     = c.city_id
    JOIN Industry i ON s.industry_id = i.industry_id
    WHERE c.city_name = p_city_name
    GROUP BY s.startup_name, i.industry_name
    ORDER BY SUM(fr.amount_usd) DESC;
END //

-- ============================================================
-- PROCEDURE 3: GetTopStartupsByIndustry
-- INPUT: Industry name, and how many results to show (limit)
-- OUTPUT: Top N startups in that industry by total funding
-- USAGE: CALL GetTopStartupsByIndustry('FinTech', 5);
-- ============================================================
CREATE PROCEDURE GetTopStartupsByIndustry(
    IN p_industry VARCHAR(100),
    IN p_limit    INT
)
BEGIN
    SELECT
        s.startup_name                  AS Startup,
        c.city_name                     AS City,
        COUNT(fr.round_id)              AS Rounds,
        SUM(fr.amount_usd)              AS Total_Raised_USD
    FROM FundingRound fr
    JOIN Startup s  ON fr.startup_id  = s.startup_id
    JOIN Industry i ON s.industry_id  = i.industry_id
    JOIN City c     ON s.city_id      = c.city_id
    WHERE i.industry_name = p_industry
    GROUP BY s.startup_name, c.city_name
    ORDER BY SUM(fr.amount_usd) DESC
    LIMIT p_limit;
END //

-- ============================================================
-- PROCEDURE 4: AddNewFundingRound
-- INPUT: Startup name, investment type, amount, date
-- OUTPUT: Inserts a new funding round into the database
-- USAGE: CALL AddNewFundingRound('Groww', 'Series A', 5000000, '2026-01-15');
-- ============================================================
CREATE PROCEDURE AddNewFundingRound(
    IN p_startup_name   VARCHAR(200),
    IN p_type_name      VARCHAR(50),
    IN p_amount         BIGINT,
    IN p_date           DATE
)
BEGIN
    DECLARE v_startup_id INT;
    DECLARE v_type_id    INT;

    -- Find the startup ID by name
    SELECT startup_id INTO v_startup_id
    FROM Startup
    WHERE startup_name = p_startup_name
    LIMIT 1;

    -- Find the investment type ID by name
    SELECT investment_type_id INTO v_type_id
    FROM InvestmentType
    WHERE type_name = p_type_name
    LIMIT 1;

    -- Check if startup was found
    IF v_startup_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Startup not found. Please check the name.';
    ELSE
        -- Insert the new funding round
        INSERT INTO FundingRound (startup_id, investment_type_id, amount_usd, funding_date)
        VALUES (v_startup_id, v_type_id, p_amount, p_date);

        SELECT 'Funding round added successfully!' AS Message;
    END IF;
END //

-- ============================================================
-- PROCEDURE 5: GetYearlyReport
-- INPUT: A year (e.g. 2023)
-- OUTPUT: Full funding activity for that year
-- USAGE: CALL GetYearlyReport(2023);
-- ============================================================
CREATE PROCEDURE GetYearlyReport(IN p_year INT)
BEGIN
    SELECT
        i.industry_name                 AS Industry,
        COUNT(fr.round_id)              AS Total_Rounds,
        SUM(fr.amount_usd)              AS Total_Funding_USD,
        ROUND(AVG(fr.amount_usd), 0)    AS Avg_Deal_USD
    FROM FundingRound fr
    JOIN Startup s  ON fr.startup_id  = s.startup_id
    JOIN Industry i ON s.industry_id  = i.industry_id
    WHERE YEAR(fr.funding_date) = p_year
    GROUP BY i.industry_name
    ORDER BY SUM(fr.amount_usd) DESC;
END //

-- Restore the delimiter back to normal
DELIMITER ;

-- ============================================================
-- HOW TO CALL YOUR PROCEDURES (copy-paste these):
-- ============================================================

-- CALL GetStartupDetails('Groww');
-- CALL GetStartupDetails('Ola');

-- CALL GetCitySummary('Bengaluru');
-- CALL GetCitySummary('Mumbai');

-- CALL GetTopStartupsByIndustry('FinTech', 5);
-- CALL GetTopStartupsByIndustry('EdTech', 3);

-- CALL GetYearlyReport(2023);
-- CALL GetYearlyReport(2024);

-- CALL AddNewFundingRound('Groww', 'Series D', 50000000, '2026-03-01');
