const express = require('express');
const userController = require('../controllers/userController');
const authenticate = require('../middleware/auth').authenticate;
const router = express.Router();

router.get('/deliveryBoys',userController.fetchDeliveryBoy);
router.get('/all',authenticate,userController.getAllUser);
router.get ('/:emailOrPhone',userController.getUser);
router.post('/sendOtp',userController.sendOtp);
router.post('/', userController.registerUser);
router.post('/verify', userController.verifyUser);
router.post('/login', userController.loginUser);
router.put('/updateRole/',authenticate,userController.updateRole);



module.exports = router;
