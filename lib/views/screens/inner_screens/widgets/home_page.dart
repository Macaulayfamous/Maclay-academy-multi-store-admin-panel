// import 'package:flutter/material.dart';
// import 'package:mac_store_web/views/screens/inner_screens/category_screen.dart';

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Panel'),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text(
//                 'Admin Panel',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: Text('Dashboard'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 // Navigate to CategoryScreen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => CategoryScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               title: Text('Users'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 // TODO: Navigate to Users screen
//               },
//             ),
//             ListTile(
//               title: Text('Settings'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 // TODO: Navigate to Settings screen
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Navigator(
//         onGenerateRoute: (RouteSettings settings) {
//           WidgetBuilder builder;
//           // Check the route name and return the corresponding screen
//           switch (settings.name) {
//             case '/':
//               builder = (BuildContext context) => DashboardScreen();
//               break;
//             case '/users':
//               builder = (BuildContext context) => UsersScreen();
//               break;
//             case '/settings':
//               builder = (BuildContext context) => SettingsScreen();
//               break;
//             default:
//               throw Exception('Invalid route: ${settings.name}');
//           }
//           return MaterialPageRoute(
//             builder: builder,
//             settings: settings,
//           );
//         },
//       ),
//     );
//   }
// }

// class DashboardScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Welcome to the Dashboard screen!'),
//     );
//   }
// }

// class UsersScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Welcome to the Users screen!'),
//     );
//   }
// }

// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Welcome to the Settings screen!'),
//     );
//   }
// }
