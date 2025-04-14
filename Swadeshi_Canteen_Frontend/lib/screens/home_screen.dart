import 'package:ajio_mart/models/carousel_model.dart';
import 'package:ajio_mart/screens/search_screen.dart';
import 'package:ajio_mart/widgets/allcategories_widget.dart';
import 'package:ajio_mart/widgets/carousel_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/models/special_widget_list.dart';
import 'package:ajio_mart/models/product_model.dart';
import 'package:ajio_mart/models/categories_model.dart';
import 'package:ajio_mart/widgets/category_home_widget.dart';
import 'package:ajio_mart/widgets/special_home_widget.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onHomeSelected;

  const HomeScreen({Key? key, this.onHomeSelected}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  String searchQuery = "";
  List<SpecialList> specialLists = [];
  TextEditingController _searchController = TextEditingController();
  List<Carousel> futureCarousels = [];
  List<Product> displayedProducts = [];
  List<Product> allProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refresh();
    _searchController
        .addListener(_filterProducts); // Attach listener for search
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose(); // Ensure proper disposal
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchCarousels();
    await fetchAllProducts();
    await fetchSpecialLists();
    await fetchCategories();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCarousels() async {
    final String apiUrl = APIConfig.getCarousels; // Replace with your API URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> carouselsJson = data['carousels'];

        // Parse the JSON into a list of Carousel objects
        setState(() {
          futureCarousels =
              carouselsJson.map((json) => Carousel.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load carousels');
      }
    } catch (e) {
      print('Error fetching carousels: $e');
    }
  }

  Future<void> fetchSpecialLists() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getSpecialWidgets));
      if (response.statusCode == 200) {
        final List<dynamic> specialListJson = jsonDecode(response.body);
        setState(() {
          specialLists = specialListJson
              .map((json) => SpecialList.fromJson(json))
              .toList();
        });
      } else {
        throw Exception('Failed to load special lists');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getAllCategories));
      if (response.statusCode == 200) {
        final List<dynamic> categoryList = jsonDecode(response.body);
        setState(() {
          categories =
              categoryList.map((json) => Category.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAllProducts() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getProduct));
      if (response.statusCode == 200) {
        final allproducts = jsonDecode(response.body);
        setState(() {
          for (var item in allproducts) {
            final product =
                Product.fromJson(item); // Assuming fromJson handles null values
            allProducts.add(product);
          }
          print("product fetched.");
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Search logic to filter products by product name or category
  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    print(query);
    setState(() {
      if (query.isEmpty) {
        displayedProducts = []; // Show all products when search is empty
      } else {
        // Filtering products based on name or category ID
        print(allProducts.length);
        displayedProducts = allProducts.where((Product) {
          return Product.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: screenWidth * 0.2,
              backgroundColor: Colors.amberAccent,
              // flexibleSpace: LayoutBuilder(
              //   builder: (BuildContext context, BoxConstraints constraints) {
              //     return Container(
              //       decoration: BoxDecoration(
              //         image: DecorationImage(
              //           image: AssetImage(
              //               'assets/images/logo.png'), // Use AssetImage instead
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     );
              //   },
              // ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SearchBarDelegate(
                searchWidget: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchScreen(
                                products: allProducts,
                              )),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Container(
                      height: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.search, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              'Search Products',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Check if the carousel data is loaded before displaying
                  isLoading 
                      ? Center(child: CircularProgressIndicator())
                      : ImageCarouselWidget(
                          imageUrls: futureCarousels.isNotEmpty
                              ? futureCarousels[0].imageUrl ?? []
                              : [],
                          height: screenWidth * 0.4,
                          isLoading: isLoading,
                        ),
                  // Display special lists
                  Column(
                    children: specialLists.map((specialList) {
                      return SpecialHomeWidget(
                        heading: specialList.title,
                        products: specialList.productIdList,
                        numberOfProducts: 3,
                        showViewAll: true,
                      );
                    }).toList(),
                  ),

                  isLoading 
                      ? Center(child: CircularProgressIndicator())
                      : ImageCarouselWidget(
                          imageUrls: futureCarousels.length > 1
                              ? futureCarousels[1].imageUrl ?? []
                              : [], // Fallback to an empty list if there isn't a second element
                          height: screenWidth * 0.4,
                          isLoading: isLoading,
                        ),

                  AllCategoriesHomeWidget(),

                  // Display categories
                  Column(
                    children: categories.map((category) {
                      return CategoryHomeWidget(
                        heading: category.name,
                        description: category.description,
                        categoryId: category.categoryId,
                        numberOfProducts: 3,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget searchWidget;

  SearchBarDelegate({required this.searchWidget});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: searchWidget,
    );
  }

  @override
  double get maxExtent =>
      65.8; // Ensure maxExtent is not greater than paintExtent

  @override
  double get minExtent => 65.8; // Ensure consistency with layout extent

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
