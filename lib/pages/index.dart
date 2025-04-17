import 'package:flutter/cupertino.dart';

class Indexpage extends StatelessWidget {
  final int initialTab;
  const Indexpage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: CupertinoTabController(initialIndex: initialTab),
      tabBar: CupertinoTabBar(
        // activeColor: AppColors.mainColor,
        // inactiveColor: AppColors.accentColor,
        height: 75,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return Indexpage();
          default:
            return Indexpage();
        }
      },
    );
  }
}
