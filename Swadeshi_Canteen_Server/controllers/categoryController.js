const Category = require('../models/category');
const superCategory = require('../models/superCategory')
// Create a new category
exports.createCategory = async (req, res) => {
    const { categoryId,name,superCategoryId, description,imageUrl } = req.body;

    try {
        const superCategoryexists = await superCategory.findOne({superCategoryId:superCategoryId});
        if(!superCategoryexists){
            return res.status(400).json({ error: 'Invalid superCategoryId: superCategory not found' });
        }
        const category = new Category({ categoryId:categoryId,name:name,superCategoryId:superCategoryId, description:description,imageUrl:imageUrl });
        await category.save();
        res.status(201).json({ message: 'Category created successfully', category });
    } catch (err) {
        res.status(400).json({ message: 'Error creating category', error: err.message });
    }
};

// Get all categories
exports.getAllCategories = async (req, res) => {
    try {
        const categories = await Category.find();
        res.json(categories);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Get category by ID
exports.getCategoryById = async (req, res) => {
    const { id } = req.params;

    try {
        const category = await Category.findOne({categoryId:id});
        if (!category) return res.status(404).json({ message: 'Category not found' });
        res.json(category);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};
// Get all categories by super category id
exports.getSuperCategoryCategories = async (req, res) => {
    const{ id } = req.params; 
    try {
        const superCat = await Category.find({superCategoryId:id});
        res.json(superCat);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};
// Update a category
exports.updateCategory = async (req, res) => {
    const { id } = req.params;
    const { superCategoryId } = req.body;
    try {
        if (superCategoryId) {
            const existingSuperCategory = await superCategory.findOne({ superCategoryId:superCategoryId });

            // If superCategoryId is invalid, return an error response
            if (!existingSuperCategory) {
                return res.status(400).json({ 
                    message: 'Invalid superCategoryId. No  Super category with this ID exists.' 
                });
            }
        }
        const updatedCategory = await Category.updateOne({_id:id},{$set: req.body}, { new: true });
        if (updatedCategory.matchedCount==0) return res.status(404).json({ message: 'Category not found' });
        res.status(200).json({ message: 'Category updated successfully', updatedCategory });
    } catch (err) {
        res.status(400).json({ message: 'Error updating category', error: err.message });
    }

};

// Delete a category
exports.deleteCategory = async (req, res) => {
    const { id } = req.params;

    try {
        const deletedCategory = await Category.deleteOne({_id:id});
        if (deletedCategory.deletedCount==0) return res.status(404).json({ message: 'Category not found' });
        res.json({ message: 'Category deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }

};
