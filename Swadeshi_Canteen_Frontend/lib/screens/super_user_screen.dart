import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/utils/user_global.dart' as globals;

class SuperUserPanel extends StatefulWidget {
  @override
  _SuperUserPanelState createState() => _SuperUserPanelState();
}

class _SuperUserPanelState extends State<SuperUserPanel> {
  List users = [];
  final List<String> roles = ['Admin', 'DeliveryBoy', 'Customer'];

  // Fetch all users from the server
  Future<void> fetchAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(APIConfig.allUser),
        headers: {
          'Authorization': 'admin',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('users')) {
          setState(() {
            // Filter out users with the role "SuperUser"
            users = (jsonResponse['users'] as List)
                .where((user) => user['role'] != 'SuperUser')
                .toList();
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users');
    }
  }

  // Update user role on the server
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final response = await http.put(
        Uri.parse(APIConfig.updateRole),
        headers: {'Content-Type': 'application/json', 'Authorization': 'admin'},
        body: json.encode({'user': userId, 'role': newRole}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user role');
      }
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  // Pull-to-refresh functionality
  Future<void> _onRefresh() async {
    await fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super User Panel'),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: users.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  String userId = user['_id'];
                  String name = user['firstName'];
                  String currentRole = user['role'];

                  // Ensure currentRole is valid for DropdownButton
                  String dropdownValue = roles.contains(currentRole) ? currentRole : roles.first;

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'Role: $currentRole',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: DropdownButton<String>(
                        value: dropdownValue,
                        items: roles.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newRole) {
                          if (newRole != null && newRole != currentRole) {
                            setState(() {
                              user['role'] = newRole;
                            });
                            updateUserRole(userId, newRole); // Update role in MongoDB
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
