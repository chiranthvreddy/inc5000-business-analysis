SELECT company, COUNT(*) AS company_count
FROM companies
GROUP BY company
HAVING COUNT(*) > 1;
SELECT
    COUNT(*) AS total_rows,
    SUM(company IS NULL OR company = '') AS missing_company,
    SUM(industry IS NULL OR industry = '') AS missing_industry,
    SUM(revenue IS NULL) AS missing_revenue,
    SUM(growth IS NULL) AS missing_growth,
    SUM(workers IS NULL) AS missing_workers
FROM companies;
SELECT
    COUNT(*) AS total_companies,
    SUM(revenue) AS total_revenue,
    ROUND(AVG(growth), 2) AS average_growth,
    ROUND(AVG(workers), 0) AS average_workers,
    ROUND(AVG(revenue), 0) AS average_revenue
FROM companies;
SELECT
    industry,
    COUNT(*) AS company_count,
    SUM(revenue) AS total_revenue,
    ROUND(AVG(growth), 2) AS avg_growth
FROM companies
GROUP BY industry
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    industry,
    COUNT(*) AS company_count,
    ROUND(AVG(growth), 2) AS avg_growth,
    SUM(revenue) AS total_revenue
FROM companies
GROUP BY industry
HAVING COUNT(*) >= 20
ORDER BY avg_growth DESC
LIMIT 10;
SELECT
    company,
    industry,
    state_l,
    revenue,
    growth,
    workers
FROM companies
ORDER BY revenue DESC
LIMIT 10;
SELECT
    company,
    industry,
    state_l,
    revenue,
    growth,
    workers
FROM companies
ORDER BY growth DESC
LIMIT 10;
-------------------------
ANALYSIS 1: INDUSTRY PERFORMANCE
-------------------------
SELECT
    industry,
    COUNT(*) AS company_count,
    ROUND(SUM(revenue) / 1000000000, 2) AS total_revenue_bn,
    ROUND(AVG(revenue) / 1000000, 2) AS avg_revenue_mn,
    ROUND(AVG(growth), 2) AS avg_growth
FROM companies
GROUP BY industry
HAVING COUNT(*) >= 20
ORDER BY total_revenue_bn DESC;
-----------------------------
ANALYSIS 2: COMPANY SIZE PERFORMANCE
-----------------------------
SELECT
    `Company Size` AS company_size,
    COUNT(*) AS company_count,
    ROUND(SUM(revenue) / 1000000000, 2) AS total_revenue_bn,
    ROUND(AVG(revenue) / 1000000, 2) AS avg_revenue_mn,
    ROUND(AVG(growth), 2) AS avg_growth,
    ROUND(AVG(workers), 0) AS avg_workers
FROM companies
GROUP BY `Company Size`
ORDER BY total_revenue_bn DESC;

------------------------------
ANALYSIS 3: GEOGRAPHIC OPPORTUNITY
------------------------------
SELECT
    state_s AS state,
    COUNT(*) AS company_count,
    ROUND(SUM(revenue) / 1000000000, 2) AS total_revenue_bn,
    ROUND(AVG(revenue) / 1000000, 2) AS avg_revenue_mn,
    ROUND(AVG(growth), 2) AS avg_growth
FROM companies
GROUP BY state_s
HAVING COUNT(*) >= 50
ORDER BY total_revenue_bn DESC;

------------------------------
 ANALYSIS 4: GROWTH SEGMENTATION
 -----------------------------
 SELECT
    CASE
        WHEN growth <= 100 THEN '≤100%'
        WHEN growth <= 500 THEN '100–500%'
        WHEN growth <= 1000 THEN '500–1,000%'
        ELSE '>1,000%'
    END AS growth_band,
    COUNT(*) AS company_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM companies),
        2
    ) AS percentage_of_companies
FROM companies
GROUP BY
    CASE
        WHEN growth <= 100 THEN '≤100%'
        WHEN growth <= 500 THEN '100–500%'
        WHEN growth <= 1000 THEN '500–1,000%'
        ELSE '>1,000%'
    END
ORDER BY MIN(growth);

-----------------------------
ANALYSIS 5: HIGH REVENUE + HIGH GROWTH
-----------------------------
SELECT
    company,
    industry,
    state_s AS state,
    revenue,
    growth,
    workers
FROM companies
WHERE revenue >= 1000000000
  AND growth >= 500
ORDER BY revenue DESC;
-----------------------------
ANALYSIS 6: COMPANY RANKING WITHIN INDUSTRY
-----------------------------
SELECT
    company,
    industry,
    revenue,
    growth,
    RANK() OVER (
        PARTITION BY industry
        ORDER BY revenue DESC
    ) AS revenue_rank_in_industry
FROM companies;
-------------------------------
 ANALYSIS 6B: TOP 3 COMPANIES BY REVENUE
 WITHIN EACH INDUSTRY
--------------------------------
WITH ranked_companies AS (
    SELECT
        company,
        industry,
        state_s AS state,
        revenue,
        growth,
        workers,
        RANK() OVER (
            PARTITION BY industry
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM companies
)

SELECT
    company,
    industry,
    state,
    revenue,
    growth,
    workers,
    revenue_rank
FROM ranked_companies
WHERE revenue_rank <= 3
ORDER BY industry, revenue_rank;
------------------------------------
ANALYSIS 7: TOP GROWTH COMPANIES
WITHIN EACH INDUSTRY
------------------------------------
WITH ranked_growth AS (
    SELECT
        company,
        industry,
        state_s AS state,
        revenue,
        growth,
        workers,
        RANK() OVER (
            PARTITION BY industry
            ORDER BY growth DESC
        ) AS growth_rank
    FROM companies
)

SELECT
    company,
    industry,
    state,
    revenue,
    growth,
    workers,
    growth_rank
FROM ranked_growth
WHERE growth_rank <= 3
ORDER BY industry, growth_rank;
----------------------------
ANALYSIS 8: INDUSTRY × COMPANY SIZE
----------------------------
SELECT
    industry,
    `Company Size` AS company_size,
    COUNT(*) AS company_count,
    ROUND(AVG(growth), 2) AS avg_growth,
    ROUND(AVG(revenue) / 1000000, 2) AS avg_revenue_mn
FROM companies
GROUP BY
    industry,
    `Company Size`
HAVING COUNT(*) >= 50
ORDER BY avg_growth DESC;
------------------------------
ANALYSIS 9: REVENUE SEGMENT vs GROWTH
------------------------------
SELECT
    CASE
        WHEN revenue < 10000000 THEN '<$10M'
        WHEN revenue < 50000000 THEN '$10M–$50M'
        WHEN revenue < 100000000 THEN '$50M–$100M'
        WHEN revenue < 500000000 THEN '$100M–$500M'
        ELSE '>$500M'
    END AS revenue_segment,

    COUNT(*) AS company_count,

    ROUND(AVG(growth), 2) AS avg_growth,

    ROUND(AVG(workers), 0) AS avg_workers

FROM companies

GROUP BY
    CASE
        WHEN revenue < 10000000 THEN '<$10M'
        WHEN revenue < 50000000 THEN '$10M–$50M'
        WHEN revenue < 100000000 THEN '$50M–$100M'
        WHEN revenue < 500000000 THEN '$100M–$500M'
        ELSE '>$500M'
    END

ORDER BY MIN(revenue);
-------------------------------
ANALYSIS 10: INDUSTRY OPPORTUNITY SCORECARD
------------------------------
WITH industry_metrics AS (
    SELECT
        industry,
        COUNT(*) AS company_count,
        SUM(revenue) AS total_revenue,
        AVG(growth) AS avg_growth
    FROM companies
    GROUP BY industry
),

industry_scores AS (
    SELECT
        industry,
        company_count,
        ROUND(total_revenue / 1000000000, 2) AS total_revenue_bn,
        ROUND(avg_growth, 2) AS avg_growth,

        CASE
            WHEN avg_growth >= 700
                 AND total_revenue >= 10000000000
                 AND company_count >= 100
            THEN 'High Opportunity'

            WHEN avg_growth >= 500
                 AND total_revenue >= 5000000000
            THEN 'Moderate Opportunity'

            ELSE 'Lower Opportunity'
        END AS opportunity_category

    FROM industry_metrics
)

SELECT
    industry,
    company_count,
    total_revenue_bn,
    avg_growth,
    opportunity_category
FROM industry_scores
ORDER BY
    CASE opportunity_category
        WHEN 'High Opportunity' THEN 1
        WHEN 'Moderate Opportunity' THEN 2
        ELSE 3
    END,
    avg_growth DESC;