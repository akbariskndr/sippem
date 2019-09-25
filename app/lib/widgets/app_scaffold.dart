import 'package:flutter/material.dart';
import 'package:sippem/provider.dart';

import 'package:sippem/themes/color.dart';
import 'package:sippem/widgets/navigation_drawer.dart';
import 'package:sippem/def/drawer_item_navigation_data.dart';

class AppScaffold extends StatelessWidget {
  final int activeItem;
  final Widget body;
  final Widget floatingActionButton;
  final GlobalKey<ScaffoldState> scaffoldKey;

  AppScaffold({this.scaffoldKey, this.body, this.activeItem, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    List<DrawerItemNavigationData> drawerItemsNavigationData = [
      DrawerItemNavigationData(id: 0, icon: Icons.home, route: '/'),
      DrawerItemNavigationData(id: 1, icon: Icons.list, route: '/diagnose'),
    ];

    final loggedIn = LoginProvider.of(context).isLoggedIn;

    if (loggedIn) {
      drawerItemsNavigationData.add(
        DrawerItemNavigationData(id: 2, icon: Icons.edit, route: '/show')
      );
    }

    return Scaffold(
      key: scaffoldKey,
      body: body,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: NavigationDrawer(
        activeItem: activeItem,
        drawerItemsNavigationData: drawerItemsNavigationData,
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: floatingActionButton,
    );
  }
}