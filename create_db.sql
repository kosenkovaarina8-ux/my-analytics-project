CREATE DATABASE bank_system;
GO

USE bank_system;
GO

-- Таблица клиентов
CREATE TABLE client (
    client_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(255) NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    client_email NVARCHAR(255) UNIQUE,
    registration_date DATETIME2 NOT NULL
);

-- Таблица отделений банка
CREATE TABLE bank_branch (
    bank_branch_id INT IDENTITY(1,1) PRIMARY KEY,
    address NVARCHAR(255) NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    manager_email NVARCHAR(255),
    working_hours NVARCHAR(100)
);

-- Таблица сотрудников банка
CREATE TABLE bank_employee (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    bank_branch_id INT NOT NULL FOREIGN KEY REFERENCES bank_branch(bank_branch_id),
    full_name NVARCHAR(255) NOT NULL,
    position NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    work_email NVARCHAR(255) UNIQUE
);

-- Таблица счетов
CREATE TABLE account (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL FOREIGN KEY REFERENCES client(client_id),
    number NVARCHAR(50) NOT NULL UNIQUE,
    currency NVARCHAR(3) NOT NULL,
    status NVARCHAR(50) NOT NULL,
    opened_at DATETIME2 NOT NULL,
    blocked_amount DECIMAL(15,2) NOT NULL DEFAULT 0
);

-- Таблица транзакций
CREATE TABLE transaction (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT NOT NULL FOREIGN KEY REFERENCES account(account_id),
    order_id INT NULL,
    transaction_type NVARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency NVARCHAR(3) NOT NULL,
    status NVARCHAR(50) NOT NULL,
    created_at DATETIME2 NOT NULL
);

-- Справочник типов комиссий
CREATE TABLE commission_type (
    commission_type_id INT IDENTITY(1,1) PRIMARY KEY,
    commission_name NVARCHAR(255) NOT NULL,
    rate DECIMAL(10,2) NOT NULL,
    calculation_method NVARCHAR(50) NOT NULL,
    is_active BIT NOT NULL
);

-- Связка счетов с типами комиссий
CREATE TABLE account_commission (
    account_id INT NOT NULL FOREIGN KEY REFERENCES account(account_id),
    commission_type_id INT NOT NULL FOREIGN KEY REFERENCES commission_type(commission_type_id),
    applied_from DATETIME2 NOT NULL,
    spec_custom_rate DECIMAL(10,2) NULL,
    PRIMARY KEY (account_id, commission_type_id)
);

-- Таблица заказов
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL FOREIGN KEY REFERENCES client(client_id),
    account_id INT NOT NULL FOREIGN KEY REFERENCES account(account_id),
    bank_branch_id INT NOT NULL FOREIGN KEY REFERENCES bank_branch(bank_branch_id),
    responses_employee_id INT NULL FOREIGN KEY REFERENCES bank_employee(employee_id),
    base_amount DECIMAL(15,2) NOT NULL,
    commission_amount DECIMAL(15,2) NOT NULL,
    status NVARCHAR(50) NOT NULL,
    blocking_reason NVARCHAR(MAX) NULL,
    cancellation_reason NVARCHAR(MAX) NULL,
    secret_code NVARCHAR(50) NOT NULL,
    created_at DATETIME2 NOT NULL,
    pickup_time DATETIME2 NULL
);

-- Таблица документов
CREATE TABLE rec_document (
    doc_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES orders(order_id),
    doc_type NVARCHAR(100) NOT NULL,
    file_link NVARCHAR(500) NOT NULL,
    generated_at DATETIME2 NOT NULL
);

-- Таблица заявок на выдачу
CREATE TABLE withdrawal_request (
    request_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES orders(order_id),
    branch_id INT NOT NULL FOREIGN KEY REFERENCES bank_branch(bank_branch_id),
    assigned_to_id INT NULL FOREIGN KEY REFERENCES bank_employee(employee_id),
    assigned_by_id INT NULL FOREIGN KEY REFERENCES bank_employee(employee_id),
    amount DECIMAL(15,2) NOT NULL,
    status NVARCHAR(50) NOT NULL,
    created_at DATETIME2 NOT NULL,
    assigned_at DATETIME2 NULL,
    completed_at DATETIME2 NULL
);

-- Таблица истории заявок
CREATE TABLE request_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    request_id INT NOT NULL FOREIGN KEY REFERENCES withdrawal_request(request_id),
    changed_by INT NOT NULL FOREIGN KEY REFERENCES bank_employee(employee_id),
    status NVARCHAR(50) NOT NULL,
    comment NVARCHAR(MAX) NULL,
    changed_at DATETIME2 NOT NULL
);

-- Таблица уведомлений
CREATE TABLE notification (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NULL FOREIGN KEY REFERENCES client(client_id),
    employee_id INT NULL FOREIGN KEY REFERENCES bank_employee(employee_id),
    order_id INT NULL FOREIGN KEY REFERENCES orders(order_id),
    type NVARCHAR(100) NOT NULL,
    channel NVARCHAR(50) NOT NULL,
    status NVARCHAR(50) NOT NULL,
    notification_text NVARCHAR(MAX) NOT NULL,
    sent_at DATETIME2 NOT NULL,
    CONSTRAINT CK_notification_recipient CHECK (
        (client_id IS NOT NULL) OR (employee_id IS NOT NULL)
    )
);

-- Таблица инкассации
CREATE TABLE cash_collection (
    collection_id INT IDENTITY(1,1) PRIMARY KEY,
    from_branch_id INT NOT NULL FOREIGN KEY REFERENCES bank_branch(bank_branch_id),
    to_branch_id INT NOT NULL FOREIGN KEY REFERENCES bank_branch(bank_branch_id),
    employee_id INT NOT NULL FOREIGN KEY REFERENCES bank_employee(employee_id),
    order_id INT NULL FOREIGN KEY REFERENCES orders(order_id),
    amount DECIMAL(15,2) NOT NULL,
    status NVARCHAR(50) NOT NULL,
    requested_at DATETIME2 NOT NULL,
    completed_at DATETIME2 NULL
);

-- Добавляем внешний ключ к уже созденной таблице

ALTER TABLE transaction
    ADD CONSTRAINT FK_transaction_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id);
GO