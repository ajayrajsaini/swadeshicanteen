const express = require('express');
const categoryController = require('../controllers/categoryController');
const authenticate = require('../middleware/auth').authenticate;

const router = express.Router();

router.post('/', authenticate, categoryController.createCategory);
router.get('/', categoryController.getAllCategories);
router.get('/:id', categoryController.getCategoryById);
router.get('/super/:id',categoryController.getSuperCategoryCategories);
router.put('/:id', authenticate, categoryController.updateCategory);
router.delete('/:id', authenticate, categoryController.deleteCategory);

module.exports = router;
