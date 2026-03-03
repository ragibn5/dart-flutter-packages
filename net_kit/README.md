# net_kit

A wrapper around [`Dio`](https://pub.dev/packages/dio) that centralizes error and data
transformation.

## Features

- Centralized error conversion
- Centralized request and response serialization/deserialization

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  parser: ^0.0.1
  net_kit: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  parser:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser
      ref: main
  net_kit:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: net_kit
      ref: main
```

## Get Started

### [`NetKit`](lib/net_kit.dart)

The main class that handles all network operations. It requires three components:

1. **[`Dio`](https://pub.dev/packages/dio) Client** (Required)
    - Used as the underlying HTTP client for all network requests
    - Must be configured before passing to NetKit
    - Configure base URL, timeouts, and other settings as needed

2. **[`ErrorMapper`](lib/src/services/error_mapper.dart)** (Required)
    - Maps errors or exceptions to your custom error type
    - Enables type-safe error handling
    - Can use any error type that fits your needs

3. **[`Parser`](../parser/lib/src/parser_base.dart)** (From Different package,
   Required)
    - Handles serialization/deserialization of request and response data
    - For JSON APIs, you can use [
      `JsonParser`](../parser/lib/src/parser_impls/json_parser.dart)
    - See the [`parser_generator`](../parser_generator), and [
      `parser_analyzer`](../parser_analyzer) packages for advanced features, like:
        - Auto generation of prefilled parser implementation
        - Static analysis for compatibility checking with the available parsers

Example setup:

```dart
// Create a dio client
final dio = Dio(
   BaseOptions(
      baseUrl: 'https://example.api.com',
      connectTimeout: const Duration(seconds: 5),
   ),
);

// Consider `MyJsonParser` is a subclass of `JsonParser`
// See the `Example` section at the end for an example implementarion of `JsonParser`.
final jsonParser = MyJsonParser();

// Consider `ApiErrorMapper` is a subclass of `ErrorMapper`
// See the `Example` section at the end for an example implementarion of `ApiErrorMapper`.
final errorMapper = ApiErrorMapper();

// Now create the `NetKit` using the instances created above.
// The the examples below to know how to make api calls in a type safe manner.
final client = NetKit(
   client: dio,
   dataParser: jsonParser,
   errorMapper: errorMapper,
);
```

## Making Network Calls

Once you have set up your `NetKit`, you can make various HTTP requests to your API. The
client provides type-safe methods for common HTTP operations:

### Basic HTTP Requests

You can use the build in methods to make network requests and get strongly typed results.
Here is an example of `GET` and `POST` requests (Other methods like `PUT`, `PATCH`, `DELETE` are
also available)

```dart
// GET request
final Result<MyErrorType, UserModel> response = await client.get<UserModel>('/users/1');

// POST request with body
final Result<MyErrorType, LoginResponse> response = await client.post<LoginResponse>(
   '/login',
   // No need to call `jsonEncode`, just pass the data
   data: LoginRequest(username: 'user', password: '****'),
);

// POST request with body, query params and options
final Result<MyErrorType, UserFeed> response = await client.get<UserFeed>(
   '/products',
   data: Location(latitude: '18.0123', longitude: '20.123'),
   queryParameters: {
      'page': 1,
      'limit': 10,
   },
   options: Options(
      headers: {'Authorization': 'Bearer $token'},
      responseType: ResponseType.json,
   ),
);
```

### Raw Responses

For special cases where you need direct access to the raw response:

```dart
final Response<dynamic> rawResponse = await client.executeRaw<dynamic>(
  '/special-endpoint',
  options: RequestOptions(method: 'GET'),
);

// Access raw response data
final int? statusCode = rawResponse.statusCode;
final Headers headers = rawResponse.headers;
final dynamic rawData = rawResponse.data;
```

### Handling Responses with Result Type

All network calls return a `Result<ErrorType, DataType>` which can be handled in a type-safe way:

```dart
final Result<MyErrorType, UserModel> response = await client.get<UserModel>('/users/1');

// Using fold to handle both success and error cases
final String message = response.fold(
   (MyErrorType error) => 'Error: ${error.message}',
   (UserModel user) => 'User name: ${user.name}',
);

// Alternative pattern with if checks
if (response.isSuccess) {
   final UserModel user = response.resultOrNull!;
   // Use user object ...
} else {
   final MyErrorType error = response.errorOrNull!;
   // Handle error ...
}
```

### Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.
