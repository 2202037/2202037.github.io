<?php
/**
 * GET /api/v1/directory/clinics
 *
 * Query parameters (all optional):
 *   lat    — user latitude  (for distance / nearby sort)
 *   lng    — user longitude
 *   search — partial name/address match
 *   page   — page number (default 1)
 *   limit  — results per page (default 10, max 50)
 *
 * When lat & lng are provided, results are sorted by proximity (Haversine).
 */

declare(strict_types=1);

require_once __DIR__ . '/../../../config/cors.php';
require_once __DIR__ . '/../../../config/response.php';
require_once __DIR__ . '/../../../config/database.php';
require_once __DIR__ . '/../../../helpers/validator.php';

setCorsHeaders();
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendMethodNotAllowed();
}

// --- Params ---
$page    = max(1, (int)($_GET['page']  ?? 1));
$limit   = min(50, max(1, (int)($_GET['limit'] ?? 10)));
$offset  = ($page - 1) * $limit;
$search  = trim($_GET['search'] ?? '');
$userLat = isset($_GET['lat']) && is_numeric($_GET['lat']) ? (float)$_GET['lat'] : null;
$userLng = isset($_GET['lng']) && is_numeric($_GET['lng']) ? (float)$_GET['lng'] : null;

// Build WHERE.
$where  = ['1=1'];
$params = [];

if ($search !== '') {
    $where[]                   = '(c.name LIKE :search_name OR c.address LIKE :search_addr)';
    $params[':search_name']    = '%' . $search . '%';
    $params[':search_addr']    = '%' . $search . '%';
}

$whereSQL = 'WHERE ' . implode(' AND ', $where);

// Haversine formula (returns km).
// :ulat appears twice in the formula (COS and SIN terms); PDO native mode
// requires distinct parameter names for each occurrence, hence :ulat2.
$distanceExpr = ($userLat !== null && $userLng !== null)
    ? "(6371 * ACOS(
          COS(RADIANS(:ulat)) * COS(RADIANS(c.latitude)) *
          COS(RADIANS(c.longitude) - RADIANS(:ulng)) +
          SIN(RADIANS(:ulat2)) * SIN(RADIANS(c.latitude))
       ))"
    : 'NULL';

$orderBy = ($userLat !== null && $userLng !== null)
    ? "ORDER BY distance_km ASC"
    : "ORDER BY c.rating DESC";

try {
    $db = (new Database())->getConnection();

    // Count.
    $countSql  = "SELECT COUNT(*) FROM clinics c {$whereSQL}";
    $countStmt = $db->prepare($countSql);
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    // Data — wrap in subquery so we can ORDER BY alias.
    $innerSQL = "SELECT
        c.id,
        c.name,
        c.address,
        c.phone,
        c.email,
        c.latitude,
        c.longitude,
        c.opening_time,
        c.closing_time,
        c.image_url,
        c.rating,
        {$distanceExpr} AS distance_km,
        (SELECT COUNT(*) FROM doctors d WHERE d.clinic_id = c.id AND d.is_available = 1) AS available_doctors
    FROM clinics c
    {$whereSQL}";

    $outerSQL = "SELECT * FROM ({$innerSQL}) AS sub {$orderBy} LIMIT :limit OFFSET :offset";

    $queryParams = $params;
    if ($userLat !== null && $userLng !== null) {
        $queryParams[':ulat']  = $userLat;
        $queryParams[':ulng']  = $userLng;
        $queryParams[':ulat2'] = $userLat;
    }
    $queryParams[':limit']  = $limit;
    $queryParams[':offset'] = $offset;

    $stmt = $db->prepare($outerSQL);
    foreach ($queryParams as $key => $val) {
        if (in_array($key, [':limit', ':offset'], true)) {
            $stmt->bindValue($key, $val, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $val);
        }
    }
    $stmt->execute();
    $clinics = $stmt->fetchAll();

    // Cast types.
    foreach ($clinics as &$c) {
        $c['id']                = (int)$c['id'];
        $c['rating']            = (float)$c['rating'];
        $c['latitude']          = $c['latitude'] !== null  ? (float)$c['latitude']  : null;
        $c['longitude']         = $c['longitude'] !== null ? (float)$c['longitude'] : null;
        $c['distance_km']       = $c['distance_km'] !== null ? round((float)$c['distance_km'], 2) : null;
        $c['available_doctors'] = (int)$c['available_doctors'];
    }
    unset($c);

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur clinics] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Clinics retrieved successfully.', ['clinics' => $clinics], [
    'page'        => $page,
    'limit'       => $limit,
    'total'       => $total,
    'total_pages' => (int)ceil($total / $limit),
]);
