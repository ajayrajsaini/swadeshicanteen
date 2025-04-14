const express = require('express');
const router = express.Router();
const sliderController = require('../controllers/sliderController');

// Route to create a new slider
router.post('/', sliderController.createSlider);

// Route to get a single slider by ID
router.get('/:id', sliderController.getSliderById);

// Route to update a slider by ID
router.put('/:id', sliderController.updateSlider);

// Route to delete a slider by ID
router.delete('/:id', sliderController.deleteSlider);

// Route to get all sliders
router.get('/', sliderController.getAllSliders);

module.exports = router;
