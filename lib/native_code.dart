// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class NativeCode extends StatefulWidget {
//   const NativeCode({super.key});

//   @override
//   State<NativeCode> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<NativeCode> {
//   //قناة اتصال بين فلاتر ونيتف كود
//   static const MethodChannel _battaryChannel = MethodChannel("battery_channel");
//   //ارسال التغيرات
//   static const EventChannel _battaryEventChannel = EventChannel("battery_Event_channel");
//   static const EventChannel _networkEventChannel = EventChannel("network_Event_channel");
   
   
//     static const EventChannel _gyrooscopeChannel = EventChannel("gyroo_scoope");
//      String _gyroData = "waiting for sensor data ...";


//   String _batteryLevel ="unknown";
//    String _batteryStatus ="unknown";
//      String _networkStatus ="unknown";

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _getBatteryLevel();
//        _startGyroScopeListener();

//   _battaryEventChannel.receiveBroadcastStream().listen((event){
//     setState(() {
//       _batteryStatus = event.toString();
//     });
//   });
//   _networkEventChannel.receiveBroadcastStream().listen((event){
//     setState(() {
//       _networkStatus = event.toString();
//     });
//   });
//   }

//  void _startGyroScopeListener(){
//     _gyrooscopeChannel.receiveBroadcastStream().listen((event){
         
          
//          setState(() {
//           _gyroData = 'X: ${event['x']} , Y:${event['y']} , Z:${event['z']}';

//          });
//     },onError:(error){
//       setState(() {
//         _gyroData = 'Error $error';
//       });
//     }, onDone: (){
//       print("---->$_gyroData");
//     }
    
//     );
//   }

//   Future<void>_getBatteryLevel()async{
//     try{
//       //getBatteryLevel تابع بالنيتف ليجبلي حالة البطارية ويحطا ب level
//         final int level = await _battaryChannel.invokeMethod("getBatteryLevel");
         
//          setState(() {
//            _batteryLevel = "$level%";
//          });
         

//     }on PlatformException catch(e)
//     {
//       _batteryLevel ="failed:${e.message}";
//     }
//   }
 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Battery Level:$_batteryLevel"),
//             Text("Battery Status:$_batteryStatus"),
//             Text("Network Status:$_networkStatus"),
// Text("===================================================="),
//             Text(
//           _gyroData,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 15
//           ),
//         ),
//             ElevatedButton(onPressed: (){
//               _getBatteryLevel();
//             }, child:Text("get level"))
//           ],
//         ),
//       ),
//     );
//   }
// } 