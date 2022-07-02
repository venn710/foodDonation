class DeliveryAgent {
  double latitude;
  double longitude;
  String name;
  int mobileNumber;

  DeliveryAgent(
      {required this.longitude,
      required this.latitude,
      required this.name,
      required this.mobileNumber});

  factory DeliveryAgent.fromJson(json) {
    return DeliveryAgent(
        longitude: json['longitude'],
        latitude: json['latitude'],
        name: json['name'],
        mobileNumber: json['mobileNumber']);
  }
}
