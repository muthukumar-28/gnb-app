class Property {
  final String id;
  final String title;
  final String description;
  final int bedrooms;
  final int bathrooms;
  final int areaSqFt;
  final double price;
  final String currency;
  final String status;
  final String dateListed;
  final List<String> images;
  final List<String> tags;
  final Agent agent;
  final Location location;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqFt,
    required this.price,
    required this.currency,
    required this.status,
    required this.dateListed,
    required this.images,
    required this.tags,
    required this.agent,
    required this.location,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      areaSqFt: json['areaSqFt'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      dateListed: json['dateListed'],
      images: List<String>.from(json['images']),
      tags: List<String>.from(json['tags']),
      agent: Agent.fromJson(json['agent']),
      location: Location.fromJson(json['location']),
    );
  }
}

class Agent {
  final String name;
  final String email;
  final String contact;

  Agent({required this.name, required this.email, required this.contact});

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      name: json['name'],
      email: json['email'],
      contact: json['contact'],
    );
  }
}

class Location {
  final String address;
  final String city;
  final String state;
  final String zip;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      country: json['country'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
