USE bank_system;
GO

CREATE VIEW vw_monthly_cash_delivery_summary AS
SELECT 
    cb.bank_branch_id AS branch_id,
    cb.address AS branch_address,
    cb.manager_email AS branch_manager,
    
    -- Статистика по инкассации
    COUNT(cc.collection_id) AS total_deliveries,
    SUM(cc.amount) AS total_amount_delivered,
    AVG(cc.amount) AS average_delivery_amount,
    MIN(cc.amount) AS min_delivery_amount,
    MAX(cc.amount) AS max_delivery_amount,
    
    -- Детали по времени
    MIN(cc.completed_at) AS first_delivery_date,
    MAX(cc.completed_at) AS last_delivery_date,
    
    -- Количество заказов, связанных с инкассацией
    COUNT(DISTINCT cc.order_id) AS orders_served,
    
    -- Служебная информация
    MONTH(GETDATE()) AS report_month,
    YEAR(GETDATE()) AS report_year
FROM 
    bank_branch cb
    LEFT JOIN cash_collection cc ON cb.bank_branch_id = cc.to_branch_id 
        AND cc.status = 'completed'
        AND MONTH(cc.completed_at) = MONTH(GETDATE())
        AND YEAR(cc.completed_at) = YEAR(GETDATE())
GROUP BY 
    cb.bank_branch_id, cb.address, cb.manager_email
HAVING 
    COUNT(cc.collection_id) > 0  -- только офисы с доставками
GO