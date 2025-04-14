const Slider = require('../models/slider');
const Product = require('../models/product');

// Create a new slider
exports.createSlider = async (req, res) => {
    try {
        const { title, numberOfProducts, showViewAll, products } = req.body;

        // Validate product existence
        const productList = await Product.find({ productId: { $in: products } });
        if (productList.length !== products.length) {
            return res.status(400).json({ error: 'One or more products not found.' });
        }

        const slider = new Slider({
            title,
            numberOfProducts,
            showViewAll,
            products
        });

        await slider.save();
        res.status(201).json({ message: 'Slider created successfully', slider });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

// Get a single slider by ID
exports.getSliderById = async (req, res) => {
    try {
        const slider = await Slider.findById(req.params.id).populate('products');
        if (!slider) {
            return res.status(404).json({ error: 'Slider not found' });
        }
        res.status(200).json(slider);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

// Update an existing slider
exports.updateSlider = async (req, res) => {
    try {
        const { title, numberOfProducts, showViewAll, products } = req.body;

        // Validate product existence
        const productList = await Product.find({ productId: { $in: products } });
        if (productList.length !== products.length) {
            return res.status(400).json({ error: 'One or more products not found.' });
        }

        const slider = await Slider.findByIdAndUpdate(req.params.id, {
            title,
            numberOfProducts,
            showViewAll,
            products
        }, { new: true });
        if (!slider) {
            return res.status(404).json({ error: 'Slider not found' });
        }

        res.status(200).json({ message: 'Slider updated successfully', slider });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

// Delete a slider
exports.deleteSlider = async (req, res) => {
    try {
        const slider = await Slider.findByIdAndDelete(req.params.id);
        if (!slider) {
            return res.status(404).json({ error: 'Slider not found' });
        }
        res.status(200).json({ message: 'Slider deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

// Get all sliders
exports.getAllSliders = async (req, res) => {
    try {
        const sliders = await Slider.find().populate('products');
        res.status(200).json(sliders);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};
