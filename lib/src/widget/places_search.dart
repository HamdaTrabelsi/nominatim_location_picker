import 'package:nominatim_location_picker/src/widget/location.dart';
import 'package:nominatim_location_picker/src/widget/predictions.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesSearch {
  /// API Key of the MapBox.
  final String apiKey;

  /// Specify the user’s language. This parameter controls the language of the text supplied in responses.
  ///
  /// Check the full list of [supported languages](https://docs.mapbox.com/api/search/#language-coverage) for the MapBox API
  final String language;

  ///Limit results to one or more countries. Permitted values are ISO 3166 alpha 2 country codes separated by commas.
  ///
  /// Check the full list of [supported countries](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) for the MapBox API
  final String country;

  /// Specify the maximum number of results to return. The default is 5 and the maximum supported is 10.
  final int limit;

  final String _url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/';

  PlacesSearch({
    this.apiKey,
    this.country,
    this.limit,
    this.language,
  }) : assert(apiKey != null);

  String _createUrl(String queryText, [Location location]) {
    String finalUrl = '$_url${Uri.encodeFull(queryText)}.json?';
    finalUrl += 'access_token=$apiKey';

    if (location != null) {
      finalUrl += '&proximity=${location.lng}%2C${location.lat}';
    }

    if (country != null) {
      finalUrl += "&country=$country";
    }

    if (limit != null) {
      finalUrl += "&limit=$limit";
    }

    if (language != null) {
      finalUrl += "&language=$language";
    }

    return finalUrl;
  }

  Future<List<MapBoxPlace>> getPlaces(
    String queryText, {
    Location location,
  }) async {
    String url = _createUrl(queryText, location);
    final response = await http.get(Uri(path: url));

    if (response?.body?.contains('message') ?? false) {
      throw Exception(json.decode(response.body)['message']);
    }

    return Predictions.fromRawJson(response.body).features;
  }
}
