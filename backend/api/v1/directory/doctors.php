<?php
/**
 * GET /api/v1/directory/doctors
 *
 * Query parameters (all optional):
 *   specialty  — filter by specialty (partial match)
 *   search     — search in doctor name (partial match)
 *   lat        — user latitude  (for distance calculation)
 *   lng        — user longitude (for distance calculation)
 *   page       — page number (default 1)
 *   limit      — results per page (default 10, max 50)
 *
 * Response includes doctor info, clinic info, and distance (km) if lat/lng supplied.
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

// --- Pagination & filters ---
$page      = max(1, (int)($_GET['page']  ?? 1));
$limit     = min(50, max(1, (int)($_GET['limit'] ?? 10)));
$offset    = ($page - 1) * $limit;
$specialty = trim($_GET['specialty'] ?? '');
$search    = trim($_GET['search']    ?? '');
$userLat   = isset($_GET['lat']) && is_numeric($_GET['lat']) ? (float)$_GET['lat'] : null;
$userLng   = isset($_GET['lng']) && is_numeric($_GET['lng']) ? (float)$_GET['lng'] : null;

// Build WHERE clauses.
$where  = ['d.is_available = 1'];
$params = [];

if ($specialty !== '') {
    $where[]              = 'd.specialty LIKE :specialty';
    $params[':specialty'] = '%' . $specialty . '%';
}
if ($search !== '') {
    $where[]           = 'u.name LIKE :search';
    $params[':search'] = '%' . $search . '%';
}

$whereSQL = 'WHERE ' . implode(' AND ', $where);

// Haversine formula as a SQL expression (returns km).
// :ulat appears twice in the formula (COS and SIN terms); PDO native mode
// requires distinct parameter names for each occurrence, hence :ulat2.
$distanceExpr = ($userLat !== null && $userLng !== null)
    ? "(6371 * ACOS(
          COS(RADIANS(:ulat)) * COS(RADIANS(d.latitude)) *
          COS(RADIANS(d.longitude) - RADIANS(:ulng)) +
          SIN(RADIANS(:ulat2)) * SIN(RADIANS(d.latitude))
       ))"
    : 'NULL';

try {
    $db = (new Database())->getConnection();

    // Total count.
    $countSql  = "SELECT COUNT(*) FROM doctors d
                  JOIN users u ON u.id = d.user_id
                  {$whereSQL}";
    $countStmt = $db->prepare($countSql);
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    // Build main query.
    $selectSql = "SELECT
        d.id            AS doctor_id,
        u.id            AS user_id,
        u.name          AS doctor_name,
        u.phone,
        u.profile_image,
        d.specialty,
        d.fee,
        d.bio,
        d.experience_years,
        d.image_url,
        d.is_available,
        d.rating,
        d.latitude,
        d.longitude,
        c.id            AS clinic_id,
        c.name          AS clinic_name,
        c.address       AS clinic_address,
        c.phone         AS clinic_phone,
        {$distanceExpr} AS distance_km
    FROM doctors d
    JOIN users u   ON u.id = d.user_id
    LEFT JOIN clinics c ON c.id = d.clinic_id
    {$whereSQL}
    ORDER BY d.rating DESC
    LIMIT :limit OFFSET :offset";

    $queryParams = $params;
    if ($userLat !== null && $userLng !== null) {
        $queryParams[':ulat']  = $userLat;
        $queryParams[':ulng']  = $userLng;
        $queryParams[':ulat2'] = $userLat;
    }
    $queryParams[':limit']  = $limit;
    $queryParams[':offset'] = $offset;

    $stmt = $db->prepare($selectSql);

    // Bind integer params explicitly to avoid PDO string-quoting them.
    foreach ($queryParams as $key => $val) {
        if (in_array($key, [':limit', ':offset'], true)) {
            $stmt->bindValue($key, $val, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $val);
        }
    }
    $stmt->execute();
    $doctors = $stmt->fetchAll();

    // Cast types.
    foreach ($doctors as &$doc) {
        $doc['doctor_id']        = (int)$doc['doctor_id'];
        $doc['user_id']          = (int)$doc['user_id'];
        $doc['fee']              = (float)$doc['fee'];
        $doc['experience_years'] = (int)$doc['experience_years'];
        $doc['is_available']     = (bool)$doc['is_available'];
        $doc['rating']           = (float)$doc['rating'];
        $doc['latitude']         = $doc['latitude'] !== null  ? (float)$doc['latitude']  : null;
        $doc['longitude']        = $doc['longitude'] !== null ? (float)$doc['longitude'] : null;
        $doc['clinic_id']        = $doc['clinic_id'] !== null ? (int)$doc['clinic_id']   : null;
        $doc['distance_km']      = $doc['distance_km'] !== null ? round((float)$doc['distance_km'], 2) : null;
    }
    unset($doc);

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur doctors] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Doctors retrieved successfully.', ['doctors' => $doctors], [
    'page'        => $page,
    'limit'       => $limit,
    'total'       => $total,
    'total_pages' => (int)ceil($total / $limit),
]);
