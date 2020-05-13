import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  Map<int, String> items = new Map();
  static const double ITEM_HEIGHT = 30;

  @override
  void initState() {
    super.initState();

    for (int i = -10; i <= 10; i++) {
      items[i] = "Item " + i.toString();
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
    List<int> keys = items.keys.toList();
    keys.sort();

    int negativeItemCount = keys.first;
    int itemCount = keys.last;
    print("itemCount = " + itemCount.toString());
    print("negativeItemCount = " + negativeItemCount.abs().toString());
    return new Scaffold(
      body: new Scrollbar(
        child: new BidirectionalListView.builder(
          controller: controller,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
                child: Text(items[index]),
                height: ITEM_HEIGHT,
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0));
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
    bool scrollingDown = oldScrollPosition < controller.position.pixels;
    List<int> keys = items.keys.toList();
    keys.sort();
    int negativeItemCount = keys.first.abs();
    int itemCount = keys.last;

    double positiveReloadBorder = (itemCount * ITEM_HEIGHT - 3 * ITEM_HEIGHT);
    double negativeReloadBorder =
        (-(negativeItemCount * ITEM_HEIGHT - 3 * ITEM_HEIGHT));

    print("pixels = " + controller.position.pixels.toString());
    print("itemCount = " + itemCount.toString());
    print("negativeItemCount = " + negativeItemCount.toString());
    print("minExtent = " + controller.position.minScrollExtent.toString());
    print("maxExtent = " + controller.position.maxScrollExtent.toString());
    print("positiveReloadBorder = " + positiveReloadBorder.toString());
    print("negativeReloadBorder = " + negativeReloadBorder.toString());

    bool rebuildNecessary = false;
    if (scrollingDown && controller.position.pixels > positiveReloadBorder) {
      for (int i = itemCount + 1; i <= itemCount + 20; i++) {
        items[i] = "Item " + i.toString();
      }
      rebuildNecessary = true;
    } else if (!scrollingDown &&
        controller.position.pixels < negativeReloadBorder) {
      for (int i = -negativeItemCount - 20; i < -negativeItemCount; i++) {
        items[i] = "Item " + i.toString();
      }
      rebuildNecessary = true;
    }

    try {
      BidirectionalScrollPosition pos = controller.position;
      pos.setMinMaxExtent(
          -negativeItemCount * ITEM_HEIGHT, itemCount * ITEM_HEIGHT);
    } catch (error) {
      print(error.toString());
    }
    if (rebuildNecessary) {
      _rebuild();
    }

    oldScrollPosition = controller.position.pixels;
  }
}
