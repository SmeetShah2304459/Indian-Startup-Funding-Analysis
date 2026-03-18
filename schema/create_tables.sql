-- ============================================================
-- FILE: create_tables.sql
-- PROJECT: Indian Startup Funding Intelligence System
-- AUTHOR: [Your Name]
-- DATE: 2026
-- DESCRIPTION:
--   This file creates all the tables for our project.
--   We are using a NORMALIZED design (up to 3NF).
--   Always run this file FIRST before inserting any data.
-- ============================================================

-- Step 1: Create the database
CREATE DATABASE IF NOT EXISTS StartupFundingDB;

-- Step 2: Select/use the database
USE StartupFundingDB;

-- ============================================================
-- TABLE 1: City
-- Stores the names of cities where startups are located.
-- Separating this avoids repeating city names in every row.
-- ============================================================
CREATE TABLE City (
    city_id   INT PRIMARY KEY AUTO_INCREMENT,  -- Unique ID for each city
    city_name VARCHAR(100) NOT NULL             -- Name of the city
);

-- ============================================================
-- TABLE 2: Industry
-- Stores the main industry categories (e.g. FinTech, EdTech).
-- Separating this avoids repeating industry names everywhere.
-- ============================================================
CREATE TABLE Industry (
    industry_id   INT PRIMARY KEY AUTO_INCREMENT,
    industry_name VARCHAR(100) NOT NULL
);

-- ============================================================
-- TABLE 3: SubVertical
-- Stores sub-categories under each industry.
-- Example: "Payments" is a sub-vertical of "FinTech".
-- This links back to Industry using industry_id (Foreign Key).
-- ============================================================
CREATE TABLE SubVertical (
    sub_vertical_id   INT PRIMARY KEY AUTO_INCREMENT,
    sub_vertical_name VARCHAR(100) NOT NULL,
    industry_id       INT,                         -- Links to Industry table
    FOREIGN KEY (industry_id) REFERENCES Industry(industry_id)
);

-- ============================================================
-- TABLE 4: Startup
-- Stores each startup company (only once, not repeated).
-- Links to City, Industry, SubVertical using Foreign Keys.
-- ============================================================
CREATE TABLE Startup (
    startup_id      INT PRIMARY KEY AUTO_INCREMENT,
    startup_name    VARCHAR(200) NOT NULL,
    city_id         INT,                           -- Which city is this startup from?
    industry_id     INT,                           -- Which industry?
    sub_vertical_id INT,                           -- Which sub-vertical?
    FOREIGN KEY (city_id)         REFERENCES City(city_id),
    FOREIGN KEY (industry_id)     REFERENCES Industry(industry_id),
    FOREIGN KEY (sub_vertical_id) REFERENCES SubVertical(sub_vertical_id)
);

-- ============================================================
-- TABLE 5: InvestmentType
-- Stores investment stage names (Seed, Series A, Series B, etc.)
-- Separating this keeps the main table clean.
-- ============================================================
CREATE TABLE InvestmentType (
    investment_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name          VARCHAR(50) NOT NULL   -- e.g. "Seed", "Series A", "Angel"
);

-- ============================================================
-- TABLE 6: Investor
-- Stores each investor firm name.
-- In the original Excel, multiple investors were crammed into
-- one cell separated by commas — that is a 1NF violation!
-- We fix that here by storing each investor separately.
-- ============================================================
CREATE TABLE Investor (
    investor_id   INT PRIMARY KEY AUTO_INCREMENT,
    investor_name VARCHAR(200) NOT NULL UNIQUE   -- Each investor appears only once
);

-- ============================================================
-- TABLE 7: FundingRound (MAIN / FACT TABLE)
-- Each row = one funding event for a startup.
-- Links to Startup and InvestmentType using Foreign Keys.
-- ============================================================
CREATE TABLE FundingRound (
    round_id           INT PRIMARY KEY AUTO_INCREMENT,
    startup_id         INT NOT NULL,     -- Which startup received funding?
    investment_type_id INT,              -- What kind of round? (Seed, Series A...)
    amount_usd         BIGINT,           -- How much money was raised? (in USD)
    funding_date       DATE,             -- When did this happen?
    FOREIGN KEY (startup_id)         REFERENCES Startup(startup_id),
    FOREIGN KEY (investment_type_id) REFERENCES InvestmentType(investment_type_id)
);

-- ============================================================
-- TABLE 8: RoundInvestor (JUNCTION / BRIDGE TABLE)
-- This table solves the 1NF problem!
-- One funding round can have MANY investors.
-- One investor can participate in MANY rounds.
-- This is a Many-to-Many relationship.
-- ============================================================
CREATE TABLE RoundInvestor (
    round_id    INT,
    investor_id INT,
    PRIMARY KEY (round_id, investor_id),    -- Composite Primary Key
    FOREIGN KEY (round_id)    REFERENCES FundingRound(round_id),
    FOREIGN KEY (investor_id) REFERENCES Investor(investor_id)
);

-- ============================================================
-- Done! You should now have 8 tables created.
-- Next step: Run insert_data.sql to load the data.
-- ============================================================
