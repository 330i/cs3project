import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:parkit/models/pluscode.dart';

class LocalMap extends StatefulWidget {

  @override
  _LocalMapState createState() => _LocalMapState();
}

class _LocalMapState extends State<LocalMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: getCurrentLatLng().asStream(),
        builder: (context, currentLocation) {
          if(currentLocation.hasData) {
            LatLng currentLatLng = currentLocation.data as LatLng;
            return FutureBuilder(
              future: getPlusCode(),
              builder: (context, currentPlusCode) {
                if(currentPlusCode.hasData) {
                  return FutureBuilder(
                    future: FirebaseFirestore.instance.collection('spots').doc(currentPlusCode.data.toString().substring(0,4)).collection(currentPlusCode.data.toString().substring(0,4)).get(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        List<Marker> spotList = [];
                        spotList.add(
                          Marker(
                            width: 15.0,
                            height: 15.0,
                            point: currentLatLng,
                            builder: (ctx) =>
                            new Container(
                              child: Image.asset('assets/currentlocation.png'),
                            ),
                          ),
                        );
                        for(int i=0;i<(snapshot.data! as QuerySnapshot).docs.length;i++) {
                          DocumentSnapshot currentDoc = (snapshot.data as QuerySnapshot).docs[i];
                          spotList.add(SpotMarker(currentDoc['rate'], currentDoc['id']));
                        }
                        return FlutterMap(
                          options: new MapOptions(
                            center: currentLatLng,
                            zoom: 15.0,
                          ),
                          layers: [
                            new TileLayerOptions(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c']
                            ),
                            new MarkerLayerOptions(
                              markers: spotList,
                            ),
                          ],
                        );
                      }
                      else {
                        return FlutterMap(
                          options: new MapOptions(
                            center: currentLatLng,
                            zoom: 15.0,
                          ),
                          layers: [
                            new TileLayerOptions(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c']
                            ),
                            new MarkerLayerOptions(
                              markers: [
                                Marker(
                                  width: 15.0,
                                  height: 15.0,
                                  point: currentLatLng,
                                  builder: (ctx) =>
                                  new Container(
                                      child: Image.asset('assets/currentlocation.png')
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  );
                }
                else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          }
          else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  SpotMarker(var price, String plusCode) {
    return Marker(
      width: 105.0,
      height: 160.0,
      point: LatLng(getPosition(plusCode)[0], getPosition(plusCode)[1]),
      builder: (ctx) =>
      new Container(
        child: Column(
          children: [
            Container(
              height: 80,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${NumberFormat("\$#,##0.00", "en_US").format(price)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/hour',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Image.asset('assets/spot.png', fit: BoxFit.contain, height: 50,)
                ],
              ),
            ),
            Container(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
