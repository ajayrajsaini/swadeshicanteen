const Order = require('../models/order');
const Cart = require('../models/cart');
const User = require('../models/User');
const Address = require('../models/address')
const Delivery = require('../models/deliveryfee')
// Create a new order
exports.createOrder = async (req, res) => {

    try {
        const { user, paymentMethod, addressId } = req.body;
        const address = await Address.findById(addressId);
        if (!address) {
            return res.status(404).json({ message: 'Address not found' });
        }
        const cart = await Cart.findOne({ user: user });
        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ message: 'Cart is empty' });
        }
        const delivery = await Delivery.findOne();
        if(cart.totalPrice<delivery.min_free_delivery){
            cart.totalPrice += delivery.delivery_fee;
        }
        const order = new Order({
            user: user,
            items: cart.items,
            totalPrice: cart.totalPrice,
            deliveryAddress: `${address.name},${address.addressLine1}, ${address.addressLine2}, ${address.city}, ${address.state}, ${address.postalCode},${address.phoneNumber}`,
            paymentMethod: paymentMethod,
            paymentStatus: 'Pending',
            orderStatus: 'Pending'
        });
        const savedOrder = await order.save();
        cart.items = [];
        await cart.save();
        res.status(201).json({ message: 'Order Placed successfully', savedOrder });
    } catch (err) {
        res.status(400).json({ message: 'Error creating order', error: err.message });
    }
};

// Get all orders for a user
exports.getUserOrders = async (req, res) => {
    try {
        const orders = await Order.find({ user: req.params.id });
        res.status(200).json({ message: 'Order fetched Successfully', orders });
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Get order by ID
exports.getOrderById = async (req, res) => {
    const { id } = req.params;

    try {
        const order = await Order.findById(id);
        if (!order) return res.status(404).json({ message: 'Order not found' });
        res.status(200).json({ message: 'Order fetched Successfully', order });
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

//update Order status
exports.updateOrder = async (req, res) => {
    try {
        const { orderStatus, paymentStatus } = req.body;

        const order = await Order.findById(req.params.id);
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        if (orderStatus) order.orderStatus = orderStatus;
        if (paymentStatus) order.paymentStatus = paymentStatus;
        if (orderStatus === 'Delivered') {
            order.deliveredAt = new Date(); // Update the delivery time when marked as delivered
        }

        const updatedOrder = await order.save();
        res.status(200).json(updatedOrder);
    } catch (error) {
        res.status(500).json({ message: 'Error updating order status', error: error.message });
    }
}

//Get all orders
exports.getAllOrders = async (req, res) => {
    try {
        const orders = await Order.find();
        return res.status(200).json({ message: 'Orders Fetched', orders });
    } catch (err) {
        res.status(400).json({ message: 'Error fetching orders', error: err.message });
    }
}

//Assign Order to delievery boy
exports.assignOrder = async (req, res) => {
    try {
        const { orderId, deliveryBoyId } = req.body;
        // const adminId = req.params.id;  // Assume the admin making the request has their ID in req.userId

        // // 1. Check if the admin user has the right role
        // const adminUser = await User.findById(adminId);
        // if (!adminUser || (adminUser.role !== 'Admin' && adminUser.role !== 'SuperUser')) {
        //     return res.status(403).json({ message: 'Unauthorized: Only Admins or SuperUsers can assign orders' });
        // }

        // 2. Check if the order exists
        const order = await Order.findById(orderId);
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        // 3. Check if the delivery boy exists and has the 'DeliveryBoy' role
        const deliveryBoy = await User.findById(deliveryBoyId);
        if (!deliveryBoy || deliveryBoy.role !== 'DeliveryBoy') {
            return res.status(404).json({ message: 'Delivery boy not found or role is incorrect' });
        }

        // 4. Check if the delivery boy is available
        //   if (deliveryBoy.status !== 'available') {
        //     return res.status(400).json({ message: 'Delivery boy is not available' });
        //   }

        // 5. Assign the order to the delivery boy
        order.assignedDeliveryBoy = deliveryBoyId;
        order.orderStatus = 'assigned';

        // Mark the delivery boy as busy
        //   deliveryBoy.status = 'busy';

        // Save the updates to both the order and the delivery boy
        await order.save();
        await deliveryBoy.save();

        // (Optional) Send a notification to the delivery boy about the new assignment

        res.status(200).json({ message: 'Order assigned successfully', order });
    } catch (error) {
        console.error('Error assigning order:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};