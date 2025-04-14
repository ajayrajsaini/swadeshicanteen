library my_project.globals;

String? userContactType = '';
String? userContactValue = '';
String userFirstName = '';
String userLastName = '';
String userRole= '';
String userFullName = userFirstName + ' ' + userLastName;

// Example of a function to clear user data (like on logout)
void clearUserData() {
  userContactType = '';
  userContactValue = '';
  userFirstName = '';
  userLastName = '';
  userRole = '';
}

// Example of a function to set user data
void setUserData(String? contactType, String? contactValue, String firstName, String lastName, String role) {
  userContactType = contactType;
  userContactValue = contactValue;
  userFirstName = firstName;
  userLastName = lastName;
  userRole = role;
}

DateTime convertGmtToIst(DateTime gmtDate) {
  // IST is GMT+5:30, so add 5 hours and 30 minutes
  return gmtDate.add(Duration(hours: 5, minutes: 30));
}
