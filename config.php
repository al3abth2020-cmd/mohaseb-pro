<?php
// ════════════════════════════════════════
//  حساب برو — إعدادات قاعدة البيانات
//  عدّل هذه القيم بعد رفع الملفات
// ════════════════════════════════════════

define('DB_HOST', 'localhost');
define('DB_NAME', 'hisabpro');
define('DB_USER', 'root');        // ← غيّر إلى مستخدم MySQL
define('DB_PASS', '');            // ← أضف كلمة مرور MySQL

function getDB() {
    static $pdo = null;
    if ($pdo === null) {
        try {
            $pdo = new PDO(
                'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
                DB_USER, DB_PASS,
                [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4'
                ]
            );
        } catch (PDOException $e) {
            http_response_code(500);
            die(json_encode(['error' => 'DB connection failed: ' . $e->getMessage()]));
        }
    }
    return $pdo;
}
