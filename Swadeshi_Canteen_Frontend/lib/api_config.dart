class APIConfig {
  static const String baseUrl =
      "https://ajiomart.onrender.com"; // Base URL for all API calls

  // Auth-related APIs
  static const String sendOTP = "$baseUrl/users/sendOtp/";
  static const String verifyOTP = "$baseUrl/users/verify/";
  static const String userLogin = "$baseUrl/users/login/";
  static const String register = "$baseUrl/users/";
  static const String getUserInfo = "$baseUrl/users/"; // add Suffix contactValue


  // Product-related APIs
  static const String getProduct = "$baseUrl/products/"; 
  static const String getAllProductsInCategory = "$baseUrl/products/category/";
  static const String getAllCategoriesInSuperCategory = "$baseUrl/categories/super/";
  static const String getAllCategories = "$baseUrl/Categories/";
  static const String getSuperCategories = "$baseUrl/superCategories/";
  static const String addToCart = "$baseUrl/cart/";
  static const String updateQuantityInCart = "$baseUrl/cart/"; //put
  static const String deleteProductFromCart = "$baseUrl/cart/";
  static const String getAllItemInCart = "$baseUrl/cart/"; // added user in code

  //Address-related APIs
  static const String getAllAddresses = "$baseUrl/address/"; // add suffix contact value
  static const String getAddress = "$baseUrl/address/getAddress/"; // add suffix contact value

  //Order-related APIs
  static const String getAllOrders = "$baseUrl/orders/allOrder/"; // add suffix contact value
  static const String submitOrder = "$baseUrl/orders/";


  static const String getSpecialWidgets = "$baseUrl/sliders/"; 
  static const String getCarousels = "$baseUrl/Carousels/"; 
  static const String deliveryBoys = "$baseUrl/users/deliveryBoys/"; 
  static const String assignOrder = "$baseUrl/orders/assignOrder/"; 
  static const String allUser = "$baseUrl/users/all/"; 
  static const String updateRole = "$baseUrl/users/updateRole/"; 
  static const String updateOrder = "$baseUrl/orders/updateOrder/"; 
  static const String deliveryCharges = "$baseUrl/deliveryfee/"; 


  // Add more APIs as needed
  static const String logoUrl = "https://firebasestorage.googleapis.com/v0/b/ajiomart-71d01.appspot.com/o/Logo%2Flogo.png?alt=media&token=63e84872-0e42-433c-8737-c950201db7cb";
  static const String Url = "";
}
