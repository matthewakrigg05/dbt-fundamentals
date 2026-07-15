with customers as (

    SELECT 
        *
    
    FROM
        {{ ref('stg__jaffle_shop__customers') }}

),

orders as (

    SELECT 
        *
    
    FROM
        {{ ref('stg__jaffle_shop__orders') }}

),

customer_orders AS (

    SELECT
        customer_id
        , MIN(order_date) AS first_order_date
        , MAX(order_date) AS most_recent_order_date
        , COUNT(order_id) AS number_of_orders

    FROM 
        orders

    GROUP BY 1

),

payments AS (

    SELECT
        p.payment_id
        , p.order_id
        , p.amount

    FROM 
        {{ ref('stg__stripe__payments') }} p

    WHERE 
        p.status = 'success'

),

customer_payments AS (

    SELECT
        o.customer_id
        , SUM(p.amount) AS lifetime_value

    FROM 
        orders o
    
    JOIN 
        payments p 
    ON
        o.order_id = p.order_id

    GROUP BY 1

),


final AS (

    SELECT
        c.customer_id
        , c.first_name
        , c.last_name
        , COALESCE(cp.lifetime_value, 0) AS lifetime_value
        , co.first_order_date
        , co.most_recent_order_date
        , COALESCE(co.number_of_orders, 0) AS number_of_orders

    FROM 
        customers c

    LEFT JOIN 
        customer_orders co
    USING 
        (customer_id)
    
    LEFT JOIN 
        customer_payments cp
    USING 
        (customer_id)

)

SELECT 
    * 
FROM 
    final
