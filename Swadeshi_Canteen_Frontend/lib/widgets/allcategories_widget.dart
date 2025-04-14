import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/models/super_category_model.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:ajio_mart/screens/sub_category_screen.dart';
import 'package:ajio_mart/screens/super_categories_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/models/product_model.dart'; // Assuming this model exists
import 'package:http/http.dart' as http;

class AllCategoriesHomeWidget extends StatefulWidget {
  AllCategoriesHomeWidget();

  @override
  _AllCategoriesHomeWidgetState createState() =>
      _AllCategoriesHomeWidgetState();
}

class _AllCategoriesHomeWidgetState extends State<AllCategoriesHomeWidget> {
  List<SuperCategory> superCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuperCategories();
  }

  Future<void> fetchSuperCategories() async {
    try {
      final url = APIConfig.getSuperCategories;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic>? data = json.decode(response.body);

        if (data != null && data.isNotEmpty) {
          superCategories.clear();
          for (var item in data) {
            final category = SuperCategory.fromJson(item);
            superCategories.add(category);
          }
        }
      }
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (superCategories.isEmpty && !isLoading) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading with "View All" Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle "View All" button tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewAllSuperCategoriesScreen(), // Navigate to "View All" page
                    ),
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(color: Colors.teal[600], fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        // Categories Grid (limited to 2 rows)
        isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: superCategories.length > 8 ? 8 : superCategories.length, // Show only 2 rows (4 categories per row)
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 boxes per row
                  childAspectRatio: 0.8, // Adjust the height/width ratio
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  return _buildCategoryCard(superCategories[index]);
                },
              ),
      ],
    );
  }

  Widget _buildCategoryCard(SuperCategory category) {
    return InkWell(
      onTap: () {
        if (category.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SubCategoryScreen(superCategoryId: category.superCategoryId),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? category.imageUrl!
                    : 'https://via.placeholder.com/150',
                height: 70,
                
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  'https://via.placeholder.com/150',
                  height: 70,
                  
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                category.name ?? '',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2, // Limit to 2 lines
                overflow: TextOverflow.ellipsis, // Add ellipsis for long names
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
