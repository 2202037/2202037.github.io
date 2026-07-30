<?php
/**
 * GET /api/v1/blood_bank/inventory
 *
 * Public endpoint — returns current blood inventory for all blood groups.
 *
 * Response:
 *   {
 *     "success": true,
 *     "data": {
 *       "inventory": [
 *         { "id": 1, "blood_group": "A+", "quantity": 45, "last_updated": "..." },
 *         ...
 *       ]
 *     }
 *   }
 */

declare(strict_types=1);

require_once __DIR__ . '/../../../config/cors.php';
require_once __DIR__ . '/../../../config/response.php';
require_once __DIR__ . '/../../../config/database.php';

setCorsHeaders();
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendMethodNotAllowed();
}

// Optional blood_group filter.
$filter = strtoupper(trim($_GET['blood_group'] ?? ''));

try {
    $db = (new Database())->getConnection();

    if ($filter !== '') {
        $stmt = $db->prepare(
            'SELECT id, blood_group, quantity, last_updated
             FROM blood_inventory
             WHERE blood_group = :bg
             ORDER BY blood_group ASC'
        );
        $stmt->execute([':bg' => $filter]);
    } else {
        $stmt = $db->query(
            'SELECT id, blood_group, quantity, last_updated
             FROM blood_inventory
             ORDER BY blood_group ASC'
        );
    }

    $inventory = $stmt->fetchAll();

    // Cast types.
    foreach ($inventory as &$item) {
        $item['id']       = (int)$item['id'];
        $item['quantity'] = (int)$item['quantity'];
        // Classify availability.
        $item['availability'] = match(true) {
            $item['quantity'] === 0  => 'unavailable',
            $item['quantity'] <= 10  => 'critical',
            $item['quantity'] <= 25  => 'low',
            default                   => 'available',
        };
    }
    unset($item);

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur blood inventory] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Blood inventory retrieved successfully.', ['inventory' => $inventory]);
