import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'constant.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Map Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController _controller;
  List<StreamSubscription> _locationSubscription = [];
  List<Location> _locationTracker = [];
  List<Marker> MarkersOfBus = [];
  List<Circle> MarkersAroundBus = [];

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(
        "assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void AddVehicle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {

      _locationTracker.add(new Location());

      MarkersOfBus.add(kmarker.copyWith(
        positionParam:  latlng,
        rotationParam: newLocalData.heading,
      ));

      MarkersAroundBus.add(kcircle.copyWith(
        radiusParam: newLocalData.accuracy,
        centerParam: latlng,
      ));
    });
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      for( int i = 0 ; i<MarkersOfBus.length ; i+=1 ){
          MarkersOfBus[i] = kmarker.copyWith(
            positionParam:  latlng,
            rotationParam: newLocalData.heading,
          );
          MarkersAroundBus[i] = kcircle.copyWith(
            radiusParam: newLocalData.accuracy,
            centerParam: latlng,
          );
      }
    });
  }

  void getCurrentLocation() async {
    try {
      for( int i = 0 ; i<_locationTracker.length ; i+=1 ) {
        Uint8List imageData = await getMarker();
        var location = await _locationTracker[i].getLocation();
        updateMarkerAndCircle(location, imageData);

        if (_locationSubscription[i] != null) {
          _locationSubscription[i].cancel();
        }

        _locationSubscription[i] = _locationTracker[i].onLocationChanged().listen((newLocalData) {
              if (_controller != null) {
                _controller.animateCamera(
                    CameraUpdate.newCameraPosition(new CameraPosition(
                        bearing: 192.8334901395799,
                        target: LatLng(
                            newLocalData.latitude, newLocalData.longitude),
                        tilt: 0,
                        zoom: 18.00)));
                updateMarkerAndCircle(newLocalData, imageData);
              }
            });
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    for( int i = 0 ; i<_locationSubscription.length ; i+=1 )
      if (_locationSubscription[i] != null) {
        _locationSubscription[i].cancel();
      }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: Set.of((MarkersOfBus != null) ? MarkersOfBus : []),
        circles: Set.of((MarkersAroundBus != null) ? MarkersAroundBus : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}
