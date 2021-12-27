import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:badger_group_up/src/system/session_manager/location.dart';
import 'package:badger_group_up/src/system/shared_values.dart';

///Progress
/// Base UI <--
/// Connect to DB
/// Implement Functions
/// Finish UI overflow
///
class MapViewWidget extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  MapViewWidget({Key? key}) : super(key: key);

  @override
  _MapViewWidgetState createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  BitmapDescriptor greenMapIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor redMapIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    greenMapIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'assets/greenMapIcon.png');
    redMapIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'assets/redMapIcon.png');
  }

  final Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _markers = <Marker>[];
  bool onthelake = false;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(43.0770162, -89.416099),
    zoom: 17,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 90, target: LatLng(43.0770162, -89.416799), tilt: 0, zoom: 17);

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      body: GoogleMap(
        mapType: MapType.satellite,
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(_markers),
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(Utils.mapStyles);
          _controller.complete(controller);
          setState(() {
            for (var location in Location.locations) {
              _markers.add(getMarkerList(context, location));
            }
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              top: 30,
              right: 20,
              child: Align(
                child: FloatingActionButton(
                  backgroundColor: MyTheme.mainColor,
                  heroTag: 'realign',
                  onPressed: _realign,
                  child: const Icon(
                    Icons.my_location,
                    size: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                alignment: const Alignment(4, 3.7),
              )),
        ],
      ),
    );
    return Column(children: [
        Expanded(
        flex: 8,
        child: scaffold)
    ,
    Expanded(flex: 1, child: Container())]);
  }

  Marker getMarkerList(BuildContext context, Location entry) {
    return Marker(
        markerId: MarkerId(entry.id),
        position: LatLng(entry.xPos, entry.yPos),
        infoWindow: InfoWindow(
            title: entry.name,
            snippet: "Tap for more details",
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(height: 400, color: Colors.red, child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Activity: ' + entry.name.split(" ")[0],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('\n'),
                          Text('Location: ' + entry.name.split(", ")[1], style: TextStyle(color: Colors.white, fontSize: 16)),
                          Text('\n'),
                        ],
                      ),
                    ),
                  );
                },
              );
              //showJoinDialog(context);
            }),
        icon: greenMapIcon);
  }

  Future<void> _realign() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]''';
}
