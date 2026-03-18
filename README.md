# 🇮🇳 Indian Startup Funding Intelligence System

A fully normalized MySQL relational database project built on real Indian startup funding data from **2020 to 2025**.

---

## 📊 About the Dataset

| Property | Value |
|---|---|
| **Total Funding Rounds** | 1,100 |
| **Unique Startups** | 180 |
| **Industries** | 14 (FinTech, EdTech, HealthTech, SaaS…) |
| **Cities** | 10 (Bengaluru, Mumbai, Delhi, Hyderabad…) |
| **Investors** | 26 unique firms |
| **Date Range** | 2020 – 2025 |

---

## 🗄️ Database Schema (Normalized to 3NF)

```
City ←──── Startup ────→ Industry
                │               │
                └──→ SubVertical (Industry determines SubVertical)
                │
            FundingRound ────→ InvestmentType
                │
            RoundInvestor ←──── Investor
```

### Why is this design good?

- ✅ **1NF** — No multi-valued columns (Investors split into a junction table)
- ✅ **2NF** — Every field depends on the full primary key
- ✅ **3NF** — No transitive dependencies (City, Industry, SubVertical are separate)

---

## 🗂️ Project Structure

```
startup-funding-sql/
│
├── README.md                           ← You are here!
│
├── schema/
│   └── create_tables.sql               ← Step 1: Create all 8 tables
│
├── data/
│   └── insert_data.sql                 ← Step 2: Load all 1100 rows of data
│
├── queries/
│   ├── basic_queries.sql               ← Step 3: Simple SELECT & JOIN queries
│   └── analytical_queries.sql          ← Step 4: GROUP BY, HAVING, Subqueries
│
└── views_and_procedures/
    ├── views.sql                        ← Step 5: 5 reusable Views
    └── stored_procedures.sql            ← Step 6: 5 Stored Procedures
```

---

## 🚀 How to Run This Project

### Prerequisites
- MySQL 8.0+ installed
- MySQL Workbench (recommended) or any MySQL client

### Step-by-Step Setup

**Step 1** — Create the tables
```sql
SOURCE /path/to/schema/create_tables.sql;
```

**Step 2** — Insert the data
```sql
SOURCE /path/to/data/insert_data.sql;
```

**Step 3** — Run queries
```sql
SOURCE /path/to/queries/basic_queries.sql;
```

**Step 4** — Create views
```sql
SOURCE /path/to/views_and_procedures/views.sql;
```

**Step 5** — Create procedures
```sql
SOURCE /path/to/views_and_procedures/stored_procedures.sql;
```

---

## 💡 Sample Queries You Can Try

```sql
-- Top 10 funded startups
SELECT s.startup_name, SUM(fr.amount_usd) AS total
FROM FundingRound fr JOIN Startup s ON fr.startup_id = s.startup_id
GROUP BY s.startup_name ORDER BY total DESC LIMIT 10;

-- Funding trend per year
SELECT * FROM v_YearlyFundingTrend ORDER BY Year;

-- All rounds for a startup
CALL GetStartupDetails('Groww');

-- Top 5 FinTech startups
CALL GetTopStartupsByIndustry('FinTech', 5);
```

---

## 🛠️ Tech Stack

- **Database:** MySQL 8.0
- **Tools:** MySQL Workbench, DBeaver
- **Data Source:** Indian Startup Funding Dataset 2020–2025
- **Language:** SQL

---

## 👤 Author

**Smeet Shah**  
B.Tech (Computer Science Engineering and Data Science)  
GitHub: [SmeetShah2304459](https://github.com/SmeetShah2304459)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
