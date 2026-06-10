<?php
// ════════════════════════════════════════
//  حساب برو — API الخلفي
// ════════════════════════════════════════

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

require_once 'config.php';

$action = $_GET['action'] ?? '';
$body   = json_decode(file_get_contents('php://input'), true) ?? [];

// ── دالة مساعدة ──────────────────────────────────────
function res($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

$db = getDB();

switch ($action) {

    // ── تحميل كل البيانات ────────────────────────────
    case 'load':
        $row = $db->query('SELECT data_json FROM app_data WHERE id=1')->fetch();
        res(json_decode($row['data_json'], true));

    // ── حفظ كل البيانات ──────────────────────────────
    case 'save':
        if (empty($body)) res(['error' => 'No data'], 400);
        $json = json_encode($body, JSON_UNESCAPED_UNICODE);
        $stmt = $db->prepare('INSERT INTO app_data (id, data_json) VALUES (1, ?) ON DUPLICATE KEY UPDATE data_json=?');
        $stmt->execute([$json, $json]);
        res(['ok' => true]);

    // ── تسجيل الدخول ─────────────────────────────────
    case 'login':
        $u = strtolower(trim($body['username'] ?? ''));
        $p = $body['password'] ?? '';
        $row = $db->query("SELECT setting_value FROM settings WHERE setting_key='credentials'")->fetch();
        $creds = json_decode($row['setting_value'], true);
        if (strtolower($creds['username']) === $u && $creds['password'] === $p) {
            res(['ok' => true, 'name' => $creds['name'], 'username' => $creds['username']]);
        } else {
            res(['ok' => false], 401);
        }

    // ── تحميل الإعدادات ───────────────────────────────
    case 'get_settings':
        $rows = $db->query("SELECT setting_key, setting_value FROM settings")->fetchAll();
        $out = [];
        foreach ($rows as $r) $out[$r['setting_key']] = json_decode($r['setting_value'], true);
        res($out);

    // ── حفظ بيانات الدخول ────────────────────────────
    case 'save_credentials':
        $json = json_encode($body, JSON_UNESCAPED_UNICODE);
        $stmt = $db->prepare("INSERT INTO settings (setting_key, setting_value) VALUES ('credentials',?) ON DUPLICATE KEY UPDATE setting_value=?");
        $stmt->execute([$json, $json]);
        res(['ok' => true]);

    // ── حفظ بيانات الشركة ────────────────────────────
    case 'save_company':
        $json = json_encode($body, JSON_UNESCAPED_UNICODE);
        $stmt = $db->prepare("INSERT INTO settings (setting_key, setting_value) VALUES ('company',?) ON DUPLICATE KEY UPDATE setting_value=?");
        $stmt->execute([$json, $json]);
        res(['ok' => true]);

    default:
        res(['error' => 'Unknown action'], 400);
}
