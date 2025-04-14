const DeliveryFee = require('../models/deliveryfee');

// **1. Get Delivery Fee Configuration**
exports.getDeliveryFee = async (req, res) => {
  try {
    // Fetch the first document in the collection
    const deliveryFee = await DeliveryFee.findOne();
    if (!deliveryFee) {
      return res.status(404).json({ message: 'Delivery fee configuration not found' });
    }
    res.status(200).json(deliveryFee);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching delivery fee configuration', error });
  }
};

// **2. Update Delivery Fee Configuration**
exports.updateDeliveryFee = async (req, res) => {
  const { min_free_delivery, delivery_fee } = req.body;

  // Validate inputs
  if (min_free_delivery == null || delivery_fee == null) {
    return res.status(400).json({ message: 'Both min_free_delivery and delivery_fee are required' });
  }

  try {
    // Fetch the first document, or create a new one if it doesn't exist
    const deliveryFee = await DeliveryFee.findOneAndUpdate(
      {}, // No filter criteria; updates the first document
      { min_free_delivery, delivery_fee, updated_at: new Date() },
      { new: true, upsert: true } // Create if it doesn't exist
    );
    res.status(200).json({ message: 'Delivery fee configuration updated successfully', deliveryFee });
  } catch (error) {
    res.status(500).json({ message: 'Error updating delivery fee configuration', error });
  }
};
