-- ================================================
-- حساب برو — قاعدة بيانات MySQL
-- ================================================

CREATE DATABASE IF NOT EXISTS hisabpro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hisabpro;

-- جدول البيانات الرئيسي (invoices, customers, products, expenses)
CREATE TABLE IF NOT EXISTS app_data (
    id          INT         NOT NULL DEFAULT 1,
    data_json   LONGTEXT    NOT NULL,
    updated_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- جدول الإعدادات (credentials, company info)
CREATE TABLE IF NOT EXISTS settings (
    setting_key     VARCHAR(100)    NOT NULL,
    setting_value   TEXT            NOT NULL,
    PRIMARY KEY (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- إدخال بيانات الدخول الافتراضية: admin / admin123
INSERT IGNORE INTO settings (setting_key, setting_value) VALUES
('credentials', '{"username":"admin","password":"admin123","name":"مدير النظام"}'),
('company',     '{"name":"شركتي","phone":"","email":"","address":""}');

-- إدخال صف البيانات الفارغ
INSERT IGNORE INTO app_data (id, data_json) VALUES
(1, '{"invoices":[],"customers":[],"expenses":[],"products":[],"nextInv":1,"nextCust":1,"nextExp":1,"nextProd":1}');
