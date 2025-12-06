# Performance Optimization Guide - Advisor Desk

This document outlines performance optimization strategies for the Advisor Desk application to ensure smooth, responsive user experience.

## 🎯 Performance Goals

- App startup time: < 2 seconds
- Screen transitions: < 300ms
- UI frame rate: 60 FPS (16ms per frame)
- Memory usage: < 200MB for typical usage
- Database queries: < 100ms for most operations

## 🚀 Optimization Strategies

### 1. Use Const Constructors

Const constructors prevent unnecessary widget rebuilds:

```dart
// ❌ Before (Creates new object on every rebuild)
Widget build(BuildContext context) {
  return Text(
    'Total Calls',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );
}

// ✅ After (Reuses existing object)
Widget build(BuildContext context) {
  return const Text(
    'Total Calls',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );
}
```

**Files to optimize:**
- `lib/presentation/features/dashboard/widgets/dashboard_card.dart`
- `lib/presentation/common/widgets/empty_state_widget.dart`
- `lib/presentation/common/widgets/custom_divider.dart`

### 2. Implement ListView.builder for Large Lists

Use ListView.builder for lazy loading instead of ListView:

```dart
// ❌ Before (Loads all items at once)
ListView(
  children: entries.map((entry) => EntryCard(entry)).toList(),
)

// ✅ After (Loads items on demand)
ListView.builder(
  itemCount: entries.length,
  itemBuilder: (context, index) {
    return EntryCard(entries[index]);
  },
)
```

### 3. Optimize Image Loading

Implement efficient image loading and caching:

```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 300, // Resize for memory efficiency
  memCacheHeight: 300,
)

// For local images, specify dimensions
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
  cacheWidth: 100,
  cacheHeight: 100,
)
```

### 4. Debounce Expensive Operations

Debounce search and filter operations:

```dart
import 'dart:async';

class SearchWidget extends StatefulWidget {
  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  Timer? _debounce;
  
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Perform expensive search operation
      _performSearch(query);
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

### 5. Use RepaintBoundary for Complex Widgets

Isolate complex widgets to prevent unnecessary repaints:

```dart
// Wrap expensive-to-paint widgets
RepaintBoundary(
  child: ComplexChart(),
)

// Use for animations that don't affect other widgets
RepaintBoundary(
  child: AnimatedWidget(),
)
```

### 6. Implement Pagination

Load data in chunks instead of all at once:

```dart
class PaginatedList extends StatefulWidget {
  @override
  State<PaginatedList> createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  final ScrollController _scrollController = ScrollController();
  List<Entry> _entries = [];
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  
  @override
  void initState() {
    super.initState();
    _loadMoreData();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMoreData();
    }
  }
  
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    final newEntries = await repository.getEntries(
      page: _page,
      limit: 20,
    );
    
    setState(() {
      _entries.addAll(newEntries);
      _page++;
      _isLoading = false;
      _hasMore = newEntries.length == 20;
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 7. Optimize Database Queries

Implement efficient database patterns:

```dart
// ❌ Bad: Multiple queries
for (var date in dates) {
  final entry = await db.getEntryByDate(date);
  entries.add(entry);
}

// ✅ Good: Single query with IN clause
final entries = await db.getEntriesByDates(dates);

// Use indexes for frequently queried columns
await db.execute('''
  CREATE INDEX IF NOT EXISTS idx_entries_date 
  ON entries(date)
''');

// Use prepared statements
final stmt = await db.prepare(
  'SELECT * FROM entries WHERE date BETWEEN ? AND ?'
);
final results = await stmt.query([startDate, endDate]);
```

### 8. Lazy Load Heavy Computations

Defer heavy computations until needed:

```dart
// Use FutureBuilder for async data
FutureBuilder<MonthlySummary>(
  future: _calculateMonthlySummary(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SkeletonLoader();
    }
    return SummaryWidget(summary: snapshot.data!);
  },
)

// Or use compute for heavy calculations
Future<List<ReportData>> _generateReport() async {
  return await compute(
    _calculateReportData,
    entries,
  );
}

// Top-level function for compute
List<ReportData> _calculateReportData(List<Entry> entries) {
  // Heavy computation here
  return processedData;
}
```

### 9. Minimize Widget Rebuilds

Use const, keys, and selective rebuilds:

```dart
// Use BlocBuilder with buildWhen for selective rebuilds
BlocBuilder<DashboardBloc, DashboardState>(
  buildWhen: (previous, current) {
    // Only rebuild when specific data changes
    return previous.totalCalls != current.totalCalls;
  },
  builder: (context, state) {
    return CallsWidget(calls: state.totalCalls);
  },
)

// Use ValueListenableBuilder for single values
ValueListenableBuilder<int>(
  valueListenable: callsNotifier,
  builder: (context, calls, child) {
    return Text('Calls: $calls');
  },
)

// Pass child that doesn't rebuild
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return SomeWidget(
      child: const ExpensiveWidget(), // Won't rebuild
    );
  },
)
```

### 10. Use Keys Wisely

Preserve widget state with appropriate keys:

```dart
// Use ValueKey for items in a list
ListView.builder(
  itemCount: entries.length,
  itemBuilder: (context, index) {
    final entry = entries[index];
    return EntryCard(
      key: ValueKey(entry.id), // Preserves state when list changes
      entry: entry,
    );
  },
)

// Use GlobalKey sparingly (expensive)
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
```

### 11. Optimize Animations

Use efficient animation patterns:

```dart
// Use AnimatedWidget instead of listening to animation
class RotatingLogo extends AnimatedWidget {
  const RotatingLogo({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform.rotate(
      angle: animation.value,
      child: const FlutterLogo(),
    );
  }
}

// Use AnimatedBuilder for multiple widgets
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: _controller.value,
      child: child,
    );
  },
  child: const ExpensiveWidget(), // Built once
)

// Dispose animation controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### 12. Memory Management

Prevent memory leaks:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _subscription = stream.listen((data) {
      // Handle data
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Do something
    });
  }
  
  @override
  void dispose() {
    // Always cancel subscriptions and timers
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
```

## 🔍 Performance Profiling

### Using Flutter DevTools

1. **Performance Overlay:**
   ```dart
   MaterialApp(
     showPerformanceOverlay: true, // Shows frame rendering stats
     // ...
   )
   ```

2. **Profile Mode:**
   ```bash
   flutter run --profile
   ```

3. **Analyze Build Times:**
   ```bash
   flutter build apk --analyze-size
   ```

### Key Metrics to Monitor

- **Frame Rendering Time:** Should be < 16ms (60 FPS)
- **Memory Usage:** Monitor heap usage and garbage collection
- **CPU Usage:** Identify expensive operations
- **Network Calls:** Optimize API calls and caching

## 📊 Optimization Checklist

### Widgets
- [ ] Use const constructors where possible
- [ ] Implement ListView.builder for long lists
- [ ] Use RepaintBoundary for complex widgets
- [ ] Minimize widget tree depth
- [ ] Extract widgets to separate classes

### State Management
- [ ] Use buildWhen to prevent unnecessary rebuilds
- [ ] Implement proper BLoC/Cubit patterns
- [ ] Dispose controllers and subscriptions
- [ ] Use ValueListenableBuilder for simple state

### Database
- [ ] Add indexes on frequently queried columns
- [ ] Use batch operations for multiple inserts
- [ ] Implement query result caching
- [ ] Use pagination for large datasets
- [ ] Optimize JOIN queries

### Images & Assets
- [ ] Compress images before including
- [ ] Use appropriate image formats (WebP for photos, SVG for icons)
- [ ] Specify image dimensions
- [ ] Implement image caching
- [ ] Lazy load images

### Network
- [ ] Cache API responses
- [ ] Implement request debouncing
- [ ] Use connection pooling
- [ ] Compress request/response data
- [ ] Handle offline scenarios

### Code
- [ ] Remove unused imports and dependencies
- [ ] Use tree shaking
- [ ] Minimize app size
- [ ] Enable code obfuscation
- [ ] Profile and optimize hot paths

## 🎯 Performance Testing

### Manual Testing
1. Test on low-end devices
2. Test with large datasets (1000+ entries)
3. Monitor battery drain
4. Check app size
5. Test offline performance

### Automated Testing
```dart
// Performance test example
testWidgets('Dashboard loads quickly', (tester) async {
  final stopwatch = Stopwatch()..start();
  
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(2000));
});
```

## 📈 Monitoring in Production

1. **Crash Analytics:** Firebase Crashlytics
2. **Performance Monitoring:** Firebase Performance
3. **User Metrics:** Track user engagement and retention
4. **App Size:** Monitor APK/IPA size trends

## 🔧 Quick Wins

Priority optimizations for immediate impact:

1. ✅ Add const to all static widgets
2. ✅ Replace ListView with ListView.builder in dashboard
3. ✅ Add database indexes on date columns
4. ✅ Implement pagination for daily entries list
5. ✅ Add RepaintBoundary to charts
6. ✅ Optimize image sizes in assets

## 📚 Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Dart Performance Tips](https://dart.dev/guides/language/performance)

---

**Last Updated:** December 6, 2024
**Maintained by:** Advisor Desk Development Team
