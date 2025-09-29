# Flutter BLoC Pattern Documentation

This document outlines the patterns and conventions for implementing the BLoC (Business Logic Component) pattern in Flutter applications. Following these guidelines will help maintain consistency across your codebase and make it easier for team members to understand and modify the code.

## Table of Contents

1. [Project Structure](#project-structure)
2. [BLoC Structure](#bloc-structure)
3. [VarStatus Class Usage](#varstatus-class-usage)
4. [Event Handling Pattern](#event-handling-pattern)
5. [State Management Pattern](#state-management-pattern)
6. [BLoC Implementation Examples](#bloc-implementation-examples)
7. [Best Practices](#best-practices)

## Project Structure

The BLoC components should be organized in the following structure:

```
lib/
└── application/
    ├── var_status.dart
    ├── feature1/
    │   ├── feature1_bloc.dart
    │   ├── feature1_event.dart 
    │   └── feature1_state.dart
    └── feature2/
        ├── feature2_bloc.dart
        ├── feature2_event.dart
        └── feature2_state.dart
```

> **Note**: In actual implementation, the `*_event.dart` and `*_state.dart` files are usually defined as part of the `*_bloc.dart` file using the `part of` directive.

## BLoC Structure

### 1. Event Class

Events represent the input to a BLoC. They are dispatched from the UI to trigger state changes.

```dart
part of 'feature_bloc.dart';

@freezed
class FeatureEvent with _$FeatureEvent {
  // Event with no parameters
  const factory FeatureEvent.init() = _Init;
  
  // Event with required parameters
  const factory FeatureEvent.loadData({
    required String id,
  }) = _LoadData;
  
  // Event with optional parameters and defaults
  const factory FeatureEvent.refreshData({
    @Default(false) bool clearCache,
    @Default(false) bool requiredRemote,
  }) = _RefreshData;
}
```

### 2. State Class

States represent the output of a BLoC and are consumed by the UI.

```dart
part of 'feature_bloc.dart';

@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState.initial({
    // Group state variables by event
    
    /// FeatureEvent.loadData
    @Default(VarStatus()) VarStatus dataStatus, 
    @Default([]) List<DataModel> items,
    
    /// FeatureEvent.refreshData
    @Default(VarStatus()) VarStatus refreshStatus,
    @Default(false) bool hasMore,
    @Default(1) int page,
  }) = _Initial;
}
```

### 3. BLoC Class

The BLoC class handles the business logic, transforming events into states.

```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../var_status.dart';
import '../../domain/models/data_model.dart';
import '../../domain/facades/data_facade.dart';

part 'feature_bloc.freezed.dart';
part 'feature_event.dart';
part 'feature_state.dart';

@Injectable()
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final DataFacade _facade;
  
  FeatureBloc(this._facade) : super(const FeatureState.initial()) {
    on<_Init>(_onInit);
    on<_LoadData>(_onLoadData);
    on<_RefreshData>(_onRefreshData);
  }
  
  Future<void> _onInit(_Init event, Emitter<FeatureState> emit) async {
    // Implementation for initialization logic
  }
  
  Future<void> _onLoadData(_LoadData event, Emitter<FeatureState> emit) async {
    emit(state.copyWith(dataStatus: VarStatus.loading()));
    
    final result = await _facade.getData(event.id);
    
    result.fold(
      (l) => emit(state.copyWith(dataStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(
        dataStatus: VarStatus.success(),
        items: r,
      )),
    );
  }
  
  Future<void> _onRefreshData(_RefreshData event, Emitter<FeatureState> emit) async {
    // Implementation for refresh logic
  }
}
```

## VarStatus Class Usage

The `VarStatus` class is used to track the status of asynchronous operations:

```dart
// Example of using VarStatus in a BLoC
emit(state.copyWith(dataStatus: VarStatus.loading()));

final result = await _facade.getData();

result.fold(
  (error) => emit(state.copyWith(dataStatus: VarStatus.fail(error))),
  (data) => emit(state.copyWith(
    dataStatus: VarStatus.success(),
    items: data,
  )),
);
```

In UI:

```dart
return BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    return state.dataStatus.when(
      initial: () => const SizedBox(),
      loading: () => const CircularProgressIndicator(),
      success: () => ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(state.items[index].title),
        ),
      ),
      fail: (error) => Text('Error: $error'),
    );
  },
);
```

## Event Handling Pattern

Each event should follow a consistent pattern:

1. Update the status to loading
2. Call the appropriate facade method
3. Handle success or failure cases

```dart
Future<void> _onEventName(_EventName event, Emitter<FeatureState> emit) async {
  // 1. Update status to loading
  emit(state.copyWith(eventStatus: VarStatus.loading()));
  
  // 2. Call facade method
  final result = await _facade.methodName(
    param1: event.param1,
    param2: event.param2,
  );
  
  // 3. Handle result
  result.fold(
    (l) => emit(state.copyWith(eventStatus: VarStatus.fail(l))),
    (r) => emit(state.copyWith(
      eventStatus: VarStatus.success(),
      resultData: r,
    )),
  );
}
```

## State Management Pattern

1. Group state variables by the events that modify them
2. Use comments to indicate which event the variables belong to
3. Use `VarStatus` to track the status of asynchronous operations
4. Use default values to initialize state variables

```dart
@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState.initial({
    /// FeatureEvent.loadItems
    @Default(VarStatus()) VarStatus itemsStatus,
    @Default([]) List<ItemModel> items,
    
    /// FeatureEvent.loadDetails
    @Default(VarStatus()) VarStatus detailsStatus,
    @Default(ItemDetailModel()) ItemDetailModel details,
    
    /// FeatureEvent.paginate
    @Default(1) int page,
    @Default(10) int pageSize,
    @Default(true) bool hasMore,
  }) = _Initial;
}
```

## BLoC Implementation Examples

### Pagination Example

```dart
// Event
const factory FeatureEvent.loadPage() = _LoadPage;
const factory FeatureEvent.loadNextPage() = _LoadNextPage;

// State variables
@Default(VarStatus()) VarStatus pageStatus,
@Default([]) List<ItemModel> items,
@Default(1) int page,
@Default(10) int pageSize,
@Default(true) bool hasMore,

// Implementation
Future<void> _onLoadPage(_LoadPage event, Emitter<FeatureState> emit) async {
  emit(state.copyWith(
    pageStatus: VarStatus.loading(),
    items: [],
    page: 1,
  ));
  
  final result = await _facade.getItems(
    page: 1,
    pageSize: state.pageSize,
  );
  
  result.fold(
    (l) => emit(state.copyWith(pageStatus: VarStatus.fail(l))),
    (r) => emit(state.copyWith(
      pageStatus: VarStatus.success(),
      items: r,
      hasMore: r.length == state.pageSize,
    )),
  );
}

Future<void> _onLoadNextPage(_LoadNextPage event, Emitter<FeatureState> emit) async {
  if (state.pageStatus.isLoading || !state.hasMore) return;
  
  emit(state.copyWith(pageStatus: VarStatus.loading()));
  
  final nextPage = state.page + 1;
  final result = await _facade.getItems(
    page: nextPage,
    pageSize: state.pageSize,
  );
  
  result.fold(
    (l) => emit(state.copyWith(pageStatus: VarStatus.fail(l))),
    (r) => emit(state.copyWith(
      pageStatus: VarStatus.success(),
      items: [...state.items, ...r],
      page: nextPage,
      hasMore: r.length == state.pageSize,
    )),
  );
}
```

### Location Tracking Example

```dart
// Event
const factory LocationEvent.init() = _Init;
const factory LocationEvent.check(PolygonModel polygon) = _Check;

// State
@Default(VarStatus()) VarStatus locationStatus,
Position? position,
@Default(VarStatus()) VarStatus checkStatus,

// Implementation
Future<void> _onInit(_Init event, Emitter<LocationState> emit) async {
  emit(state.copyWith(locationStatus: VarStatus.loading()));
  
  await emit.forEach(
    _locationService.position(),
    onData: (position) {
      return state.copyWith(
        locationStatus: VarStatus.success(),
        position: position,
      );
    },
    onError: (error, _) => state.copyWith(
      locationStatus: VarStatus.fail(error.toString()),
    ),
  );
}

Future<void> _onCheck(_Check event, Emitter<LocationState> emit) async {
  if (state.position == null) return;
  
  emit(state.copyWith(checkStatus: VarStatus.loading()));
  
  final isInside = _locationService.isInPolygon(
    event.polygon,
    state.position!,
  );
  
  if (isInside) {
    emit(state.copyWith(checkStatus: VarStatus.success()));
  } else {
    emit(state.copyWith(
      checkStatus: VarStatus.fail("Not in polygon"),
    ));
  }
}
```

## Best Practices

1. **Naming Conventions**
   - BLoC class: `FeatureBloc`
   - Event class: `FeatureEvent`
   - State class: `FeatureState`
   - Event handlers: `_onEventName`

2. **Dependencies**
   - Inject dependencies through the constructor
   - Use dependency injection framework (e.g., GetIt with injectable)

3. **Error Handling**
   - Use `Either<Failure, Success>` pattern for error handling
   - Always handle both success and failure cases

4. **State Management**
   - Keep state immutable
   - Use `copyWith` for state updates
   - Group state variables by event
   - Use comments to indicate which event the variables belong to

5. **Documentation**
   - Document complex event handlers
   - Provide usage examples in comments for non-obvious functionality

6. **Testing**
   - Write unit tests for BLoC event handlers
   - Mock dependencies for testing

7. **Performance**
   - Avoid unnecessary state emissions
   - Check status before proceeding with operations
   - Handle edge cases like already loading, empty results, etc.

---

This document serves as a guideline for implementing the BLoC pattern in your Flutter application. Following these conventions will help maintain consistency and make your code more maintainable.
