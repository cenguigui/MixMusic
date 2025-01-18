import 'dart:convert';

import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../http/app_exceptions.dart';
import '../http/http.dart';
import '../http/http_dio.dart';

class CommonApi {
  CommonApi._();

  static var _init = false;

  ///初始化请求
  static Future<void> _initHttp() async {
    if (kDebugMode) {
      print("object");
    }
    if (!_init) {
      var cookie = await HttpDio().getCookieManager();
      Http.init(
        baseUrl: "http://127.0.0.0",
        interceptors: [cookie],
        connectTimeout: 30000,
      );
      _init = true;
    }
  }

  //公共请求方法
  static Future<T> post<T>(String path, {Map<String, dynamic>? params}) async {
    await _initHttp();

    return Http.post(
      path,
      data: params,
      options: Options(
        sendTimeout: const Duration(milliseconds: 15000),
        // 响应流上前后两次接受到数据的间隔，单位为毫秒。
        receiveTimeout: const Duration(milliseconds: 15000),
      ),
    ).then((value) {
      try {
        if (T is String) {
          return Future.value(value.toString() as T?);
        } else if (T is Map<dynamic, dynamic>) {
          return Future.value(value as T?);
        } else {
          /// List类型数据由fromJsonAsT判断处理
          return Future.value(JsonMapper.fromJson<T>(json.encode(value)));
        }
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        return Future.error(AppException(500, "对象转换异常"));
      }
    });
  }

  //公共请求方法
  static Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
    await _initHttp();

    return Http.get(
      path,
      params: params,
      options: Options(
        sendTimeout: const Duration(milliseconds: 15000),
        // 响应流上前后两次接受到数据的间隔，单位为毫秒。
        receiveTimeout: const Duration(milliseconds: 15000),
      ),
    ).then((value) {
      try {
        if (T is String) {
          return Future.value(value.toString() as T?);
        } else if (T is Map<dynamic, dynamic>) {
          return Future.value(value as T?);
        } else {
          /// List类型数据由fromJsonAsT判断处理
          return Future.value(JsonMapper.fromJson<T>(json.encode(value)));
        }
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        return Future.error(AppException(500, "对象转换异常"));
      }
    });
  }

  //公共请求方法
  static Future<T> postForm<T>(String path, {Map<String, dynamic>? params, List<String>? files}) async {
    await _initHttp();

    var fileParams = <String, dynamic>{};
    fileParams.addAll(params ?? {});

    await Future.forEach<String>(files ?? <String>[], (element) async {
      var index = files?.indexOf(element);
      print(element);
      fileParams["file$index"] = await MultipartFile.fromFile(element, filename: "file_${DateTime.now().millisecondsSinceEpoch}.jpg");
    });

    return Http.postForm(
      path,
      params: fileParams,
      options: Options(
        sendTimeout: const Duration(milliseconds: 15000),
        // 响应流上前后两次接受到数据的间隔，单位为毫秒。
        receiveTimeout: const Duration(milliseconds: 15000),
      ),
    ).then((value) {
      try {
        if (T is String) {
          return Future.value(value.toString() as T?);
        } else if (T is Map<dynamic, dynamic>) {
          return Future.value(value as T?);
        } else {
          /// List类型数据由fromJsonAsT判断处理
          return Future.value(JsonMapper.fromJson<T>(json.encode(value)));
        }
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        return Future.error(AppException(500, "对象转换异常"));
      }
    });
  }

  //下载
  static Future<String> download(String path, String dir, String? fileName, {Map<String, dynamic>? params, ProgressCallback? onReceiveProgress}) async {
    await _initHttp();
    params?.removeWhere((key, value) => value == null);

    var filePath = "";

    return Http.download(path, (Headers headers) {
      var name = headers["Content-Disposition"]?.first.split("filename=").last;
      var location = headers["uri"]?.firstOrNull;
      if (name != null) {
        name = Uri.decodeFull(name);
      } else if (location != null) {
        Uri uri = Uri.parse(location);
        name = uri.pathSegments.last;
      } else {
        Uri uri = Uri.parse(path);
        name = uri.pathSegments.last;
      }
      String fileExtension = name.split('.').last;

      var downloadName = fileName == null ? name : "$fileName.$fileExtension";
      print(downloadName);
      filePath = "$dir/$downloadName";
      return filePath;
    },
            params: {"params": json.encode(params)},
            options: Options(
              sendTimeout: const Duration(milliseconds: 30000),
              // 响应流上前后两次接受到数据的间隔，单位为毫秒。
              receiveTimeout: const Duration(milliseconds: 60000),
            ),
            onReceiveProgress: onReceiveProgress)
        .then((v) {
      return Future.value(filePath);
    });
  }

//下载
  static Future download2(String path, savePath, {Map<String, dynamic>? params, ProgressCallback? onReceiveProgress}) async {
    await _initHttp();
    params?.removeWhere((key, value) => value == null);

    return Http.download(path, savePath,
        params: {"params": json.encode(params)},
        options: Options(
          sendTimeout: const Duration(milliseconds: 30000),
          // 响应流上前后两次接受到数据的间隔，单位为毫秒。
          receiveTimeout: const Duration(milliseconds: 60000),
        ),
        onReceiveProgress: onReceiveProgress);
  }
}
