const Category = require('../models/superCategory'); // Adjust the path as per your folder structure

// Create a new category
exports.createSuperCategory = async (req, res) => {
    try {
        const { superCategoryId, name, description, imageUrl } = req.body;

        // Create a new category
        const newCategory = new Category({
            superCategoryId,
            name,
            description,
            imageUrl
        });

        await newCategory.save();

        res.status(201).json({
            message: 'Category created successfully',
            category: newCategory
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get all categories
exports.getAllSuperCategories = async (req, res) => {
    try {
        const categories = await Category.find();
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a category by ID
exports.getSuperCategoryById = async (req, res) => {
    try {
        const { id } = req.params;
        const category = await Category.findById(id);

        if (!category) {
            return res.status(404).json({ message: 'Category not found' });
        }

        res.status(200).json(category);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update a category
exports.updateSuperCategory = async (req, res) => {
    try {
        const { id } = req.params;
        const { superCategoryId, name, description, imageUrl } = req.body;

        const updatedCategory = await Category.findByIdAndUpdate(
            id,
            {
                superCategoryId,
                name,
                description,
                imageUrl,
                updatedAt: Date.now()
            },
            { new: true, runValidators: true }
        );

        if (!updatedCategory) {
            return res.status(404).json({ message: 'Category not found' });
        }

        res.status(200).json({
            message: 'Category updated successfully',
            category: updatedCategory
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Delete a category
exports.deleteSuperCategory = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedCategory = await Category.findByIdAndDelete(id);

        if (!deletedCategory) {
            return res.status(404).json({ message: 'Category not found' });
        }

        res.status(200).json({ message: 'Category deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
