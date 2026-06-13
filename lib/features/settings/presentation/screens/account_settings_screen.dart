import 'package:flutter/material.dart';
import '../../../../../utils/CommonAppBar.dart';
import '../../../../../utils/CommonWigdets.dart';
import '../../../../../utils/Common.dart';
import 'account_delete_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Account settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: size.width * appBarHeadingFontSize,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: const [],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * numD01,
          vertical: size.height * numD015,
        ),
        children: [
          ListTile(
            title: Text(
              "Delete Account",
              style: commonTextStyle(
                size: size,
                fontSize: size.width * numD04,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: size.width * numD05,
              color: Colors.red,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountDeleteScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
