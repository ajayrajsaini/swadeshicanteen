const Product = require('../models/product');
const Category = require('../models/category');

// Create a new product
exports.createProduct = async (req, res) => {
    const { name, productId, description, price, mrp, categoryId, stock, imageUrl, additionalImages } = req.body;

    try {
        // Check if the category exists
        const categoryExists = await Category.findOne({ categoryId });
        if (!categoryExists) {
            return res.status(400).json({ error: 'Invalid categoryId: Category not found' });
        }

        // Validate additionalImages if provided
        if (additionalImages && !Array.isArray(additionalImages)) {
            return res.status(400).json({ error: 'Invalid additionalImages: Must be an array of strings' });
        }

        // Create a new product
        const product = new Product({
            name,
            productId,
            description,
            price,
            mrp,
            categoryId,
            stock,
            imageUrl,
            additionalImages
        });

        // Save the product
        await product.save();
        res.status(201).json({ message: 'Product created successfully', product });
    } catch (err) {
        res.status(400).json({ message: 'Error creating product', error: err.message });
    }

};

// Get all products by category id
exports.getCategoryProducts = async (req, res) => {
    const { id } = req.params;
    try {
        const products = await Product.find({ categoryId: id });
        res.json(products);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Get all products
exports.getAllProducts = async (req, res) => {
    try {
        const products = await Product.find({});
        res.json(products);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Get product by ID
exports.getProductById = async (req, res) => {
    const { id } = req.params;

    try {
        const product = await Product.findOne({ productId: id });
        if (!product) return res.status(404).json({ message: 'Product not found' });
        res.json(product);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Update a product
exports.updateProduct = async (req, res) => {
    const { id } = req.params;
    const { name, productId, description, price, mrp, categoryId, stock, imageUrl, additionalImages } = req.body;

    try {
        // Validate additionalImages if provided
        if (additionalImages && !Array.isArray(additionalImages)) {
            return res.status(400).json({ error: 'Invalid additionalImages: Must be an array of strings' });
        }

        // Check if the category exists if categoryId is provided
        if (categoryId) {
            const categoryExists = await Category.findOne({ categoryId });
            if (!categoryExists) {
                return res.status(400).json({ error: 'Invalid categoryId: Category not found' });
            }
        }

        // Find and update the product
        const updates = { name, productId, description, price, mrp, categoryId, stock, imageUrl, additionalImages };
        const updatedProduct = await Product.findByIdAndUpdate(id, updates, { new: true });

        if (!updatedProduct) {
            return res.status(404).json({ error: 'Product not found' });
        }

        res.status(200).json({ message: 'Product updated successfully', product: updatedProduct });
    } catch (err) {
        res.status(400).json({ message: 'Error updating product', error: err.message });
    }
};

// Delete a product
exports.deleteProduct = async (req, res) => {
    const { id } = req.params;

    try {
        const deletedProduct = await Product.findByIdAndDelete(id);
        if (!deletedProduct) return res.status(404).json({ message: 'Product not found' });
        res.json({ message: 'Product deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};
