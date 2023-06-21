import 'package:flutter/material.dart';
import 'package:foursquare/foursquare.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foursquare Venues',
      home: FoursquareVenuesPage(),
    );
  }
}

class FoursquareVenuesPage extends StatefulWidget {
  @override
  _FoursquareVenuesPageState createState() => _FoursquareVenuesPageState();
}

class _FoursquareVenuesPageState extends State<FoursquareVenuesPage> {
  late API client;
  late Position location;
  late Future<List<Venue>> _venues;

  @override
  void initState() {
    super.initState();

    client = API.authed('FOURSQUARE_OAUTH_TOKEN');
    _venues = getVenues();
  }

  Future<List<Venue>> getVenues() async {
    await Permission.location.request();
    Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true);
    return Venue.search(client, location.latitude, location.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Venue>>(
      future: _venues,
      builder: (BuildContext context, AsyncSnapshot<List<Venue>> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return new Center(child: new CircularProgressIndicator());
        } else {
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          else {
            final venues = snapshot.data!;
            return Scaffold(
              body: ListView.builder(
                itemCount: venues.length,
                itemBuilder: (context, index) {
                  Venue venue = venues.elementAt(index);
                  return ListTile(
                    title: Text(venue.name ?? ''),
                    subtitle: Text(venue.location ?? ''),
                    onTap: () {
                      checkIn(venue);
                    },
                  );
                },
              ),
            );
          }
        }
      },
    );
  }

  void checkIn(Venue venue) async {
    await Checkin.add(client, venue);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in to ${venue.name}'),
      ),
    );
  }
}