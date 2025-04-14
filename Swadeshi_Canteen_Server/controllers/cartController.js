const Cart = require('../models/cart');
const Product = require('../models/product');


//addtoCart
exports.addToCart = async (req, res) => {


    try {
        const { user, productId, quantity } = req.body;
        // const searchCriteria = user.includes('@') ? { user: user } : { phone: user };
        const product = await Product.findOne({ productId: productId });
        if (!product) return res.status(404).json({ message: 'Product not found' });
        const price = product.price;
        let cart = await Cart.findOne({ user: user });
        if (cart) {
            // If cart exists, update it
            console.log("searching in ");
            const itemIndex = cart.items.findIndex(item => item.productId.toString() === productId.toString());
            if (itemIndex > -1) {
                // Item exists in the cart, update quantity and price
                cart.items[itemIndex].quantity += Number(quantity);
                cart.items[itemIndex].price = parseFloat(price) * parseInt(cart.items[itemIndex].quantity, 10); // Convert both to numbers
            } else {
                // Item does not exist, push new item to cart
                cart.items.push({ productId, quantity: parseInt(quantity, 10), price: price * parseInt(quantity, 10) });
            }
            // cart.totalQuantity = cart.items.reduce((total, item) => total + item.quantity, 0);
            cart.totalPrice = cart.items.reduce((total, item) => total + parseFloat(item.price), 0); // Ensure price is a number while summing
        } else {
            // Create a new cart if it doesn't exist
            cart = new Cart({
                user,
                items: [{ productId, quantity, price: price }],
                totalPrice: price * quantity
            });


        }
        await cart.save();
        return res.status(200).json(cart);
    } catch (err) {
        res.status(400).json({ message: 'Error while updating cart', error: err.message });
    }
};

//get cart
exports.getCart = async (req, res) => {
    try {
        const userId = req.params.emailOrPhone; // Assuming userId comes from the authenticated session
        const cart = await Cart.findOne({ user: userId });

        if (!cart) {
            return res.status(404).json({ message: 'Cart is empty' });
        }

        res.status(200).json(cart);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching cart', error });
    }
}

//remove item form cart
exports.removeItem = async (req, res) => {
    try {
        const { productId } = req.params;
        console.log("1");
        const userId = req.headers['user'];
        console.log(userId);
        const cart = await Cart.findOne({ user: userId });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }
        console.log("deleting now");
        const itemIndex = cart.items.findIndex(item => item.productId.toString() === productId);
        console.log("deleting");
        if (itemIndex > -1) {
            const item = cart.items[itemIndex];
            cart.totalQuantity -= item.quantity;
            cart.totalPrice -= item.price;
            cart.items.splice(itemIndex, 1);

            await cart.save();
            res.status(200).json(cart);
        } else {
            res.status(404).json({ message: 'Item not found in cart' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Error removing item from cart', error });
    }
};

//update item quantity
exports.updateItemQuantity = async (req, res) => {
    try {
        const { productId, quantity, user } = req.body;
        const cart = await Cart.findOne({ user }).populate('items.productId', 'price');
        if (!cart) return res.status(404).json({ message: 'Cart not found' });
        const product = await Product.findOne({ productId });
        const itemIndex = cart.items.findIndex(item => item.productId === productId);
        console.log(itemIndex);
        if (itemIndex > -1) {
            const cartItem = cart.items[itemIndex];
            const difference = parseInt(cart.totalPrice) - parseInt(cartItem.price);
            cartItem.quantity = Number(quantity);
            cartItem.price = Number(quantity) * parseInt(product.price);
            cart.totalPrice = difference + parseInt(cartItem.price);

            await cart.save();
            res.status(200).json(cart);
        } else {
            res.status(404).json({ message: 'Item not found in cart' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Error updating item quantity', error });
    }
}
