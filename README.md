# 🏦 RFM Customer Segmentation — Analytics Engineering Portfolio

> **dbt + BigQuery + Python** · End-to-end Analytics Engineering project simulating customer behavior analysis for a LATAM fintech/retail context.

---

## 📌 Business Context

Banks and fintechs like BCP, Yape, or Rappi need to know **which customers are loyal, which are at risk, and which are about to churn** — before it shows up in their revenue.

This project builds a production-ready RFM segmentation pipeline over an e-commerce retail dataset, replicating the kind of analysis a Digital Analytics → Analytics Engineering team would run on transactional data:

| Raw data concept | Fintech equivalent |
|---|---|
| Invoice / transaction | App payment or transfer |
| Customer ID | User account |
| Quantity × Price | Transaction amount |
| Invoice date | Last app interaction |
| RFM score | Customer health score |

**Result:** 4,312 customers classified into 6 behavioral segments with actionable scoring — ready for CRM campaigns or churn prevention workflows.

---

## 🏗️ Architecture

```
Kaggle (Online Retail II UK)
        │
        ▼
  pipeline/                          ← Python ELT
  extract_load_bq.py
        │
        ▼
  BigQuery: ga4_data.retail_online_raw   ← Raw table
        │
        ▼
┌─────────────────────────────────────────┐
│  STAGING  (views)                       │
│  stg_retail_transaction                 │
│  → rename, cast, surrogate key, filter  │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  INTERMEDIATE  (ephemeral)              │
│  int_customer_metrics                   │
│  → recency, frequency, monetary per     │
│    customer · data quality filters      │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  MARTS  (tables)                        │
│  fct_rfm_analysis                       │
│  → RFM scoring (1–5) · segment labels  │
│  → Champions / Loyal / At Risk / ...   │
└─────────────────────────────────────────┘
        │
        ▼
  Looker Studio Dashboard
```

---

## 📊 Results

| Segment | Users | % | Description |
|---|---|---|---|
| Loyalty users | 1,171 | 27.2% | High frequency, consistent spend |
| Stand by users | 1,026 | 24.0% | Hibernating — at risk of churn |
| Champions | 922 | 21.4% | Best customers, bought recently |
| Regulars | 821 | 18.5% | Average behavior, growth potential |
| New clients | 347 | 8.0% | First purchase in recent window |
| Perfects | 39 | 0.9% | Perfect RFM score across all axes |

**Total:** 4,312 unique customers · Scoring: Recency + Frequency + Monetary (1–5 scale each)

---

## 🛠️ Tech Stack

- **dbt Core** — transformation layer (staging → intermediate → marts)
- **Google BigQuery** — data warehouse
- **Python 3** + `kaggle` API — data extraction and loading
- **Looker Studio** — dashboard and visualization
- **Git** — version control

---

## 📂 Project Structure

```
Practica_analytics/
│
├── dbt_project.yml              # dbt config: materializations per layer
│
├── models/
│   ├── sources.yml              # Source declaration: retail_online_raw
│   │
│   ├── staging/
│   │   ├── stg_retail_transaction.sql   # Rename + cast + surrogate key
│   │   └── schema.yml                   # Column docs + not_null tests
│   │
│   ├── intermediate/
│   │   └── int_customer_metrics.sql     # RFM metrics per customer
│   │                                    # (ephemeral — no storage cost)
│   └── marts/
│       ├── fct_rfm_analysis.sql         # Final scoring + segment labels
│       └── schema.yml                   # Tests + docs for mart
│
├── tests/
│   └── assert_positive_rfm_values.sql  # Custom test: no negative scores
│
└── pipeline/
    └── extract_load_bq.py              # Kaggle → BigQuery ELT script
```

---

## ⚙️ Setup

### Prerequisites

```bash
pip install dbt-bigquery kaggle google-cloud-bigquery pandas
```

### 1. GCP Authentication

```bash
gcloud auth application-default login
```

### 2. Configure dbt profile

Create `~/.dbt/profiles.yml` (never commit this file):

```yaml
retail_ecommerce_dbt:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: YOUR_GCP_PROJECT_ID
      dataset: YOUR_DATASET
      threads: 4
      timeout_seconds: 300
      location: US
```

### 3. Load raw data

```bash
cd pipeline
python extract_load_bq.py
```

### 4. Run dbt models

```bash
# Install dependencies
dbt deps

# Verify connection
dbt debug

# Run all models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve   # → http://localhost:8080
```

---

## 5. Dashboard

<img width="995" height="748" alt="image" src="https://github.com/user-attachments/assets/eda8cf26-a44d-4595-8cb6-ff2624d17bbc" />

Link: https://datastudio.google.com/reporting/962413ce-16e7-4fba-814c-2ff2c2ef7ea8

## 🧠 Architecture Decisions

| Decision | Why |
|---|---|
| Staging as **views** | No storage cost; always reflects source |
| Intermediate as **ephemeral** | Calculation step, not a business output |
| Marts as **tables** | Dashboards need read speed |
| Surrogate key in staging | `invoice + stockcode` → unique line item ID |
| Data quality filters in intermediate | Removes returns (qty < 0), free items (price = 0), and corrupted IDs |
| RFM scoring 1–5 with `NTILE` | Standard industry approach, easy to explain to stakeholders |

---

## 🧪 Data Quality

Custom filters applied in `int_customer_metrics.sql`:

```sql
WHERE customer_id IS NOT NULL
AND TRIM(CAST(customer_id AS STRING)) != ''
AND CAST(customer_id AS STRING) != 'nan'
AND quantity > 0        -- excludes returns
AND unit_price > 0      -- excludes free/error items
```

Custom test in `tests/`:
- `assert_positive_rfm_values.sql` — ensures no customer receives a score of 0 or negative

---

## 📎 Dataset

**Online Retail II** — UCI Machine Learning Repository via Kaggle  
Transactions from a UK-based e-commerce retailer (2009–2011)  
~500K rows · 8 columns · 4,312 unique customers after cleaning

---

## 👤 Author

**Luis Alvaro**  
Digital Analytics → Analytics Engineering  
[LinkedIn](https://www.linkedin.com/in/luisalvaromendozasilva-analyticsengineer/) · [GitHub](https://github.com/Luisalvaro-zip)

---

*Built as a portfolio project to demonstrate Analytics Engineering skills: ELT pipeline design, dbt layered modeling, data quality testing, and customer segmentation logic applicable to banking and fintech contexts.*
