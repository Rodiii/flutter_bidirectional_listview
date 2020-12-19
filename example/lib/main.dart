import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:bidirectional_listview/bidirectional_listview.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => new _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  BidirectionalScrollController controller;
  Map<int, String> items = HashMap<int, String>();
  static const double kItemHeight = 30;

  @override
  void initState() {
    super.initState();

    for (int i = -10; i <= 10; i++) {
      items[i] = 'Item $i';
    }
    controller = new BidirectionalScrollController()
      ..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<int> keys = items.keys.toList();
    keys.sort();

    final int negativeItemCount = keys.first;
    final int itemCount = keys.last;
    print('itemCount = $itemCount');
    print('negativeItemCount = ${negativeItemCount.abs()}');
    return new Scaffold(
      body: new Scrollbar(
        child: new BidirectionalListView.builder(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
                child: Text(items[index]),
                height: kItemHeight,
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.all(0));
          },
          itemCount: itemCount,
          negativeItemCount: negativeItemCount.abs(),
        ),
      ),
    );
  }

  void _rebuild() => setState(() {});

  double oldScrollPosition = 0.0;
  void _scrollListener() {
    final bool scrollingDown = oldScrollPosition < controller.position.pixels;
    final List<int> keys = items.keys.toList();
    keys.sort();
    final int negativeItemCount = keys.first.abs();
    final int itemCount = keys.last;

    final double positiveReloadBorder =
        itemCount * kItemHeight - 3 * kItemHeight;
    final double negativeReloadBorder =
        -(negativeItemCount * kItemHeight - 3 * kItemHeight);

    print('pixels = ${controller.position.pixels}');
    print('itemCount = $itemCount');
    print('negativeItemCount = $negativeItemCount');
    print('minExtent = ${controller.position.minScrollExtent}');
    print('maxExtent = ${controller.position.maxScrollExtent}');
    print('positiveReloadBorder = $positiveReloadBorder');
    print('negativeReloadBorder = $negativeReloadBorder');

    bool rebuildNecessary = false;
    if (scrollingDown && controller.position.pixels > positiveReloadBorder) {
      for (int i = itemCount + 1; i <= itemCount + 20; i++) {
        items[i] = 'Item $i';
      }
      rebuildNecessary = true;
    } else if (!scrollingDown &&
        controller.position.pixels < negativeReloadBorder) {
      for (int i = -negativeItemCount - 20; i < -negativeItemCount; i++) {
        items[i] = 'Item $i';
      }
      rebuildNecessary = true;
    }

    try {
      final BidirectionalScrollPosition pos = controller.position;
      pos.setMinMaxExtent(
          -negativeItemCount * kItemHeight, itemCount * kItemHeight);
    } on Exception catch (error) {
      print(error.toString());
    }
    if (rebuildNecessary) {
      _rebuild();
    }

    oldScrollPosition = controller.position.pixels;
  }
}
