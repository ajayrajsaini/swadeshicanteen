import 'dart:convert';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  OrderDetailScreen({required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<Map<String, dynamic>> itemsWithDetails = [];
  int? selectedRating; // Holds the user's rating selection
  bool showSubmitRatingButton = false; // Controls visibility of Submit button

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }


  // Function to generate PDF invoice
Future<void> downloadInvoice() async {
  final pdf = pw.Document();
  print("Starting invoice generation...");

  try {
    // Load the logo image from assets
    final ByteData bytes = await rootBundle.load('assets/images/logo.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Get the current date and time
    DateTime GMT = DateTime.parse(widget.order['deliveredAt']).toLocal();
    DateTime now = globals.convertGmtToIst(GMT);
    String formattedDate = '${now.day}/${now.month}/${now.year}';

    // Load the font
    final ByteData ttfData = await rootBundle.load('assets/font/SakalBharati.ttf');
    final Uint8List fontData = ttfData.buffer.asUint8List();
    final pw.Font ttf = pw.Font.ttf(fontData.buffer.asByteData());

    const itemsPerPage = 10; // Define the number of items per page

    // Helper functions
    String handleNull(dynamic value, {String defaultValue = ''}) {
      return value != null ? value.toString() : defaultValue;
    }

    double handleNullDouble(dynamic value, {double defaultValue = 0.0}) {
      return value != null ? double.tryParse(value.toString()) ?? defaultValue : defaultValue;
    }

    int currentItem = 0;
    double totalAmount = 0.0;

    // Calculate the total number of pages
    int totalPages = (itemsWithDetails.length / itemsPerPage).ceil();

    // First pass: Create pages
    while (currentItem < itemsWithDetails.length) {
      final itemsSubset = itemsWithDetails.sublist(
          currentItem,
          (currentItem + itemsPerPage) > itemsWithDetails.length
              ? itemsWithDetails.length
              : currentItem + itemsPerPage);
      currentItem += itemsPerPage;

      // Current page number based on the currentItem index
      int currentPageNumber = (currentItem / itemsPerPage).ceil();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo Section
                pw.Image(pw.MemoryImage(imageData), width: 100, height: 100),
                pw.SizedBox(height: 20),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("AJIO MART", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(handleNull('Ward No. 2, Ashok Nagar, Bagar,')),
                        pw.Text(handleNull('Jhunjhunu, Rajasthan, India')),
                        pw.Text(handleNull('333023', defaultValue: "Zip Code")),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Order Id: ${handleNull(widget.order['_id'], defaultValue: '00000')}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("Delivered On: ${handleNull(formattedDate, defaultValue: 'dd/mm/yyyy')}"),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1, color: PdfColors.grey),
                pw.Text("BILL TO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(handleNull(widget.order['deliveryAddress'], defaultValue: "Street Address, Zip code, City, Country")),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1, color: PdfColors.grey),
                pw.Text("DETAILS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),

                // Items Table
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text(' ITEM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(' QTY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(' MRP', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(' DISCOUNT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(' PRICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(' NET AMOUNT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    ...itemsSubset.map<pw.TableRow>((item) {
                      final itemName = handleNull(item['name'], defaultValue: "N/A");
                      final itemQuantityStr = handleNull(item['quantity'], defaultValue: "0");
                      final itemQuantity = double.tryParse(itemQuantityStr) ?? 0.0;
                      final itemMrp = handleNullDouble(item['mrp'], defaultValue: 0.0);
                      final itemPrice = handleNullDouble(item['price'], defaultValue: 0.0) / itemQuantity;

                      final netItemDiscount = itemMrp - itemPrice;
                      final netItemAmount = itemPrice * itemQuantity;
                      totalAmount += netItemAmount;

                      return pw.TableRow(
                        children: [
                          pw.Text(" " + itemName, style: pw.TextStyle(font: ttf)),
                          pw.Text(" " + itemQuantity.toString(), style: pw.TextStyle(font: ttf)),
                          pw.Text(' ₹${itemMrp.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                          pw.Text(' -₹${netItemDiscount.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                          pw.Text(' ₹${itemPrice.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                          pw.Text(' ₹${netItemAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Total Section at the end of the last page only
                if (currentItem >= itemsWithDetails.length)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Delivery Charges: ₹${handleNullDouble(widget.order['totalPrice']-totalAmount, defaultValue: 0.0).toStringAsFixed(2)}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Total Amount: ₹${handleNullDouble(widget.order['totalPrice'], defaultValue: 0.0).toStringAsFixed(2)}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),

                // Page number at the bottom
                pw.SizedBox(height: 20), // Add space before page number
                pw.Align(
                  alignment: pw.Alignment.bottomCenter,
                  child: pw.Text(
                    'Page $currentPageNumber of $totalPages',
                    style: pw.TextStyle(fontSize: 12, font: ttf),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Save and open PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/Invoice_${widget.order['_id']}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(filePath);
  } catch (e) {
    print("Error generating invoice: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download invoice')));
  }
}



  Future<void> fetchProductDetails() async {
    List<Map<String, dynamic>> fetchedItems = [];

    for (var item in widget.order['items']) {
      final response =
          await http.get(Uri.parse(APIConfig.getProduct + item['productId']));

      if (response.statusCode == 200) {
        final productData = json.decode(response.body);
        fetchedItems.add({
          'id': productData['_id'],
          'productId': item['productId'],
          'quantity': item['quantity'],
          'imageUrl': productData['imageUrl'],
          'name': productData['name'],
          'mrp': productData['mrp'],
          'price': item['price'],
          'rating': productData['rating'],
          'ratingCount': productData['ratingCount'],
        });
      } else {
        fetchedItems.add({
          'id': "0",
          'productId': "0",
          'quantity': 0,
          'imageUrl': null,
          'name': 'Product Not Found',
          'mrp': 0,
          'price': 0,
          'rating': 0,
          'ratingCount': 0,
        });
      }
    }

    setState(() {
      itemsWithDetails = fetchedItems;
    });
  }

  // Function to update rating for all ordered products
  Future<void> updateRating(int rating) async {
    try {
      print(itemsWithDetails);
      // Loop through all items in the order
      for (var item in itemsWithDetails) {
        print(APIConfig.getProduct + item['id']);
        final response = await http.put(
          Uri.parse(APIConfig.getProduct +
              item['id']), // Replace with your API endpoint
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'admin'
          },
          body: jsonEncode({
            'rating': (item['rating'] * item['ratingCount'] + rating) /
                (item['ratingCount'] + 1),
            'ratingCount': item['ratingCount'] + 1,
          }),
        );

        if (response.statusCode == 200) {
          // Successfully updated rating
          print('Rating updated for product ID: ${item['productId']}');
        } else {
          // Handle error
          print('Failed to update rating for product ID: ${item['productId']}');
        }
      }

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ratings updated successfully!')),
      );
    } catch (e) {
      print('Error updating ratings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update ratings.')),
      );
    }
  }

  Text _getDeliveryMessage(String status, DateTime? deliveryDate) {
    String message;
    Color color;

    if (status == 'Cancelled') {
      message = 'Order Cancelled';
      color = Colors.red;
    } else if (status == 'Delivered') {
      message =
          'Delivered on ${deliveryDate?.toLocal().toString().split(' ')[0]}';
      color = Colors.green;
    } else if (deliveryDate == null) {
      message = 'Arriving Soon';
      color = Colors.orange;
    } else {
      message =
          'Arriving on ${deliveryDate?.toLocal().toString().split(' ')[0]}';
      color = Colors.blue;
    }

    return Text(
      message,
      style: TextStyle(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDate = widget.order['deliveredAt'] != null
        ? globals.convertGmtToIst(DateTime.parse(widget.order['deliveredAt']).toLocal())
        : null;

    final createdAt = widget.order['createdAt'] != null
        ? globals.convertGmtToIst(DateTime.parse(widget.order['createdAt']).toLocal())
        : null ;

    return Scaffold(
      appBar: AppStyles.appBarStyle("Order Detail"),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order['_id']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Created on: ${createdAt.toString().split(' ')[0]}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            Divider(
              thickness: 3,
            ),
            SizedBox(height: 10),
            Text(
              'Total Price: \₹${widget.order['totalPrice']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Payment Status: ${widget.order['paymentStatus']}',
              style: TextStyle(fontSize: 16),
            ),
            if (widget.order['paymentStatus'] == 'Paid') ...[
              SizedBox(height: 10),
              Text(
                'Payment Method: ${widget.order['paymentMethod']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
            SizedBox(height: 10),
            _getDeliveryMessage(widget.order['orderStatus'], deliveryDate),
            SizedBox(height: 10),
            Text(
              'To: ${widget.order['deliveryAddress']}',
              style: TextStyle(fontSize: 16),
            ),
            Divider(
              thickness: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Order Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: itemsWithDetails.length,
                itemBuilder: (context, index) {
                  final item = itemsWithDetails[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    shadowColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: item['imageUrl'] != null &&
                              item['imageUrl'].isNotEmpty
                          ? Image.network(
                              item['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Return a placeholder image in case of error
                                return Image.network(
                                  APIConfig
                                      .logoUrl, // Make sure to have a placeholder image in your assets
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.network(
                              APIConfig
                                  .logoUrl, // Placeholder for when imageUrl is null or empty
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                      title: Text(item['name'] ??
                          'Unknown Product'), // Handle null for name
                      subtitle: Text(
                        'Quantity: ${item['quantity'] ?? 0}\nPrice: ₹${item['price'] ?? 0}',
                      ),
                      // trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                                productId: item['productId']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Generate Invoice Button - only visible if order is delivered
            if (widget.order['orderStatus'] == 'Delivered') ...[
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: downloadInvoice,
                  icon: Icon(Icons.pages),
                  label: Text("Generate Invoice"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black45,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Rate Your Order:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: selectedRating != null && index < selectedRating!
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                        showSubmitRatingButton = true;
                      });
                    },
                  );
                }),
              ),
            ],
            // Rating Section

            if (showSubmitRatingButton)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle rating submission logic
                    // Call updateRating when the button is pressed
                    updateRating(selectedRating!);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Thank you for your rating!')));
                    setState(() {
                      showSubmitRatingButton = false;
                    });
                  },
                  child: Text("Submit Rating"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
