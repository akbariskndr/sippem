import 'package:flutter/material.dart';
import 'package:sippem/themes/color.dart';
import 'package:sippem/def/drawer_item_navigation_data.dart';

class NavigationDrawer extends StatelessWidget {
  final int activeItem;
  final List<DrawerItemNavigationData> drawerItemsNavigationData;

  NavigationDrawer({this.activeItem, this.drawerItemsNavigationData});

  Widget _buildTile(BuildContext context, IconData icon, {bool active = false, Function onTap}) {
    final listTile = ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Icon(
        icon, size: 50.0, color: Colors.white,
      ),
      onTap: () => onTap(context),
      
    );

    Widget widget = listTile;

    if (active) {
      widget = Container(
        color: Color.fromRGBO(84, 94, 92, 1.0),
        child: listTile,
      );
    }

    return widget;
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> listTiles = drawerItemsNavigationData.map((item){
      return _buildTile(context, item.icon, active: item.id == activeItem, onTap: (context) {
        Navigator.pushNamed(context, item.route);
      });
    }).toList();

    List<Widget> drawerItems = [
      Divider(
        height: AppBar().preferredSize.height + 5,
      ),
    ];

    drawerItems.addAll(listTiles);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
        child: Drawer(
          child: Container(
            color: Color.fromRGBO(46, 58, 56, 1.0),
            child: ListView(
              children: drawerItems,
            ),
          ),
        ),
    );
  }
}