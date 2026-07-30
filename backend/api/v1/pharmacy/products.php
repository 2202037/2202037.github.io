<?php
/**
 * GET /api/v1/pharmacy/products
 *
 * Public endpoint — paginated list of pharmacy products.
 *
 * Query params (all optional):
 *   category — filter by category (exact match)
 *   search   — partial match on name/description
 *   page     — default 1
 *   limit    — default 10, max 50
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
$page     = max(1, (int)($_GET['page']     ?? 1));
$limit    = min(50, max(1, (int)($_GET['limit'] ?? 10)));
$offset   = ($page - 1) * $limit;
$category = trim($_GET['category'] ?? '');
$search   = trim($_GET['search']   ?? '');

$where  = ['p.is_active = 1'];
$params = [];

if ($category !== '') {
    $where[]             = 'p.category = :category';
    $params[':category'] = $category;
}
if ($search !== '') {
    $where[]                = '(p.name LIKE :search_name OR p.description LIKE :search_desc)';
    $params[':search_name'] = '%' . $search . '%';
    $params[':search_desc'] = '%' . $search . '%';
}

$whereSQL = 'WHERE ' . implode(' AND ', $where);

try {
    $db = (new Database())->getConnection();

    // Count.
    $countStmt = $db->prepare("SELECT COUNT(*) FROM pharmacy_products p {$whereSQL}");
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    // Products.
    $sql = "SELECT
        id, name, description, price, stock_quantity, category, image_url, created_at
    FROM pharmacy_products p
    {$whereSQL}
    ORDER BY p.name ASC
    LIMIT :limit OFFSET :offset";

    $queryParams = array_merge($params, [':limit' => $limit, ':offset' => $offset]);

    $stmt = $db->prepare($sql);
    foreach ($queryParams as $key => $val) {
        if (in_array($key, [':limit', ':offset'], true)) {
            $stmt->bindValue($key, $val, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $val);
        }
    }
    $stmt->execute();
    $products = $stmt->fetchAll();

    // Cast types.
    foreach ($products as &$p) {
        $p['id']             = (int)$p['id'];
        $p['price']          = (float)$p['price'];
        $p['stock_quantity'] = (int)$p['stock_quantity'];
        $p['in_stock']       = $p['stock_quantity'] > 0;
    }
    unset($p);

    // Distinct categories for filter UI.
    $catStmt = $db->query(
        'SELECT DISTINCT category FROM pharmacy_products WHERE is_active = 1 AND category IS NOT NULL ORDER BY category ASC'
    );
    $categories = $catStmt->fetchAll(PDO::FETCH_COLUMN);

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur products] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Products retrieved successfully.', [
    'products'   => $products,
    'categories' => $categories,
], [
    'page'        => $page,
    'limit'       => $limit,
    'total'       => $total,
    'total_pages' => (int)ceil($total / $limit),
]);
