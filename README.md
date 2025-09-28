# Data Cleaning & EDA (MySQL)

 
End-to-end MySQL pipeline to clean, normalize and analyze a 1,272-row laptops dataset. All cleaning steps and analysis queries are provided in `laptopdata_cleaning_analysis.sql` (plus a printable PDF). Key quantitative finding: **RAM is the strongest numeric predictor of price (r ≈ 0.69, r² ≈ 47.6%)**, followed by storage type and CPU speed.

---

##  Project Overview
This repo demonstrates a reproducible MySQL workflow to transform messy laptop product text into analysis-ready fields and run repeatable exploratory data analysis (EDA) entirely in SQL. The goal is to identify which product attributes drive price and produce actionable summary tables.

---

##  What I did
- Backed up raw data and built a reproducible SQL pipeline.  
- Standardized columns: RAM, storage (type + size), CPU (speed + cores), screen resolution/size, OS, brand, price.  
- Parsed & cast string fields to numeric types (e.g., `8 GB` → `8`, `1,299` → `1299.00`).  
- Handled missing values and duplicates; created a clean `laptops_cleaned` table for analysis.  
- Performed EDA in MySQL: distributions, group-bys, summary tables and correlation estimates.  
- Packaged all steps into `laptopdata_cleaning_analysis.sql` and included a readable `laptopdata_cleaning_analysis.pdf`.

---

##  Key findings (quantified)
- **RAM**: strongest numeric predictor of price — **r ≈ 0.69 (r² ≈ 47.6%)**. More RAM strongly correlates with higher price tiers.  
- **Storage type**: SSD/Hybrid models command significantly higher average prices than HDD models.  
- **CPU speed**: positive correlation with price but weaker than RAM — **r ≈ 0.43 (r² ≈ 18%)**.  
- **OS & brand effects**: macOS machines occupy the premium band; Windows are midrange; Linux/no-OS skew budget.  
- **Expandable storage (SD slot)**: negatively correlated with price — common in budget models.  

**Takeaway:** Memory and fast storage are primary levers for premium pricing; CPU and display add value but less so.

