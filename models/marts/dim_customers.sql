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

customer_orders as (

    select
        customer_id,

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders

    from orders

    group by 1

),

payments as (

    select
        p.payment_id,
        p.order_id,
        p.amount

    from {{ ref('stg__stripe__payments') }} p

    where p.status = 'success'

),

customer_payments as (

    select
        o.customer_id,
        sum(p.amount) as lifetime_value

    from orders o
    join payments p on o.order_id = p.order_id

    group by 1

),


final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        coalesce(customer_payments.lifetime_value, 0) as lifetime_value,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders

    from customers

    left join customer_orders using (customer_id)
    left join customer_payments using (customer_id)

)

select * from final
