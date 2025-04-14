const User = require('../models/User');
const Otp = require('../models/otpModel')
const crypto = require('crypto');
const { search } = require('../routes/userRoutes');
const sendVerificationCode = require('../utils/notification').sendVerificationCode; // Utility to send SMS or email

//sendOtp
exports.sendOtp = async (req, res) => {
  const { email, phone } = req.body;
  const identifier = email || phone;
  try {
    console.log("Generating Verification");
    const verificationCode = crypto.randomBytes(3).toString('hex'); // Generate a random verification code
    console.log("Generated Verification");
    // Send verification code
    console.log(identifier);
    const existingUser = await Otp.findOne({ $or: [{ email: identifier }, { phone: identifier }] });
    console.log(existingUser);
    if (existingUser) {
      console.log("Found existing user");
      existingUser.otp = verificationCode;
      await existingUser.save();
    } else {
      console.log("saving new Otp");
      let otpEntry;
      if (/\S+@\S+\.\S+/.test(identifier)) {
        // If identifier matches email pattern
        console.log("checking mail", identifier);
        otpEntry = new Otp({ email: identifier, otp: verificationCode });
      } else if (/^\d{10}$/.test(identifier)) {
        // If identifier matches phone number pattern, only save phone and exclude email
        console.log("checking phone", identifier);
        otpEntry = new Otp({ phone: identifier, otp: verificationCode });
      } else {
        return res.status(400).json({ message: 'Invalid email or phone number format.' });
      }
      console.log("saving in mongoDB");
      await otpEntry.save();
    }

    console.log("sending Verification");
    await sendVerificationCode(identifier, verificationCode);
    console.log("verification sent");
    return res.status(200).json({ message: 'Otp sent successfully.' });

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
// Register User
exports.registerUser = async (req, res) => {
  const { email, phone, firstName, lastName } = req.body;
  const identifier = email || phone;

  try {
    // Check if the user already exists
    console.log("Finding User");
    if (identifier.includes('@')) {
      const existingUser = await User.findOne({ email: email });
      if (existingUser) {
        return res.status(400).json({ message: 'User already exists' });
      }
      // Create a new user
      console.log("Generating user");
      const user = new User({ email, phone, firstName, lastName });
      await user.save();
    } else {
      const existingUser = await User.findOne({ phone: phone });
      if (!phone || !/^[6-9]\d{9}$/.test(phone)) {
        return res.status(400).json({ message: 'Invalid mobile number format. It must be a 10-digit number' })
      }
      if (existingUser) {
        return res.status(400).json({ message: 'User already exists' });
      }

      const user = new User({ email, phone, firstName, lastName });
      await user.save();
    }
    return res.status(200).json({ message: 'Registration successful! ' });
  } catch (error) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// Verify User
exports.verifyUser = async (req, res) => {
  const { email, phone, otp } = req.body;
  const identifier = email || phone;

  try {
    const user = await Otp.findOne({ $or: [{ email: identifier }, { phone: identifier }] });
    console.log(user.otp);
    console.log(otp);
    if (!user || user.otp !== otp) {
      return res.status(400).json({ message: 'Invalid verification code' });
    }

    // Mark user as verified
    user.isUsed = true;
    user.otp = "null"; // Clear the verification code after successful verification
    console.log("saving in db");
    await user.save();

    return res.status(200).json({ message: 'Account verified successfully!' });
  } catch (error) {
    console.error('Verification error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
// Login User
exports.loginUser = async (req, res) => {
  const { email, phone } = req.body;
  const identifier = email || phone;

  try {
    const user = await User.findOne({ $or: [{ email: identifier }, { phone: identifier }] });
    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }

    return res.status(200).json({ message: 'Login successful!' });
  } catch (error) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};

//get user
exports.getUser = async (req, res) => {
  const identifier = req.params.emailOrPhone;

  if (!identifier) {
    return res.status(400).json({ message: 'Email or phone number is required' });
  }

  try {
    const searchCriteria = identifier.includes('@') ? { email: identifier } : { phone: identifier };
    const user = await User.findOne(searchCriteria);
    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }
    return res.status(200).json({ user });
  }
  catch (err) {
    res.status(400).json({ message: 'Error fetching user', error: err.message });
  }
};

//Update Role
exports.updateRole = async (req, res) => {
  try {
    const { user, role } = req.body;
    const update = await User.updateOne({ _id: user }, { $set: { role: role } }, { new: true });
    if (update.matchedCount == 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    return res.status(200).json({ message: 'Role Updated', update });
  } catch (err) {
    res.status(400).json({ message: 'Error updating role', error: err.message });
  }
}

//get all users
exports.getAllUser = async (req, res) => {
  try {
    const users = await User.find();
    return res.status(200).json({ message: 'Users Fetched', users });
  } catch (err) {
    res.status(400).json({ message: 'Error fetching users', error: err.message });
  }
}

//fetch Delivery Boy
exports.fetchDeliveryBoy = async (req, res) => {
  try {
    const deliveryBoys = await User.find({ role: 'DeliveryBoy' });
      return res.status(200).json({ message: 'Delivery Boys Fetched', deliveryBoys });
    } catch (err) {
      res.status(400).json({ message: 'Error fetching delivery boys', error: err.message });
  }
}


