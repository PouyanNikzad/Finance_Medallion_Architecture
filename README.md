This project implements a flexible, platform‑independent financial transaction model using dbt and Snowflake, designed to support multiple types of financial activity (payments, refunds, fees, interest, FX, adjustments, etc.) without coupling to any external finance or accounting platform.
At the core of the design is a unified, immutable ledger fact table that represents all financial transactions in a consistent structure. Instead of creating separate tables per transaction type, the project uses a single canonical transaction model enriched with extensible, semi‑structured attributes. This allows new transaction types or business requirements to be introduced through data and configuration changes rather than schema rewrites.
All financial facts are treated as append‑only and auditable—corrections and reversals are modeled as new transactions rather than updates or deletes. dbt is used to enforce data contracts, tests, and financial integrity checks, ensuring consistency and trust in downstream analytics. Snowflake serves as the system of record, leveraging its support for semi‑structured data to balance flexibility and governance.
Business‑specific logic and reporting requirements are implemented in downstream marts, derived from the core ledger, allowing different analytical views (cash flow, revenue, fees, FX exposure) without fragmenting the underlying financial truth.
This approach keeps financial logic centralized, transparent, and testable, while enabling a custom application to act purely as an event producer—making the solution scalable, auditable, and resilient to future change.


Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
