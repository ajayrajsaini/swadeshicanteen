const express = require('express');
const superCategoryController = require('../controllers/superCategoryController'); // Adjust path accordingly

const router = express.Router();

router.post('/', superCategoryController.createSuperCategory);
router.get('/', superCategoryController.getAllSuperCategories);
router.get('/:id', superCategoryController.getSuperCategoryById);
router.put('/:id', superCategoryController.updateSuperCategory);
router.delete('/:id', superCategoryController.deleteSuperCategory);

module.exports = router;
