import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  // List of screens for each section (Product, Category, Slider)
  final List<Widget> _sections = [
    ProductSection(), // Existing product section
    CategorySection(), // Existing category section
    SliderSection(), // New slider section
    OrderAssigningSection(),
    CarouselSection()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _sections[
          _selectedIndex], // Display current section based on selected index
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.slideshow),
            label: 'Sliders', // New tab for Slider Section
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Order Assign', // New tab for Order Assignment
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image), // Icon for Carousel
            label: 'Carousel', // Label for Carousel
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor:
            Colors.grey, // Optional: Color for unselected items
        onTap: (index) {
          setState(() {
            _selectedIndex =
                index; // Update selected index when a tab is clicked
          });
        },
      ),
    );
  }
}

class ProductSection extends StatefulWidget {
  @override
  _ProductSectionState createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  List products = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(APIConfig.getProduct));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse(APIConfig.getProduct),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode(product),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully.')),
      );
      fetchProducts(); // Refresh the product list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product.')),
      );
      throw Exception('Failed to add product');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> product) async {
    final response = await http.put(
      Uri.parse(APIConfig.getProduct + id),
      headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
      body: json.encode(product),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully.')),
      );
      fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product.')),
      );
      throw Exception('Failed to update product');
    }
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
  final TextEditingController nameController =
      TextEditingController(text: product?['name']);
  final TextEditingController productIdController =
      TextEditingController(text: product?['productId']);
  final TextEditingController descriptionController =
      TextEditingController(text: product?['description']);
  final TextEditingController priceController =
      TextEditingController(text: product?['price']?.toString());
  final TextEditingController mrpController =
      TextEditingController(text: product?['mrp']?.toString());
  final TextEditingController stockController =
      TextEditingController(text: product?['stock']?.toString());
  final TextEditingController categoryIdController =
      TextEditingController(text: product?['categoryId']);
  final TextEditingController imageUrlController =
      TextEditingController(text: product?['imageUrl']);
  List<TextEditingController> additionalImagesControllers = (product?['additionalImages'] as List<dynamic>?)
          ?.map((url) => TextEditingController(text: url))
          .toList() ??
      [TextEditingController()];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(product == null ? 'Add Product' : 'Edit Product'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(nameController, 'Product Name'),
                  _buildTextField(productIdController, 'Product Id'),
                  _buildTextField(descriptionController, 'Description'),
                  _buildTextField(priceController, 'Price', isNumber: true),
                  _buildTextField(mrpController, 'MRP', isNumber: true),
                  _buildTextField(stockController, 'Stock', isNumber: true),
                  _buildTextField(categoryIdController, 'Category Id',
                      isNumber: true),
                  _buildTextField(imageUrlController, 'Image URL'),
                  const SizedBox(height: 10),
                  Text(
                    'Additional Images:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    children: additionalImagesControllers
                        .asMap()
                        .entries
                        .map(
                          (entry) => Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  entry.value,
                                  'Image URL ${entry.key + 1}',
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    additionalImagesControllers.removeAt(entry.key);
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Image'),
                    onPressed: () {
                      setState(() {
                        additionalImagesControllers.add(TextEditingController());
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> productData = {
                    'name': nameController.text,
                    'productId': productIdController.text,
                    'description': descriptionController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'mrp': double.tryParse(mrpController.text) ?? 0.0,
                    'stock': int.tryParse(stockController.text) ?? 0,
                    'categoryId': categoryIdController.text,
                    'imageUrl': imageUrlController.text,
                    'additionalImages': additionalImagesControllers
                        .map((controller) => controller.text)
                        .toList(),
                  };

                  if (product == null) {
                    addProduct(productData);
                  } else {
                    updateProduct(product['_id'], productData);
                  }
                  Navigator.of(context).pop();
                },
                child: Text(product == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      );
    },
  );
}



  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Products',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchProducts,
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      if (product['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase())) {
                        return _buildProductItem(product);
                      }
                      return Container();
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showProductDialog(),
                child: Text('Add Product'),
              ),
            ],
          );
  }

  Widget _buildProductItem(product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              product['imageUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(product['name'],
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text('Stock: ${product['stock']}, Price: ₹${product['price']}'),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _showProductDialog(product: product);
          },
        ),
      ),
    );
  }
}

class CategorySection extends StatefulWidget {
  @override
  _CategorySectionState createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection>
    with SingleTickerProviderStateMixin {
  List categories = [];
  List superCategories = [];
  bool isLoadingCategories = true;
  bool isLoadingSuperCategories = true;
  String searchCategoryQuery = '';
  String searchSuperCategoryQuery = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchEntities('Category');
    fetchEntities('SuperCategory');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchEntities(String type) async {
    setState(() {
      if (type == 'Category') isLoadingCategories = true;
      if (type == 'SuperCategory') isLoadingSuperCategories = true;
    });
    try {
      final response = await http.get(Uri.parse(type == 'Category'
          ? APIConfig.getAllCategories
          : APIConfig.getSuperCategories));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (type == 'Category') {
            categories = data;
            isLoadingCategories = false;
          } else {
            superCategories = data;
            isLoadingSuperCategories = false;
          }
        });
      } else {
        throw Exception('Failed to load $type data');
      }
    } catch (e) {
      setState(() {
        if (type == 'Category') isLoadingCategories = false;
        if (type == 'SuperCategory') isLoadingSuperCategories = false;
      });
      print(e);
    }
  }

  Future<void> addOrUpdateEntity(
      String api, Map<String, dynamic> data, String id, String type) async {
    final isUpdate = id.isNotEmpty;
    try {
      final response = await (isUpdate
          ? http.put(Uri.parse('$api/$id'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'admin'
              },
              body: json.encode(data))
          : http.post(Uri.parse(api),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'admin'
              },
              body: json.encode(data)));
      print(data);
      if (response.statusCode == (isUpdate ? 200 : 201)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${isUpdate ? 'Updated' : 'Added'} successfully.')),
        );
        fetchEntities(type);
      } else {
        throw Exception('Failed to ${isUpdate ? 'update' : 'add'} $type');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showEntityDialog(String type, {Map<String, dynamic>? entity}) {
    final TextEditingController nameController =
        TextEditingController(text: entity?['name']);
    final TextEditingController superCategoryIdController =
        TextEditingController(text: entity?['superCategoryId']);
    final TextEditingController categoryIdController =
        TextEditingController(text: entity?['categoryId']);
    final TextEditingController descriptionController =
        TextEditingController(text: entity?['description']);
    final TextEditingController imageUrlController =
        TextEditingController(text: entity?['imageUrl']);
    String selectedSuperCategory = entity?['superCategoryId'] ?? '';

    showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
          maxWidth: MediaQuery.of(context).size.width * 0.9,  // 90% of screen width
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Allow Column to shrink if needed
                children: [
                  Text(
                    entity == null ? 'Add $type' : 'Edit $type',
                    // style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  if (type == 'Category') ...[
                    _buildTextField(nameController, 'Category Name'),
                    SizedBox(height: 10),
                    _buildTextField(categoryIdController, 'Category Id'),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: superCategories
                              .any((sc) => sc['superCategoryId'] == selectedSuperCategory)
                          ? selectedSuperCategory
                          : null,
                      items: superCategories.map((sc) {
                        return DropdownMenuItem<String>(
                          value: sc['superCategoryId'],
                          child: Text(sc['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSuperCategory = value ?? '';
                        });
                      },
                      decoration: InputDecoration(labelText: 'SuperCategory'),
                    ),
                    SizedBox(height: 10),
                    _buildTextField(descriptionController, 'Description'),
                    SizedBox(height: 10),
                    _buildTextField(imageUrlController, 'Image URL'),
                  ] else ...[
                    _buildTextField(nameController, 'SuperCategory Name'),
                    SizedBox(height: 10),
                    _buildTextField(superCategoryIdController, 'SuperCategory Id'),
                    SizedBox(height: 10),
                    _buildTextField(imageUrlController, 'Image Url'),
                    SizedBox(height: 10),
                    _buildTextField(descriptionController, 'Description'),
                  ],
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Map<String, dynamic> data = {
                            'name': nameController.text,
                            'description': descriptionController.text,
                            if (type == 'Category')
                              'superCategoryId': selectedSuperCategory,
                            if (type == 'Category')
                              'categoryId': categoryIdController.text,
                            if (type == 'SuperCategory')
                              'superCategoryId': superCategoryIdController.text,
                            'imageUrl': imageUrlController.text,
                          };
                          addOrUpdateEntity(
                              type == 'Category'
                                  ? APIConfig.getAllCategories
                                  : APIConfig.getSuperCategories,
                              data,
                              entity?['_id'] ?? '',
                              type);
                          Navigator.of(context).pop();
                        },
                        child: Text(entity == null ? 'Add' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);

  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildEntityList(
      String type, List data, String searchQuery, bool isLoading) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search $type',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (type == 'Category') searchCategoryQuery = value;
                      if (type == 'SuperCategory')
                        searchSuperCategoryQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await fetchEntities(type),
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var entity = data[index];
                      if (entity['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase())) {
                        return _buildEntityItem(type, entity);
                      }
                      return Container();
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showEntityDialog(type),
                child: Text('Add $type'),
              ),
            ],
          );
  }

  Widget _buildEntityItem(String type, Map<String, dynamic> entity) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              entity['imageUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title:
            Text(entity['name'], style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _showEntityDialog(type, entity: entity);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Categories'),
            Tab(text: 'SuperCategories'),
          ],
        ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEntityList(
              'Category', categories, searchCategoryQuery, isLoadingCategories),
          _buildEntityList('SuperCategory', superCategories,
              searchSuperCategoryQuery, isLoadingSuperCategories),
        ],
      ),
    );
  }
}

class SliderSection extends StatefulWidget {
  @override
  _SliderSectionState createState() => _SliderSectionState();
}

class _SliderSectionState extends State<SliderSection> {
  List sliders = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSliders();
  }

  Future<void> fetchSliders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(APIConfig.getSpecialWidgets));
      if (response.statusCode == 200) {
        setState(() {
          sliders = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sliders');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addSlider(Map<String, dynamic> sliderData) async {
    final response = await http.post(
      Uri.parse(APIConfig.getSpecialWidgets),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sliderData),
    );
    if (response.statusCode == 201) {
      fetchSliders();
    } else {
      throw Exception('Failed to add slider');
    }
  }

  Future<void> updateSlider(String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse(APIConfig.getSpecialWidgets + id),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );
    if (response.statusCode == 200) {
      fetchSliders();
    } else {
      throw Exception('Failed to update slider');
    }
  }

  Future<void> deleteSlider(String id) async {
    final response =
        await http.delete(Uri.parse(APIConfig.getSpecialWidgets + id));
    if (response.statusCode == 200) {
      fetchSliders();
    } else {
      throw Exception('Failed to delete slider');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sliders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddSliderDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchSliders,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search sliders...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: sliders.length,
                      itemBuilder: (context, index) {
                        final slider = sliders[index];
                        if (slider['title']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase())) {
                          return Card(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(slider['title']),
                              subtitle: Text(
                                  'Number of Products: ${slider['numberOfProducts']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showUpdateSliderDialog(context, slider);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteConfirmation(
                                          context, slider['_id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Add Slider Dialog
  Future<void> _showAddSliderDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController productsController = TextEditingController();
    final TextEditingController productsNumberController =
        TextEditingController();
    bool showViewAll = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Slider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: productsController,
                decoration:
                    InputDecoration(labelText: 'Products (comma-separated)'),
              ),
              TextField(
                controller: productsNumberController,
                decoration: InputDecoration(labelText: 'Number of Products'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: showViewAll,
                    onChanged: (bool? value) {
                      setState(() {
                        showViewAll = value ?? true;
                      });
                    },
                  ),
                  Text('Show View All'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newSlider = {
                'title': titleController.text,
                'products': productsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                'numberOfProducts': int.parse(productsNumberController.text),
                'showViewAll': showViewAll,
              };
              addSlider(newSlider);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // Update Slider Dialog
  Future<void> _showUpdateSliderDialog(
      BuildContext context, dynamic slider) async {
    final TextEditingController titleController =
        TextEditingController(text: slider['title']);
    final TextEditingController productsController =
        TextEditingController(text: slider['products'].join(', '));
    final TextEditingController productsNumberController =
        TextEditingController(text: slider['numberOfProducts'].toString());
    bool showViewAll = slider['showViewAll'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Slider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: productsController,
                decoration:
                    InputDecoration(labelText: 'Products (comma-separated)'),
              ),
              TextField(
                controller: productsNumberController,
                decoration: InputDecoration(labelText: 'Number of Products'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: showViewAll,
                    onChanged: (bool? value) {
                      setState(() {
                        showViewAll = value ?? true;
                      });
                    },
                  ),
                  Text('Show View All'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedSlider = {
                'title': titleController.text,
                'products': productsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                'numberOfProducts': int.parse(productsNumberController.text),
                'showViewAll': showViewAll,
              };
              updateSlider(slider['_id'], updatedSlider);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Confirm delete dialog
  Future<void> _deleteConfirmation(
      BuildContext context, String sliderId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Slider'),
        content: Text('Are you sure you want to delete this slider?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              deleteSlider(sliderId);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class OrderAssigningSection extends StatefulWidget {
  @override
  _OrderAssigningSectionState createState() => _OrderAssigningSectionState();
}

class _OrderAssigningSectionState extends State<OrderAssigningSection> {
  List<dynamic> orders = [];
  List<dynamic> deliveryBoys = [];
  Map<String, String?> selectedDeliveryBoys = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchDeliveryBoys();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse(APIConfig.getAllOrders));
    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);
        // Only fetch orders with "Pending" status
        orders = data['orders']
            .where((order) => order['orderStatus'] == 'Pending')
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load orders');
    }
  }

  Future<void> fetchDeliveryBoys() async {
    final response = await http.get(Uri.parse(APIConfig.deliveryBoys));
    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);
        deliveryBoys = data['deliveryBoys'];
      });
    } else {
      throw Exception('Failed to load delivery boys');
    }
  }

  Future<void> assignOrder(String orderId, String deliveryBoyId) async {
    final response = await http.put(
      Uri.parse(APIConfig.assignOrder),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'deliveryBoyId': deliveryBoyId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order assigned successfully'),
      ));
      // Refresh the orders after assignment
      fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to assign order'),
      ));
    }
  }

  Future<void> _refresh() async {
    await fetchOrders();
    await fetchDeliveryBoys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Pending Orders'),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  if (!selectedDeliveryBoys.containsKey(order['_id'])) {
                    selectedDeliveryBoys[order['_id']] =
                        null; // Initialize with null
                  }
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Order ID: ${order['_id']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Chip(
                                label: Text(order['orderStatus']),
                                backgroundColor:
                                    order['orderStatus'] == 'Pending'
                                        ? Colors.orangeAccent
                                        : Colors.greenAccent,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Customer: ${order['user']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Total Price: ₹${order['totalPrice']}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Delivery Address:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(order['deliveryAddress']),
                          SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            hint: Text('Select Delivery Boy'),
                            value: selectedDeliveryBoys[order['_id']],
                            onChanged: (value) {
                              setState(() {
                                selectedDeliveryBoys[order['_id']] = value;
                              });
                            },
                            items: deliveryBoys.map((deliveryBoy) {
                              return DropdownMenuItem<String>(
                                value: deliveryBoy['_id'],
                                child: Text(
                                  '${deliveryBoy['firstName']} ${deliveryBoy['lastName']}',
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: selectedDeliveryBoys[order['_id']] ==
                                    null
                                ? null
                                : () {
                                    assignOrder(order['_id'],
                                        selectedDeliveryBoys[order['_id']]!);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal, // Background color
                              foregroundColor: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text('Assign Order',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class CarouselSection extends StatefulWidget {
  @override
  _CarouselSectionState createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<CarouselSection> {
  List<dynamic> carousels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarousels();
  }

  Future<void> fetchCarousels() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getCarousels));
      if (response.statusCode == 200) {
        setState(() {
          carousels = json.decode(response.body)['carousels'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching carousels: $e");
    }
  }

  Future<void> addCarouselItem(String title, String description,
      List<String> imageUrl, String route) async {
    final response = await http.post(
      Uri.parse(APIConfig.getCarousels),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'route': route,
      }),
    );
    if (response.statusCode == 201) {
      fetchCarousels();
    }
  }

  Future<void> updateCarouselItem(String id, String title, String description,
      List<String> imageUrl, String route) async {
    final response = await http.put(
      Uri.parse(APIConfig.getCarousels + id),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'route': route,
      }),
    );
    if (response.statusCode == 200) {
      fetchCarousels();
    }
  }

  Future<void> deleteCarouselItem(String id) async {
    final response = await http.delete(Uri.parse(APIConfig.getCarousels + id));
    if (response.statusCode == 200) {
      fetchCarousels();
    }
  }

  void showCarouselDialog(
      {String? id,
      String title = '',
      String description = '',
      List<String>? imageUrl,
      String route = ''}) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController descriptionController =
        TextEditingController(text: description);
    TextEditingController imageUrlController = TextEditingController();
    TextEditingController routeController = TextEditingController(text: route);
    List<String> imageUrlList = imageUrl ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(id == null ? 'Add Carousel' : 'Edit Carousel'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: imageUrlController,
                            decoration: InputDecoration(labelText: 'Image URL'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (imageUrlController.text.isNotEmpty) {
                              setState(() {
                                imageUrlList.add(imageUrlController.text);
                              });
                              imageUrlController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: imageUrlList
                          .map((url) => Chip(
                                label: Text(url),
                                onDeleted: () {
                                  setState(() {
                                    imageUrlList.remove(url);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    TextField(
                      controller: routeController,
                      decoration: InputDecoration(labelText: 'Route'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (id == null) {
                      addCarouselItem(
                        titleController.text,
                        descriptionController.text,
                        imageUrlList,
                        routeController.text,
                      );
                    } else {
                      updateCarouselItem(
                        id,
                        titleController.text,
                        descriptionController.text,
                        imageUrlList,
                        routeController.text,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(id == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchCarousels,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: carousels.length,
                    itemBuilder: (context, index) {
                      final carousel = carousels[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                carousel['title'] ?? 'No Title',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                carousel['description'] ?? 'No Description',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Route: ${carousel['route'] ?? 'No Route'}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Images:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Wrap(
                                spacing: 8.0,
                                children:
                                    (carousel['imageUrl'] as List<dynamic>)
                                        .map((imageUrl) => Image.network(
                                              imageUrl,
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                            ))
                                        .toList(),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showCarouselDialog(
                                        id: carousel['_id'],
                                        title: carousel['title'],
                                        description: carousel['description'],
                                        imageUrl: List<String>.from(
                                            carousel['imageUrl']),
                                        route: carousel['route'],
                                      );
                                    },
                                    child: Text("Edit"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        deleteCarouselItem(carousel['_id']),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              showCarouselDialog();
            },
            child: Text("Add Carousel Item"),
          ),
        ),
      ],
    );
  }
}
