// controllers/carouselController.js
const Carousel = require('../models/carousel');

// Fetch all carousel items
exports.getCarousels = async (req, res) => {
  try {
    const carousels = await Carousel.find();
    res.status(200).json({ carousels });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching carousel items', error });
  }
};

// Create a new carousel item
exports.createCarousel = async (req, res) => {
  const { title, imageUrl, description, route } = req.body;

  try {
    const newCarousel = new Carousel({
      title,
      imageUrl,
      description,
      route
    });
    await newCarousel.save();
    res.status(201).json({ message: 'Carousel item created successfully', newCarousel });
  } catch (error) {
    res.status(500).json({ message: 'Error creating carousel item', error });
  }
};

// Update an existing carousel item
exports.updateCarousel = async (req, res) => {
  const { id } = req.params;
  const { title, imageUrl, description, route } = req.body;

  try {
    const updatedCarousel = await Carousel.findByIdAndUpdate(
      id,
      { title, imageUrl, description, route },
      { new: true }
    );
    if (!updatedCarousel) {
      return res.status(404).json({ message: 'Carousel item not found' });
    }
    res.status(200).json({ message: 'Carousel item updated successfully', updatedCarousel });
  } catch (error) {
    res.status(500).json({ message: 'Error updating carousel item', error });
  }
};

// Delete a carousel item
exports.deleteCarousel = async (req, res) => {
  const { id } = req.params;

  try {
    const deletedCarousel = await Carousel.findByIdAndDelete(id);
    if (!deletedCarousel) {
      return res.status(404).json({ message: 'Carousel item not found' });
    }
    res.status(200).json({ message: 'Carousel item deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting carousel item', error });
  }
};
