class Address {
  String id;
  String name;
  String address;
  String city;
  String state;
  String zipCode;
  String phone;
  String type; // Work or Home
  bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phone,
    required this.type,
    required this.isDefault,
  });
}
