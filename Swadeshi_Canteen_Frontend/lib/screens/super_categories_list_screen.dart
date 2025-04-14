import 'dart:convert';
import 'package:ajio_mart/screens/sub_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/models/super_category_model.dart';
import 'package:ajio_mart/api_config.dart';

class ViewAllSuperCategoriesScreen extends StatefulWidget {
  @override
  _ViewAllSuperCategoriesScreenState createState() =>
      _ViewAllSuperCategoriesScreenState();
}

class _ViewAllSuperCategoriesScreenState
    extends State<ViewAllSuperCategoriesScreen> {
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
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = 3; // Number of items per row
    final itemWidth = (screenWidth - 32 - (8 * (crossAxisCount - 1))) /
        crossAxisCount; // Adjust width for padding and spacing

    return Scaffold(
      appBar: AppBar(
        title: Text("All Categories"),
        backgroundColor: Colors.amberAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchSuperCategories,
              child: superCategories.isEmpty
                  ? Center(child: Text("No categories available"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: itemWidth / (itemWidth + 50),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: superCategories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(
                          superCategories[index],
                          itemWidth,
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildCategoryCard(SuperCategory category, double itemWidth) {
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
        width: itemWidth,
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
                height: itemWidth, // Make height equal to width
                width: itemWidth,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  'https://via.placeholder.com/150',
                  height: itemWidth,
                  width: itemWidth,
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
