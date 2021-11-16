import 'dart:async';
import 'dart:convert';
import 'package:asde_app/models/news.dart';
import 'package:asde_app/models/sector.dart';
import 'package:asde_app/models/service.dart';
import 'package:asde_app/models/tourist_sites.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<List<News>> fetchAllNews() async {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  List<News> newsList = [];
  final response = await http.get(
    Uri.parse(
        'https://ayuntamientosde.gob.do/wp-json/wp/v2/posts?categories=5'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final data = await jsonDecode(response.body);

    for (var i = 0; i < data.length; i++) {
      //String dateformatted =
      //  formatter.format(DateTime.parse(data[i]["date"].substring(1, 11)));
      newsList.add(News(
          id: data[i]["id"],
          title: data[i]["title"]["rendered"],
          image: await getNewsImage(
              data[i]["_links"]["wp:featuredmedia"][0]["href"]),
          date: formatter.format(DateTime.parse(data[i]["date"])),
          text: data[i]["content"]["rendered"]));
    }
    return newsList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load news');
  }
}

getNewsImage(href) async {
  final response = await http.get(Uri.parse(href));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["guid"]["rendered"];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print('Failed to load news image for: ' + href);
    return "";
  }
}

Future<List<TouristSite>> fetchAllTouristSites() async {
  List<TouristSite> sitesList = [];
  String response = await rootBundle.loadString('assets/tourist_sites.json');
  final data = await jsonDecode(response);
  for (var i = 0; i < data.length; i++) {
    sitesList.add(
      TouristSite(
          id: data[i]["id"],
          title: data[i]["title"],
          image: data[i]["image"],
          shortText: data[i]["shortText"],
          longText: data[i]["longText"],
          availability: data[i]["availability"],
          schedule: data[i]["schedule"],
          location: data[i]["location"],
          contact: data[i]["contact"]),
    );
  }
  return sitesList;
}

Future<List<Sector>> fetchAllSectors() async {
  List<Sector> sectorsList = [];
  final response = await http.get(
    Uri.parse(
        'https://api.digital.gob.do/v1/territories/sections?municipalityCode=01&provinceCode=32&regionCode=10'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final data = await jsonDecode(response.body);

    for (var i = 0; i < data["data"].length; i++) {
      sectorsList.add(
        Sector(
            code: data["data"][i]["code"],
            name: data["data"][i]["name"],
            districtCode: data["data"][i]["districtCode"]),
      );
    }
    return sectorsList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load sectors');
  }
}

Future<List<String>> fetchNeiborhoodsBySector(Sector section) async {
  List<String> neighborhoodsList = [];
  final response = await http.get(
    Uri.parse(
        'https://api.digital.gob.do/v1/territories/regions/10/provinces/32/municipalities/01/districts/${section.districtCode}/sections/${section.code}/neighborhoods'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final data = await jsonDecode(response.body);

    for (var i = 0; i < data["data"].length; i++) {
      neighborhoodsList.add(data["data"][i]["name"]);
    }
    return neighborhoodsList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load neighborhoods');
  }
}

Future<List<Service>> fetchAllServices() async {
  List<Service> servicesList = [];
  String response = await rootBundle.loadString('assets/services.json');
  final data = await jsonDecode(response);
  try {
    for (var i = 0; i < data.length; i++) {
      servicesList.add(
        Service(
          id: data[i]["id"],
          title: data[i]["title"],
          image: data[i]["image"],
          description: data[i]["description"],
          public: data[i]["public"],
          offerer: data[i]["offerer"],
          tel: data[i]["tel"],
          email: data[i]["email"].cast<String>(),
          requirements: data[i]["requirements"].cast<String>(),
          procedures: data[i]["procedures"].cast<String>(),
          availableDays: data[i]["available_days"],
          availableTime: data[i]["available_time"],
          cost: data[i]["cost"],
          expectedTime: data[i]["expected_time"],
          deliveryChannel: data[i]["delivery_channel"],
          additionalInformation: converToAdditionalInformationList(
              data[i]["additional_information"]),
        ),
      );
    }
  } catch (e) {
    print("ERROR");
    print(e.toString());
  }
  return servicesList;
}

List<AdditionalInformation> converToAdditionalInformationList(data) {
  List<AdditionalInformation> additionalInformationList = [];
  for (var i = 0; i < data.length; i++) {
    additionalInformationList.add(AdditionalInformation(
      text: data[i]["text"],
      isBold: data[i]["is_bold"],
      color: data[i]["color"],
    ));
  }
  return additionalInformationList;
}