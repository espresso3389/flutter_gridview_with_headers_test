import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController controller;
  SliverGridLayout layout;
  double headerSize = 60;
  final itemCounts = [40, 20, 40, 12, 30, 120];
  List<int> itemOffsets;
  int dest = 1;

  @override
  void initState() {
    controller = ScrollController();
    int sum = 0;
    itemOffsets = [];
    for (int i = 0; i < itemCounts.length; i++) {
      itemOffsets.add(sum);
      sum += itemCounts[i];
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GridView Test'),
      ),
      body: CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          for (var i = 0; i < itemCounts.length; i++)
            ...[
              SliverStickyHeader(
                header: Container(
                  height: headerSize,
                  color: Colors.lightBlue,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Header #${i + 1} (${itemOffsets[i] + 1} - ${itemOffsets[i] + itemCounts[i]})',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateInterceptor(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150.0,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    onNewLayout: (layout) {
                      this.layout = layout;
                    }
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        color: Colors.primaries[index % Colors.primaries.length], height: 30,
                        child: Text('${itemOffsets[i] + index + 1}'));
                    },
                    childCount: itemCounts[i]
                  )
                ),
              ),
            ]
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final offset = itemCounts.take(dest).fold(0, (s, a) => s + layout.computeMaxScrollOffset(a)) + dest * headerSize;
          dest = (dest + 1) % itemCounts.length;
          controller.animateTo(offset, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        },
        tooltip: 'Test',
        child: Icon(Icons.add),
      ),
    );
  }
}


class SliverGridDelegateInterceptor extends SliverGridDelegateWithMaxCrossAxisExtent {
  final SliverGridDelegateWithMaxCrossAxisExtent gridDelegate;
  final void Function(SliverGridLayout newLayout) onNewLayout;
  SliverGridDelegateInterceptor({this.gridDelegate, this.onNewLayout}):
    super(
      maxCrossAxisExtent: gridDelegate.maxCrossAxisExtent,
      mainAxisSpacing: gridDelegate.mainAxisSpacing,
      crossAxisSpacing: gridDelegate.crossAxisSpacing,
      childAspectRatio: gridDelegate.childAspectRatio);

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final layout = gridDelegate.getLayout(constraints);
    onNewLayout?.call(layout);
    return layout;
  }

  @override
  bool shouldRelayout(SliverGridDelegate oldDelegate) => gridDelegate.shouldRelayout(oldDelegate as SliverGridDelegateWithMaxCrossAxisExtent);
}
