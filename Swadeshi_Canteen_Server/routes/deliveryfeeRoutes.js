const express = require('express');
const router = express.Router();
const deliveryFeeController = require('../controllers/deliveryfeeController');

// Route to get the current delivery fee configuration
router.get('/', deliveryFeeController.getDeliveryFee);

// Route to update the delivery fee configuration
router.put('/', deliveryFeeController.updateDeliveryFee);

module.exports = router;
