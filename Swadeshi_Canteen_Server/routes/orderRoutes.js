const express = require('express');
const orderController = require('../controllers/orderController');
const  authenticate  = require('../middleware/auth').authenticate;

const router = express.Router();

router.get('/allOrder',orderController.getAllOrders);
router.post('/', orderController.createOrder);
router.get('/:id', orderController.getOrderById);
router.get('/allOrder/:id',orderController.getUserOrders);
router.put('/updateOrder/:id',orderController.updateOrder);
router.put('/assignOrder/',orderController.assignOrder);

module.exports = router;
