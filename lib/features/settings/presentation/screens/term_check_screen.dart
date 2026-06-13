// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_html/flutter_html.dart';
// import '../../../../../config/di/injection.dart';
// import '../../../../../utils/CommonAppBar.dart';
// import '../../../../../utils/Common.dart';
// import '../../../../../utils/my_common.dart';
// import '../../../../../view/employee/controller/role_controller.dart';
// import '../bloc/settings_bloc.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class TermCheckScreen extends StatelessWidget {
//   final String type;
//   const TermCheckScreen({super.key, required this.type});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => getIt<SettingsBloc>()..add(FetchLegalTerms(type)),
//       child: _TermCheckScreenContent(type: type),
//     );
//   }
// }

// class _TermCheckScreenContent extends ConsumerStatefulWidget {
//   final String type;
//   const _TermCheckScreenContent({required this.type});

//   @override
//   ConsumerState<_TermCheckScreenContent> createState() => _TermCheckScreenContentState();
// }

// class _TermCheckScreenContentState extends ConsumerState<_TermCheckScreenContent> {
//   bool check1Value = false, check2Value = false, check3Value = false, check4Value = false;
//   var scrollController = ScrollController();
//   bool isSelectUpArrow = false;

//   void _scrollDown() {
//     if (scrollController.hasClients) {
//       scrollController.animateTo(
//         !isSelectUpArrow ? scrollController.position.maxScrollExtent : scrollController.position.minScrollExtent,
//         duration: const Duration(seconds: 2),
//         curve: Curves.fastOutSlowIn,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       floatingActionButton: AnimatedSize(
//         duration: const Duration(milliseconds: 300),
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 80.0),
//           child: InkWell(
//             onTap: () {
//               _scrollDown();
//               setState(() => isSelectUpArrow = !isSelectUpArrow);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(40),
//                 boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))],
//               ),
//               padding: const EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 5),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Scroll \${!isSelectUpArrow ? "Down" : "Up"}',
//                     style: TextStyle(fontWeight: FontWeight.w500, color: const Color(0xFF4F4F4F), fontSize: size.width * numD04),
//                   ),
//                   const SizedBox(width: 10),
//                   AnimatedRotation(
//                     turns: isSelectUpArrow ? 0.5 : 0,
//                     duration: const Duration(milliseconds: 300),
//                     child: Container(
//                       width: 46, height: 46,
//                       decoration: BoxDecoration(color: ref.watch(userRoleProvider).activeColor, shape: BoxShape.circle),
//                       child: Icon(Icons.keyboard_arrow_down_sharp, color: Colors.white, size: size.width * numD085),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       appBar: CommonAppBar(
//         elevation: 0,
//         hideLeading: false,
//         title: Text(
//           widget.type == "privacy_policy" ? privacyPolicyText : "\$legalText \$tcText",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: size.width * appBarHeadingFontSize),
//         ),
//         centerTitle: false,
//         titleSpacing: 0,
//         size: size,
//         showActions: true,
//         leadingFxn: () => Navigator.pop(context),
//         actionWidget: const [],
//       ),
//       body: BlocBuilder<SettingsBloc, SettingsState>(
//         builder: (context, state) {
//           if (state is SettingsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is LegalTermsLoaded) {
//             return SingleChildScrollView(
//               controller: scrollController,
//               padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD02),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Html(
//                     data: state.content,
//                     style: {
//                       "h2": Style(color: Colors.black, fontSize: FontSize(size.width * numD04)),
//                       "p": Style(color: Colors.black54, fontSize: FontSize(size.width * numD035)),
//                     },
//                   ),
//                   // Additional Checkboxes can be re-enabled here if required
//                 ],
//               ),
//             );
//           } else if (state is SettingsError) {
//             return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
//           }
//           return const SizedBox();
//         },
//       ),
//     );
//   }
// }
