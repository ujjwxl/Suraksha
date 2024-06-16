import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:trackingapp/pages/fake_call_page.dart';
import 'package:trackingapp/pages/group_page.dart';
import 'package:trackingapp/pages/main_home_page.dart';
import 'package:trackingapp/pages/new_profile_page.dart';
import 'package:trackingapp/pages/profile_page.dart';
import 'package:trackingapp/pages/sos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  final List<Widget> pages = [
    const MainHomePage(),
    const GroupPage(),
    const SOSPage(),
    const FakeCallPage(),
    // const ProfilePage(),
    const NewProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Tracking App'),
      //   centerTitle: true,
      // ),
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            // selectedIcon: Icon(Iconsax.home1),
            // icon: Icon(Iconsax.home),
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            // selectedIcon: Icon(Iconsax.people5),
            // icon: Icon(Iconsax.people),
            selectedIcon: Icon(Icons.people),
            icon: Icon(Icons.people_outline_sharp),
            label: 'My Group',
          ),
          NavigationDestination(
            icon: Icon(Icons.sos),
            label: 'SOS',
          ),
          NavigationDestination(
            // selectedIcon: Icon(Iconsax.call5),
            // icon: Icon(Iconsax.call),
            selectedIcon: Icon(Icons.call),
            icon: Icon(Icons.call_outlined),
            label: 'Fake Call',
          ),
          NavigationDestination(
            // selectedIcon: Icon(Iconsax.profile_2user5),
            // icon: Icon(Iconsax.profile_2user4),
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
