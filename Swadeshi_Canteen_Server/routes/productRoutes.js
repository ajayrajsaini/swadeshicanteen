const express = require('express');
const productController = require('../controllers/productController');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.post('/', authenticate, productController.createProduct);
router.get('/category/:id', productController.getCategoryProducts);       //get all products by id
router.get('/',productController.getAllProducts);
router.get('/:id', productController.getProductById);
router.put('/:id', authenticate, productController.updateProduct);
router.delete('/:id', authenticate, productController.deleteProduct);

module.exports = router;
