# Data Source Creation Guidelines

This document outlines the patterns and rules for creating data sources in Flutter projects with clean architecture.

## Basic Structure

Each data source should:
1. Implement a domain facade interface
2. Use dependency injection (Injectable)
3. Return Either<dynamic, T> for all methods
4. Handle errors properly

## Template Pattern

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:your_app/domain/facades/your_facade.dart';
import 'package:your_app/domain/models/your_model.dart';
import 'package:your_app/infrastructure/services/http/http_service.dart';

@Injectable(as: YourFacade)
class YourDataSource implements YourFacade {
  final HttpService _http;
  
  const YourDataSource(this._http);
  
  @override
  Future<Either<dynamic, YourModel>> getItem(
    String id, {
    required bool requiredRemote,
  }) async {
    final client = _http.client(
      requiredToken: true,
      requiredRemote: requiredRemote,
      cacheDuration: const Duration(minutes: 30),
    );

    final path = '/your/endpoint/$id';

    try {
      final response = await client.get(path);
      return right(YourModel.fromJson(response.data));
    } catch (e) {
      return left(e);
    }
  }
  
  @override
  Future<Either<dynamic, List<YourModel>>> getItems({
    required int page,
    required int size,
    required bool requiredRemote,
    String? filterId,
  }) async {
    final client = _http.client(
      requiredToken: true,
      requiredRemote: requiredRemote,
      cacheDuration: const Duration(minutes: 30),
    );

    const path = '/your/endpoint/filter';
    final queryParam = {'startPage': page, 'pageSize': size};
    final data = {
      if (filterId != null) "filterId": filterId,
      "active": true,
    };

    try {
      final response = await client.post(
        path,
        queryParameters: queryParam,
        data: data,
      );

      final list = ((response.data["data"] ?? []) as List)
          .map((e) => YourModel.fromJson(e))
          .toList();
      return right(list);
    } catch (e) {
      return left(e);
    }
  }
  
  @override
  Future<Either<dynamic, void>> updateItem(YourModel model) async {
    final client = _http.client(requiredRemote: true, requiredToken: true);

    const path = '/your/endpoint';

    try {
      await client.put(path, data: model.toJson());
      return right(null);
    } catch (e) {
      return left(e);
    }
  }
}
```

## Key Rules

### 1. HTTP Client Configuration

```dart
final client = _http.client(
  requiredToken: true,          // Whether the request needs authentication
  requiredRemote: requiredRemote, // Whether to force remote fetch or allow cache
  cacheDuration: const Duration(minutes: 30), // How long to cache the response
);
```

### 2. Error Handling

Always use try-catch and return a left value with the error:

```dart
try {
  // API call
  return right(result);
} catch (e) {
  return left(e);
}
```

### 3. Data Transformation

Transform API responses to domain models:

```dart
// For single objects
return right(YourModel.fromJson(response.data));

// For lists
final list = ((response.data["data"] ?? []) as List)
    .map((e) => YourModel.fromJson(e))
    .toList();
return right(list);
```

### 4. Request Parameters

Organize request parameters clearly:

```dart
// Query parameters
final queryParam = {'startPage': page, 'pageSize': size};

// Request body
final data = {
  if (filterId != null) "filterId": filterId,
  "active": true,
};
```

### 5. File Uploads and Form Data

For file uploads, use FormData:

```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    filePath,
    filename: 'filename.ext',
  ),
  'otherField': 'value',
});

await client.post(path, data: formData, onSendProgress: onSendProgress);
```

### 6. Custom Headers

Set headers when needed:

```dart
await client.post(
  path,
  data: data,
  options: Options(headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'CustomHeader': 'value',
  }),
);
```

### 7. Cache Management

For cache operations:

```dart
// Set cache
await _cache.setItem(id, data);

// Get from cache
final result = _cache.getItem(id);

// Clear cache
await _cache.clear();
await _http.clearCache();
```

## Common Patterns

### GET Request

```dart
final response = await client.get('/endpoint/${id}');
return right(Model.fromJson(response.data));
```

### POST Request with Filtering

```dart
final response = await client.post(
  '/endpoint/filter',
  queryParameters: {'page': page, 'size': size},
  data: {'filterId': filterId},
);
```

### PUT Request for Updates

```dart
await client.put('/endpoint', data: model.toJson());
return right(null);
```

### DELETE Request

```dart
await client.delete('/endpoint/${id}');
return right(null);
```

## Handling Different Response Types

### JSON Object Response

```dart
return right(Model.fromJson(response.data));
```

### Paginated List Response

```dart
final list = ((response.data["data"] ?? []) as List)
    .map((e) => Model.fromJson(e))
    .toList();
return right(list);
```

### Simple List Response

```dart
final list = ((response.data ?? []) as List)
    .map((e) => Model.fromJson(e))
    .toList();
return right(list);
```

### Boolean or Void Response

```dart
// For endpoints that return success/failure
return right(null);
```

## Additional Services

Remember to inject any additional services needed for complex operations:

```dart
@Injectable(as: ComplexFacade)
class ComplexDataSource implements ComplexFacade {
  final HttpService _http;
  final AppCache _cache;
  final ArchiveService _archive;

  const ComplexDataSource(this._http, this._cache, this._archive);
  
  // Methods using all three services...
}
```
