const express = require('express');
const router = express.Router();
const addressController = require('../controllers/addressController');


router.post('/', addressController.addAddress);
router.get('/:id',addressController.getAddresses);
router.put('/:id',addressController.updateAddress);
router.delete('/:id',addressController.deleteAdress);
router.get('/getAddress/:id',addressController.getAddress);

module.exports = router;