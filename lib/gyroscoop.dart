// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class JuroScoop extends StatefulWidget {
//   const JuroScoop({super.key});

//   @override
//   State<JuroScoop> createState() => _JuroScoopState();
// }

// class _JuroScoopState extends State<JuroScoop> {

//     static const EventChannel _gyrooscopeChannel = EventChannel("gyroo_scoope");
//      String _gyroData = "waiting for sensor data ...";



//     @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//    _startGyroScopeListener();
//   }


//   void _startGyroScopeListener(){
//     _gyrooscopeChannel.receiveBroadcastStream().listen((event){
         
          
//          setState(() {
//           _gyroData = 'X: ${event['x']} , Y:${event['y']} , Z:${event['z']}';

//          });
//     },onError:(error){
//       setState(() {
//         _gyroData = 'Error $error';
//       });
//     } 
    
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text(
//           _gyroData,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 15
//           ),
//         ),
//       ),
//     );
//   }
// }