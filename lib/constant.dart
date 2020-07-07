import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Marker kmarker = Marker(
  markerId: MarkerId("home"),
  //position: latlng,
  //rotation: newLocalData.heading,
  draggable: false,
  zIndex: 2,
  flat: true,
  anchor: Offset(0.5, 0.5),
);
//icon: BitmapDescriptor.fromBytes(imageData))

Circle kcircle = Circle(
  circleId: CircleId("car"),
  //radius: newLocalData.accuracy,
  zIndex: 1,
  strokeColor: Colors.blue,
  //center: latlng,
  fillColor: Colors.blue.withAlpha(70),);