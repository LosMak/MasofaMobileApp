# Flutter Freezed Models Guide

This guide outlines how to create Dart models using the Freezed package for Flutter applications. Freezed provides immutable model classes with built-in serialization, equality, and copy functionality.

## Model Structure and Requirements

### Basic Model Template

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_model.freezed.dart';
part 'example_model.g.dart';

@freezed
class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    @Default('') String id,
    @Default(0) int count,
    @Default(false) bool isActive,
    String? optionalField,
    required DateTime createdAt,
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

### Key Components

1. **Imports and Part Declarations**:
   - Always import `freezed_annotation`
   - Include part files for the generated code
   - Name part files to match the model file name

2. **Class Annotation**:
   - Use `@freezed` annotation for all model classes
   - Class name should follow PascalCase and end with "Model"

3. **Factory Constructors**:
   - Primary constructor should be `const factory`
   - Always include `fromJson` factory for serialization

4. **Fields and Defaults**:
   - Use `@Default()` for fields with default values
   - Use nullable types with `?` for optional fields
   - Use `required` keyword for mandatory fields

## Field Types and Patterns

### Primitive Types
```dart
@Default('') String textField,
@Default(0) int countField,
@Default(0.0) double valueField,
@Default(false) bool flagField,
DateTime? dateField,
```

### Collections
```dart
@Default([]) List<String> stringList,
@Default({}) Map<String, dynamic> properties,
@Default(<String>{}) Set<String> uniqueValues,
```

### Nested Models
```dart
@Default(SubModel()) SubModel subModel,
@Default([]) List<SubModel> items,
```

### Enums
```dart
@Default(Status.pending) Status status,
@JsonKey(fromJson: _statusFromJson, toJson: _statusToJson) Status mappedStatus,
```

## Custom Serialization

### Custom JSON Keys
```dart
@JsonKey(name: 'user_id') String userId,
@JsonKey(includeIfNull: false) String? optionalField,
```

### Custom Converters
```dart
@JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) DateTime createdAt,

// Helper functions for conversion
DateTime _dateFromJson(dynamic value) {
  if (value == null) return DateTime.now();
  return DateTime.parse(value.toString());
}

String _dateToJson(DateTime date) => date.toIso8601String();
```

### Enum Conversion
```dart
enum UserRole {
  @JsonValue('admin') admin,
  @JsonValue('user') user,
  @JsonValue('guest') guest,
}

@JsonKey(unknownEnumValue: UserRole.guest) UserRole role,
```

## Special Patterns

### Custom Constructors
```dart
const factory ExampleModel.empty() = _ExampleModel;

factory ExampleModel.fromString(String data) {
  // Custom parsing logic
  final json = jsonDecode(data);
  return ExampleModel.fromJson(json);
}
```

### Nested Freezed Models
```dart
@freezed
class ParentModel with _$ParentModel {
  const factory ParentModel({
    @Default('') String id,
    @Default([]) List<ChildModel> children,
  }) = _ParentModel;

  factory ParentModel.fromJson(Map<String, dynamic> json) =>
      _$ParentModelFromJson(json);
}

@freezed
class ChildModel with _$ChildModel {
  const factory ChildModel({
    @Default('') String name,
    @Default(0) int value,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}
```

### Complex Nesting with Records
```dart
@freezed
class GeoModel with _$GeoModel {
  const factory GeoModel({
    @Default('') String type,
    @Default([]) List<List<({double lat, double lng})>> coordinates,
  }) = _GeoModel;

  factory GeoModel.fromJson(Map<String, dynamic> json) =>
      _$GeoModelFromJson(json);
}
```

## Project Setup Requirements

Ensure your `pubspec.yaml` includes the required dependencies:

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.7.0
```

## Code Generation

After defining your models, run the following command to generate necessary code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Best Practices

1. Use meaningful field names that follow Dart naming conventions
2. Group related models in the same file for small models
3. Use separate files for complex models
4. Always provide sensible default values to ensure null safety
5. Use custom serialization when API responses don't match your preferred model structure
6. Document complex models with comments explaining any non-obvious fields
7. Create extension methods for complex models for additional functionality

## Troubleshooting

- If you see errors about missing part files, run the code generation command
- For serialization issues, check your custom JSON converters
- For complex nested structures, use custom fromJson implementations
- Always handle potential null values in API responses
