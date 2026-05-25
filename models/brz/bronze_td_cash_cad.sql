{{ invest_source_sql(
    source('raw_finance_transactions', 'TD_CAD_CASH_INVEST_TRANSACTIONS'),
    'TD',
    "CASH_CAD"
) }}