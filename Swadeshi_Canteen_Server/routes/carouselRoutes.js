// routes/carouselRoutes.js
const express = require('express');
const router = express.Router();
const carouselController = require('../controllers/carouselController');

// GET all carousel items
router.get('/', carouselController.getCarousels);

// POST a new carousel item
router.post('/', carouselController.createCarousel);

// PUT (update) a carousel item by ID
router.put('/:id', carouselController.updateCarousel);

// DELETE a carousel item by ID
router.delete('/:id', carouselController.deleteCarousel);

module.exports = router;
