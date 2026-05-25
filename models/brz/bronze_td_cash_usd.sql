{{ invest_source_sql(
    source('raw_finance_transactions', 'TD_USD_CASH_INVEST_TRANSACTIONS'),
    'TD',
    "CASH_USD"
) }}