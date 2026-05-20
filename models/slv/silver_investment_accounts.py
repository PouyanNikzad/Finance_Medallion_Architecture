from functools import reduce
from snowflake.snowpark.functions import col, lit

CANON_COLS = [
    "TRANSACTIONS_HKEY",
    "TRANSACTION_HDIFF",
    "SYMBOL",
    "MARKET",
    "DESCRIPTION",
    "QUANTITY",
    "PRICE",
    "AVERAGE_COST",
    "BOOK_COST",
    "MARKET_VALUE",
    "VOLUME",
	"DAY_LOW",
	"DAY_HIGH",
	"WK52_LOW",
	"WK52_HIGH",
    "INISTITUE_SCHEMA_NAME",
    "PRODUCT_NAME",
    "STAGING_INSERT_TIME",
    "ACCOUNT_NAME"          # derived
]

def standardize(df, account_name: str):
    # Add missing columns as NULL + add account_name
    df = df.with_column("ACCOUNT_NAME", lit(account_name))

    existing = set(df.columns)
    for c in CANON_COLS:
        if c not in existing:
            df = df.with_column(c, lit(None))

    return df.select([col(c) for c in CANON_COLS])

def model(dbt, session):
    dbt.config(materialized="table", tags=["silver", "investments"])

    # ✅ dbt.ref() args are string literals
    df_cash_cad = dbt.ref("bronze_td_cash_cad")
    df_tfsa_cad = dbt.ref("bronze_td_tfsa_cad")
    df_rrsp_cad = dbt.ref("bronze_td_rrsp_cad")
    df_cash_usd = dbt.ref("bronze_td_cash_usd")
    df_questrade = dbt.ref("bronze_questrade")

    # Align/rename columns (adjust these to match each bronze model’s actual column names)
    cash_cad = df_cash_cad.select(
    col("TRANSACTIONS_HKEY"),
    col("TRAN_TD_CAD_CASH_INVEST_TRANSACTIONS_HDIFF").alias("TRANSACTION_HDIFF"),
    col("SYMBOL"),
    col("MARKET"),
    col("DESCRIPTION"),
    col("QUANTITY"),
    col("PRICE"),
    col("AVERAGE_COST"),
    col("BOOK_COST"),
    col("MARKET_VALUE"),
    col("VOLUME"),
	col("DAY_LOW"),
	col("DAY_HIGH"),
	col("WK52_LOW"),
	col("WK52_HIGH"),
    col("INISTITUE_SCHEMA_NAME"),
    col("PRODUCT_NAME"),
    col("STAGING_INSERT_TIME")
    )
    tfsa_cad = df_tfsa_cad.select(
        col("TRANSACTIONS_HKEY"),
        col("TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_HDIFF").alias("TRANSACTION_HDIFF"),
    col("SYMBOL"),
    col("MARKET"),
    col("DESCRIPTION"),
    col("QUANTITY"),
    col("PRICE"),
    col("AVERAGE_COST"),
    col("BOOK_COST"),
    col("MARKET_VALUE"),
    col("VOLUME"),
	col("DAY_LOW"),
	col("DAY_HIGH"),
	col("WK52_LOW"),
	col("WK52_HIGH"),
    col("INISTITUE_SCHEMA_NAME"),
    col("PRODUCT_NAME"),
    col("STAGING_INSERT_TIME")
    )
    rrsp_cad = df_rrsp_cad.select(
        col("TRANSACTIONS_HKEY"),
        col("TRAN_TD_CAD_RRSP_INVEST_TRANSACTIONS_HDIFF").alias("TRANSACTION_HDIFF"),
    col("SYMBOL"),
    col("MARKET"),
    col("DESCRIPTION"),
    col("QUANTITY"),
    col("PRICE"),
    col("AVERAGE_COST"),
    col("BOOK_COST"),
    col("MARKET_VALUE"),
    col("VOLUME"),
	col("DAY_LOW"),
	col("DAY_HIGH"),
	col("WK52_LOW"),
	col("WK52_HIGH"),
    col("INISTITUE_SCHEMA_NAME"),
    col("PRODUCT_NAME"),
    col("STAGING_INSERT_TIME")
    )
    cash_usd = df_cash_usd.select(
        col("TRANSACTIONS_HKEY"),
        col("TRAN_TD_USD_CASH_INVEST_TRANSACTIONS_HDIFF").alias("TRANSACTION_HDIFF"),
    col("SYMBOL"),
    col("MARKET"),
    col("DESCRIPTION"),
    col("QUANTITY"),
    col("PRICE"),
    col("AVERAGE_COST"),
    col("BOOK_COST"),
    col("MARKET_VALUE"),
    col("VOLUME"),
	col("DAY_LOW"),
	col("DAY_HIGH"),
	col("WK52_LOW"),
	col("WK52_HIGH"),
    col("INISTITUE_SCHEMA_NAME"),
    col("PRODUCT_NAME"),
    col("STAGING_INSERT_TIME")
    )    
    questrade = df_questrade.select(
    col("TRANSACTIONS_HKEY"),
    col("TRAN_QUESTRADE_TRANSACTIONS_HDIFF").alias("TRANSACTION_HDIFF"),
    col("EQUITY_SYMBOL").alias("SYMBOL"),
    col("CURRENCY").alias("MARKET"),
    col("EQUITY_DESCRIPTION").alias("DESCRIPTION"),
    col("QUANTITY"),
    col("MARKET_PRICE").alias("PRICE"),
    col("COST_PER_SHARE").alias("AVERAGE_COST"),
    col("POSITION_COST").alias("BOOK_COST"),
    col("MARKET_VALUE"),
    col("VOLUME"),
	col("DAY_LOW"),
	col("DAY_HIGH"),
	col("WK52_LOW"),
	col("WK52_HIGH"),
    col("INISTITUE_SCHEMA_NAME"),
    col("PRODUCT_NAME"),
    col("STAGING_INSERT_TIME")
    )      

    dfs = [
        standardize(cash_cad, "TD_CASH_CAD"),
        standardize(tfsa_cad, "TD_TFSA_CAD"),
        standardize(rrsp_cad, "TD_RRSP_CAD"),
        standardize(cash_usd, "TD_CASH_USD"),
        standardize(questrade, "questrade"),
    ]

    # Union all DataFrames (by name is safest if schemas evolve)
    final_df = reduce(lambda a, b: a.union_all_by_name(b, allow_missing_columns=True), dfs)

    return final_df