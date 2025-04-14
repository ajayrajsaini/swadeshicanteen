const Address = require('../models/address');

exports.addAddress = async (req, res) => {
    try {
        const { name,user, label, addressLine1, addressLine2, city, state, postalCode, phoneNumber, isDefault } = req.body;
        // Validate required fields
        if (!name||!label || !addressLine1 || !city || !state || !postalCode || !phoneNumber) {
            return res.status(400).json({ message: "All required fields must be provided" });
        }
        // If the user sets the new address as default, make sure other addresses are updated
        const addresses = await Address.find({ user: user });
        if (isDefault) {
            await Address.updateMany(
                { user: user },
                { $set: { isDefault: false } }  // Unset previous default addresses
            );
        }

        const newAddress = new Address({
            name:name,
            user: user,
            label: label,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            state: state,
            postalCode: postalCode,
            phoneNumber: phoneNumber,
            isDefault: isDefault || addresses.length === 0
        });

        const savedAddress = await newAddress.save();
        res.status(201).json({ message: "Address Saved Successfully", savedAddress });
    } catch (error) {
        res.status(500).json({ message: 'Error saving address', error: error.message });
    }
}

exports.getAddresses = async (req, res) => {
    try {
        const userId = req.params.id;
        const addresses = await Address.find({ user: userId });
        res.status(200).json(addresses);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching addresses', error: error.message });
    }
}

exports.updateAddress = async (req, res) => {
    try {
        const addressId = req.params.id;
        const { name,user, label, addressLine1, addressLine2, city, state, postalCode, phoneNumber, isDefault } = req.body;

        // If the user sets the address as default, unset the other defaults
        if (isDefault) {
            await Address.updateMany(
                { user: user },
                { $set: { isDefault: false } }  // Unset previous default addresses
            );
        }

        const updatedAddress = await Address.findOneAndUpdate(
            { _id: addressId, user: user },  // Ensure the address belongs to the user
            { name,label, addressLine1, addressLine2, city, state, postalCode, phoneNumber, isDefault },
            { new: true }  // Return the updated document
        );

        if (!updatedAddress) {
            return res.status(404).json({ message: 'Address not found' });
        }

        res.status(200).json({ message: "Address Updated", updatedAddress });
    } catch (error) {
        res.status(500).json({ message: 'Error updating address', error: error.message });
    }
}

exports.deleteAdress = async (req, res) => {
    try {
        const addressId = req.params.id;
        const deletedAddress = await Address.findOneAndDelete({ _id: addressId });
        if (!deletedAddress) {
            return res.status(404).json({ message: 'Address not found' });
        }
         // Check if the deleted address was the default
         if (deletedAddress.isDefault) {
            // Find the user's other addresses
            const remainingAddresses = await Address.find({ user: deletedAddress.user });

            if (remainingAddresses.length > 0) {
                // If other addresses are available, make the first one default
                remainingAddresses[0].isDefault = true;
                await remainingAddresses[0].save();
            }
        }

        res.status(200).json({ message: 'Address deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting address', error: error.message });
    }
}

exports.getAddress = async(req,res) => {
    try{
        const addressId = req.params.id;

        const userAddress = await Address.findOne({ _id: addressId });
        if (!userAddress) {
            return res.status(404).json({ message: 'Address not found' });
        }

        res.status(200).json({message:'Address fetched successfully',userAddress});

    }catch (error){
        res.status(500).json({ message: 'Error fetching address', error: error.message });
    }
}