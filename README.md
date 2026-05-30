
# 🚴‍♂️ Divvy Bike-Share Cloud Analytics Pipeline (AWS & Tableau)

## 📌 Project Overview
This project builds an end-to-end, serverless cloud data pipeline on **AWS** to store, transform, and analyze historical bike-share trip data for **Cyclistic**, a fictional bike-share company operating in Chicago. 

The primary business objective is to solve a core marketing challenge set by the Director of Marketing, Lily Moreno: **Understand how casual riders and annual members use Cyclistic bikes differently**. These data-driven insights will be utilized by the marketing analytics team to design strategies aimed at converting high-value casual riders into profitable annual members.

Instead of using desktop spreadsheet tools that crash under massive datasets, this solution implements a decoupled cloud architecture using **Amazon S3, AWS Glue, Amazon Athena (Presto SQL), and Tableau Public** to process full-year data efficiently.

---

## 🏗️ Data Pipeline Architecture
The system architecture decouples storage, metadata cataloging, compute analytics, and business intelligence visualization layer.

### 📐 Text-Based Architecture Flow
```text
┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
│  Raw Data (.CSV)     │ ───> │  Amazon S3 (Raw Zone)   │ ───> │   AWS Glue Crawler     │
│  Historical Trips    │      │  s3://.../raw-data/     │      │   Automated Discovery  │
└──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
                                                                           │
                                                                           ▼
┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
│ Tableau Public BI    │ <─── │ Download Aggregated CSV │ <─── │ AWS Glue Data Catalog  │
│ Executive Dashboard  │      │ s3://.../query-results/ │      │ Metadata Base Schema   │
└──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
                                           ▲                               │
                                           │                               ▼
                                           └─────────────────────── [ Amazon Athena ]
                                                                     Presto SQL ETL Engine
                                                                     (CTAS Transformations)







