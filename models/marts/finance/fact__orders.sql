WITH cte_orders AS (
    SELECT
        order_id
        , customer_id
        , order_date

    FROM 
        {{ ref('stg__jaffle_shop__orders')}} 
),

cte_payments AS (
    SELECT
        *
    FROM 
        {{ ref('stg__stripe__payments')}}
),

cte_order_payments AS (
    SELECT
        order_id
        , SUM(CASE WHEN status = 'success' THEN amount END) AS amount    
    FROM 
        cte_payments
    GROUP BY 1
),

final AS (
    SELECT 
        o.order_id
        , o.customer_id
        , o.order_date
        , COALESCE(c.amount, 0) as amount

    FROM 
        cte_orders o

    LEFT JOIN 
        cte_payments c
    USING 
        (order_id)
)

SELECT
    *

FROM 
    final