#!/bin/bash
# ════════════════════════════════════════════════
#  تثبيت PHP + MySQL + Nginx على Ubuntu 24.04
# ════════════════════════════════════════════════

echo "→ تحديث النظام..."
apt-get update -qq

echo "→ تثبيت Nginx + PHP + MySQL..."
apt-get install -y nginx php8.3-fpm php8.3-mysql mysql-server

echo "→ تشغيل الخدمات..."
systemctl start nginx php8.3-fpm mysql
systemctl enable nginx php8.3-fpm mysql

echo "→ إعداد Nginx لـ PHP..."
cat > /etc/nginx/sites-available/hisab << 'EOF'
server {
    listen 80 default_server;
    root /var/www/html;
    index index.html index.php;

    location / { try_files $uri $uri/ /index.html; }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }
}
EOF

ln -sf /etc/nginx/sites-available/hisab /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "→ إنشاء قاعدة البيانات..."
mysql -u root << 'SQLEOF'
CREATE DATABASE IF NOT EXISTS hisabpro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hisabpro;
CREATE TABLE IF NOT EXISTS app_data (
    id INT NOT NULL DEFAULT 1,
    data_json LONGTEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS settings (
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT NOT NULL,
    PRIMARY KEY (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT IGNORE INTO settings VALUES
('credentials','{"username":"admin","password":"admin123","name":"مدير النظام"}'),
('company','{"name":"شركتي","phone":"","email":"","address":""}');
INSERT IGNORE INTO app_data (id, data_json) VALUES
(1,'{"invoices":[],"customers":[],"expenses":[],"products":[],"nextInv":1,"nextCust":1,"nextExp":1,"nextProd":1}');
SQLEOF

echo "→ ضبط صلاحيات المجلد..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo ""
echo "✅ انتهى التثبيت!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  الموقع: http://$(hostname -I | awk '{print $1}')"
echo "  المستخدم: admin"
echo "  كلمة المرور: admin123"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
