import 'dart:convert';

import 'package:http/http.dart';
import 'package:network_layer/services/cache_service.dart';
import 'package:network_layer/utils/get_it_injection.dart';

import '../error/exceptions.dart';

class NetworkResponseHandler {
  NetworkResponseHandler();

  // network response handler for raw data requests
  Future<dynamic> call(Response res,) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final token = json.decode(res.body)['token'];
      if(token!=null){
        await getIt<CacheService>().setUserToken(token: token);
      }
      return res.body;
    }else if(res.statusCode==401){
      throw AuthException("Unauthenticated Please Login");
    }else if (res.statusCode==404){
      throw ServerException("Error: request not found");
    }
    else {
      throw ServerException("Error: ${res.statusCode}");
    }
  }

  // network response handler for form data and multipart requests
  Future<dynamic> handleFormData(StreamedResponse res,) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final token = json.decode(await res.stream.bytesToString())['token'];
      if(token!=null){
        await getIt<CacheService>().setUserToken(token: token);
      }
      return await res.stream.bytesToString();
    }else if(res.statusCode==401){
      throw AuthException("Unauthenticated Please Login");
    }else if (res.statusCode==404){
      throw ServerException("Error: request not found");
    }
    else {
      throw ServerException( "Error: ${res.statusCode}");
    }
  }
}
