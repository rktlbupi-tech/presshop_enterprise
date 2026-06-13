import 'package:flutter/material.dart';
import '../../../../../utils/CommonAppBar.dart';
import '../../../../../utils/Common.dart';

class FAQScreen extends StatelessWidget {
  final bool priceTipsSelected;
  final String type;
  final int index;

  const FAQScreen({
    super.key,
    required this.priceTipsSelected,
    required this.type,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          priceTipsSelected ? priceTipsText : faqText,
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
        leadingFxn: () => Navigator.pop(context),
        actionWidget: const [],
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            "FAQ & Price Tips Coming Soon",
            style: TextStyle(fontSize: size.width * numD04),
          ),
        ),
      ),
    );
  }
}
