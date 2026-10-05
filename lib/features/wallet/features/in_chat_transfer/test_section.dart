// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:qik_talk/features/wallet/features/in_chat_transfer/select_transfer_mode_bottom_sheet.dart';
// import 'package:qik_talk/features/wallet/features/in_chat_transfer/send_or_request_option_bottom_sheet.dart';
// import 'package:qik_talk/features/wallet/features/in_chat_transfer/ship_mode/sheet/ship_transfer_bottom_sheet.dart';
//
// import 'airplane_mode/sheet/airplane_transfer_bottom_sheet.dart';
// import 'car_mode/sheet/car_transfer_bottom_sheet.dart';
// import 'input_amount_bottom_sheet.dart';
//
// class TestSection extends StatelessWidget {
//   const TestSection({super.key});
//
//   void _startCarFlow(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const CarRideFlowBottomSheet(),
//     );
//   }
//
//   void _startShipFlow(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const ShipRideFlowBottomSheet(),
//     );
//   }
//
//   void _startPlaneFlow(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const AirplaneRideFlowBottomSheet(),
//     );
//   }
//   //
//   // void _startEnterAmountFlow(BuildContext context) {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (context) => InputAmountBottomSheet(mode: 'car',),
//   //   );
//   // }
//   //
//   // void _startSelectModeFlow(BuildContext context) {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (context) => DeliveryMethodSheet(),
//   //   );
//   // }
//
//   // void _startSendOrRequestFlow(BuildContext context) {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (context) => const SendOrRequestOptionBottomSheet(),
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarIconBrightness:  Brightness.dark,
//         statusBarColor: Colors.transparent,
//         systemNavigationBarColor: Colors.white,
//         systemNavigationBarIconBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(elevation: 0, backgroundColor: Colors.white,),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Center(
//             //   child: ElevatedButton(
//             //     onPressed: () => _startCarFlow(context),
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor: const Color(0xFF6C3916),
//             //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(12),
//             //       ),
//             //     ),
//             //     child: const Text(
//             //       'Start Car Ride Flow',
//             //       style: TextStyle(
//             //         fontSize: 16,
//             //         fontWeight: FontWeight.bold,
//             //         color: Colors.white,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // const SizedBox(height: 15,),
//             // Center(
//             //   child: ElevatedButton(
//             //     onPressed: () => _startShipFlow(context),
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor: const Color(0xFF6C3916),
//             //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(12),
//             //       ),
//             //     ),
//             //     child: const Text(
//             //       'Start Ship Ride Flow',
//             //       style: TextStyle(
//             //         fontSize: 16,
//             //         fontWeight: FontWeight.bold,
//             //         color: Colors.white,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // const SizedBox(height: 15,),
//             // Center(
//             //   child: ElevatedButton(
//             //     onPressed: () => _startPlaneFlow(context),
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor: const Color(0xFF6C3916),
//             //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(12),
//             //       ),
//             //     ),
//             //     child: const Text(
//             //       'Start Plane Ride Flow',
//             //       style: TextStyle(
//             //         fontSize: 16,
//             //         fontWeight: FontWeight.bold,
//             //         color: Colors.white,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // const SizedBox(height: 15,),
//             // Center(
//             //   child: ElevatedButton(
//             //     onPressed: () => _startEnterAmountFlow(context),
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor: const Color(0xFF6C3916),
//             //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(12),
//             //       ),
//             //     ),
//             //     child: const Text(
//             //       'Start Plane Ride Flow',
//             //       style: TextStyle(
//             //         fontSize: 16,
//             //         fontWeight: FontWeight.bold,
//             //         color: Colors.white,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // const SizedBox(height: 15,),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () => _startSendOrRequestFlow(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6C3916),
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Start Send Or Request Flow',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             // const SizedBox(height: 15,),
//             // Center(
//             //   child: ElevatedButton(
//             //     onPressed: () => _startSelectModeFlow(context),
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor: const Color(0xFF6C3916),
//             //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(12),
//             //       ),
//             //     ),
//             //     child: const Text(
//             //       'Start Select Mode Flow',
//             //       style: TextStyle(
//             //         fontSize: 16,
//             //         fontWeight: FontWeight.bold,
//             //         color: Colors.white,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }