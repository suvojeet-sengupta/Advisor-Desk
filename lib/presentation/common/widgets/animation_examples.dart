// Animation Implementation Examples
// This file shows how to use the new animation widgets in your app

import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/skeleton_loader.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/presentation/common/widgets/staggered_list.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_refresh_indicator.dart';
import 'package:advisor_desk/presentation/common/widgets/hero_wrapper.dart';

/// This file provides a collection of examples demonstrating how to use the
/// custom animation widgets available in the application. It is intended as a
/// guide for developers and is not used directly in the application's UI.

/// An example of how to use the [DashboardSkeletonLoader] widget.
class ExampleSkeletonUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardSkeletonLoader(), // Use instead of DashboardShimmer
    );
  }
}

/// An example of how to use the various animated button widgets.
class ExampleAnimatedButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated button with haptic feedback
        AnimatedButton(
          onPressed: () {
            // Your action here
          },
          child: Text('Save Changes'),
        ),
        
        // Animated icon button
        AnimatedIconButton(
          icon: Icons.favorite,
          onPressed: () {
            // Your action here
          },
          color: Colors.red,
        ),
        
        // Animated switch
        AnimatedSwitch(
          value: true,
          onChanged: (value) {
            // Handle switch change
          },
        ),
        
        // Animated checkbox
        AnimatedCheckbox(
          value: false,
          onChanged: (value) {
            // Handle checkbox change
          },
        ),
      ],
    );
  }
}

/// An example of how to use the [StaggeredListView] widget.
class ExampleStaggeredList extends StatelessWidget {
  final List<String> items = List.generate(20, (index) => 'Item $index');
  
  @override
  Widget build(BuildContext context) {
    return StaggeredListView(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(items[index]),
            subtitle: Text('Description for ${items[index]}'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}

/// An example of how to use the [CustomRefreshIndicator] widget.
class ExampleCustomRefresh extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(Duration(seconds: 2));
      },
      // Optional: Add your own Lottie animation
      // lottieAsset: 'assets/animations/refresh.json',
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
    );
  }
}

/// An example of how to use [Hero] animations with the [HeroWrapper] widget.
class ExampleHeroAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        final heroTag = 'hero_$index';
        
        return AnimatedDetailCard(
          heroTag: heroTag,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  heroTag: heroTag,
                  index: index,
                ),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              child: Text('$index'),
            ),
            title: Text('Item $index'),
            subtitle: Text('Tap for hero animation'),
          ),
        );
      },
    );
  }
}

/// A detail screen for demonstrating [Hero] animations.
class DetailScreen extends StatelessWidget {
  /// The tag for the [Hero] widget.
  final String heroTag;
  /// The index of the item.
  final int index;
  
  /// Creates a detail screen.
  const DetailScreen({
    required this.heroTag,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail $index'),
      ),
      body: Center(
        child: HeroWrapper(
          tag: heroTag,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An example of how to use the [OpenContainerWrapper] for smooth transitions.
class ExampleOpenContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return OpenContainerWrapper(
          closedWidget: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                'Card $index',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          openWidget: Scaffold(
            appBar: AppBar(
              title: Text('Detail View $index'),
            ),
            body: Center(
              child: Text('Full screen detail for item $index'),
            ),
          ),
        );
      },
    );
  }
}

/// An example of how to use [StaggeredColumn] for form animations.
class ExampleStaggeredForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StaggeredColumn(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 24),
        AnimatedButton(
          onPressed: () {},
          child: Text('Submit'),
        ),
      ],
    );
  }
}

// HOW TO INTEGRATE IN YOUR EXISTING SCREENS:

// 1. In dashboard_screen.dart:
// Replace: const DashboardShimmer()
// With: const DashboardSkeletonLoader()

// 2. In daily_entries_section.dart:
// Wrap your ListView with StaggeredListView:
/*
StaggeredListView(
  itemCount: entries.length,
  itemBuilder: (context, index) {
    return YourEntryWidget(entry: entries[index]);
  },
)
*/

// 3. For buttons throughout the app:
// Replace: ElevatedButton(onPressed: ..., child: ...)
// With: AnimatedButton(onPressed: ..., child: ...)

// 4. For refresh indicators:
// Replace: RefreshIndicator(onRefresh: ..., child: ...)
// With: CustomRefreshIndicator(onRefresh: ..., child: ...)

// 5. For navigation transitions:
// Wrap cards that navigate with OpenContainerWrapper or use Hero animations

// 6. For forms:
// Use StaggeredColumn to wrap form fields for cascade animations
