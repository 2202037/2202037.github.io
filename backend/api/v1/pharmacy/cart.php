<?php
/**
 * Cart endpoints. Authorization: Bearer <token> required for all methods.
 *
 * GET    /api/v1/pharmacy/cart        — get user's cart
 * POST   /api/v1/pharmacy/cart        — add/update item in cart
 * DELETE /api/v1/pharmacy/cart        — remove item from cart
 *
 * POST body:   { "product_id": 1, "quantity": 2 }
 * DELETE body: { "product_id": 1 }    OR   { "cart_item_id": 5 }
 */

declare(strict_types=1);

require_once __DIR__ . '/../../../config/cors.php';
require_once __DIR__ . '/../../../config/response.php';
require_once __DIR__ . '/../../../config/database.php';
require_once __DIR__ . '/../../../helpers/jwt.php';
require_once __DIR__ . '/../../../helpers/validator.php';

setCorsHeaders();
header('Content-Type: application/json; charset=utf-8');

$method = $_SERVER['REQUEST_METHOD'];

if (!in_array($method, ['GET', 'POST', 'DELETE'], true)) {
    sendMethodNotAllowed();
}

// --- Auth ---
$auth   = requireAuth();
$userId = (int)$auth['user_id'];

try {
    $db = (new Database())->getConnection();
} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
}

// ============================================================
// GET — return cart
// ============================================================
if ($method === 'GET') {
    $stmt = $db->prepare(
        'SELECT
            c.id         AS cart_item_id,
            c.product_id,
            c.quantity,
            c.added_at,
            p.name,
            p.description,
            p.price,
            p.stock_quantity,
            p.category,
            p.image_url,
            (c.quantity * p.price) AS line_total
         FROM cart c
         JOIN pharmacy_products p ON p.id = c.product_id
         WHERE c.user_id = :user_id
         ORDER BY c.added_at DESC'
    );
    $stmt->execute([':user_id' => $userId]);
    $items = $stmt->fetchAll();

    $grandTotal = 0.0;
    foreach ($items as &$item) {
        $item['cart_item_id']   = (int)$item['cart_item_id'];
        $item['product_id']     = (int)$item['product_id'];
        $item['quantity']       = (int)$item['quantity'];
        $item['price']          = (float)$item['price'];
        $item['stock_quantity'] = (int)$item['stock_quantity'];
        $item['line_total']     = (float)$item['line_total'];
        $grandTotal            += $item['line_total'];
    }
    unset($item);

    sendSuccess('Cart retrieved successfully.', [
        'items'       => $items,
        'grand_total' => round($grandTotal, 2),
        'item_count'  => count($items),
    ]);
}

// ============================================================
// POST — add / update cart item
// ============================================================
if ($method === 'POST') {
    $body = getRequestBody();

    $v = new Validator($body);
    $v->required(['product_id', 'quantity'])
      ->positiveInt('product_id')
      ->positiveInt('quantity');

    if ($v->fails()) {
        sendError('Validation failed.', 422, $v->errors());
    }

    $productId = (int)$body['product_id'];
    $quantity  = (int)$body['quantity'];

    // Verify product exists and has sufficient stock.
    $prodStmt = $db->prepare(
        'SELECT id, stock_quantity FROM pharmacy_products WHERE id = :id AND is_active = 1 LIMIT 1'
    );
    $prodStmt->execute([':id' => $productId]);
    $product = $prodStmt->fetch();

    if (!$product) {
        sendNotFound('Product not found or unavailable.');
    }
    if ((int)$product['stock_quantity'] < $quantity) {
        sendError("Insufficient stock. Only {$product['stock_quantity']} unit(s) available.", 409);
    }

    // Upsert.
    $upsert = $db->prepare(
        'INSERT INTO cart (user_id, product_id, quantity)
         VALUES (:user_id, :product_id, :quantity)
         ON DUPLICATE KEY UPDATE quantity = :quantity2'
    );
    $upsert->execute([
        ':user_id'    => $userId,
        ':product_id' => $productId,
        ':quantity'   => $quantity,
        ':quantity2'  => $quantity,
    ]);

    // Return updated cart item.
    $fetch = $db->prepare(
        'SELECT c.id AS cart_item_id, c.product_id, c.quantity, c.added_at,
                p.name, p.price, p.image_url, (c.quantity * p.price) AS line_total
         FROM cart c
         JOIN pharmacy_products p ON p.id = c.product_id
         WHERE c.user_id = :user_id AND c.product_id = :product_id
         LIMIT 1'
    );
    $fetch->execute([':user_id' => $userId, ':product_id' => $productId]);
    $item = $fetch->fetch();

    $item['cart_item_id'] = (int)$item['cart_item_id'];
    $item['product_id']   = (int)$item['product_id'];
    $item['quantity']     = (int)$item['quantity'];
    $item['price']        = (float)$item['price'];
    $item['line_total']   = (float)$item['line_total'];

    sendSuccess('Item added to cart.', ['item' => $item], [], 201);
}

// ============================================================
// DELETE — remove cart item
// ============================================================
if ($method === 'DELETE') {
    $body = getRequestBody();

    // Accept either product_id or cart_item_id.
    if (!empty($body['cart_item_id'])) {
        $v = new Validator($body);
        $v->positiveInt('cart_item_id');
        if ($v->fails()) {
            sendError('Validation failed.', 422, $v->errors());
        }

        $stmt = $db->prepare(
            'DELETE FROM cart WHERE id = :id AND user_id = :user_id'
        );
        $stmt->execute([':id' => (int)$body['cart_item_id'], ':user_id' => $userId]);
    } elseif (!empty($body['product_id'])) {
        $v = new Validator($body);
        $v->positiveInt('product_id');
        if ($v->fails()) {
            sendError('Validation failed.', 422, $v->errors());
        }

        $stmt = $db->prepare(
            'DELETE FROM cart WHERE product_id = :product_id AND user_id = :user_id'
        );
        $stmt->execute([':product_id' => (int)$body['product_id'], ':user_id' => $userId]);
    } else {
        sendError('Provide cart_item_id or product_id to remove.', 422);
    }

    if ($stmt->rowCount() === 0) {
        sendNotFound('Cart item not found.');
    }

    sendSuccess('Item removed from cart.');
}
