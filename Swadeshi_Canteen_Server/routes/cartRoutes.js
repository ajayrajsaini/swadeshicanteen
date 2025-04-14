// routes/cartRoutes.js
const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');

// Add item to cart (POST /cart)
router.post('/', cartController.addToCart);

// Get user's cart (GET /cart)
router.get('/:emailOrPhone', cartController.getCart);

// Remove item from cart (DELETE /cart/:productId)
router.delete('/:productId', cartController.removeItem);

// Update item quantity in cart (PUT /cart/:productId)
router.put('/', cartController.updateItemQuantity);

module.exports = router;
