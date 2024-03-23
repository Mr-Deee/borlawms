

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Clientdetails
{
  String? client_Address;
  String ?finalClient_address;
  LatLng ?pickup;
  LatLng ?dropoff;
  String ? artisan_request_id;
  String ?payment_method;
  String ?client_name;
  String ?client_phone;

  Clientdetails({this.client_Address, this.finalClient_address, this.pickup, this.dropoff, this.artisan_request_id, this.payment_method, this.client_name, this.client_phone});
}