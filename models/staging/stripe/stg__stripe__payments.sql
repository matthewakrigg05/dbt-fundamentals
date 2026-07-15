SELECT  
    id AS payment_id
    , orderid AS order_id
    , paymentmethod AS payment_method
    , status
    , ROUND(amount / 100.0, 2) AS amount
    , created AS created_at

FROM
    {{ source('stripe', 'payments') }}