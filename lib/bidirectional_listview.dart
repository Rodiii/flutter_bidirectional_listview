library bidirectional_listview;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

/// BidirectionalListView
///
/// ListView with items that can be scrolled in both directions with fixed item counts (positve and negative) and scroll boundaries
///
/// BidirectionalListView forked from InfiniteListView https://github.com/fluttercommunity/flutter_infinite_listview
///
/// See example for usage
///
class BidirectionalListView extends StatelessWidget {
  /// See [ListView.builder]
  BidirectionalListView.builder({
    Key key,
    this.scrollDirection = Axis.vertical,
    BidirectionalScrollController controller,
    this.physics,
    this.padding,
    this.itemExtent,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    int negativeItemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    this.anchor = 0.0,
    this.cacheExtent,
  })  : positiveChildrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        negativeChildrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) => itemBuilder(context, -1 - index),
          childCount: negativeItemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        controller = controller ?? BidirectionalScrollController(),
        super(key: key);

  /// See [ListView.separated]
  BidirectionalListView.separated({
    Key key,
    this.scrollDirection = Axis.vertical,
    BidirectionalScrollController controller,
    this.physics,
    this.padding,
    @required IndexedWidgetBuilder itemBuilder,
    @required IndexedWidgetBuilder separatorBuilder,
    int itemCount,
    int negativeItemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    this.cacheExtent,
    this.anchor = 0.0,
  })  : assert(itemBuilder != null),
        assert(separatorBuilder != null),
        itemExtent = null,
        positiveChildrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final itemIndex = index ~/ 2;
            return index.isEven
                ? itemBuilder(context, itemIndex)
                : separatorBuilder(context, itemIndex);
          },
          childCount: itemCount != null ? math.max(0, itemCount * 2 - 1) : null,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        negativeChildrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final itemIndex = (-1 - index) ~/ 2;
            return index.isOdd
                ? itemBuilder(context, itemIndex)
                : separatorBuilder(context, itemIndex);
          },
          childCount: negativeItemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        controller = controller ?? BidirectionalScrollController(),
        super(key: key);

  /// See: [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// See: [ScrollView.controller]
  final BidirectionalScrollController controller;

  /// See: [ScrollView.physics]
  final ScrollPhysics physics;

  /// See: [BoxScrollView.padding]
  final EdgeInsets padding;

  /// See: [ListView.itemExtent]
  final double itemExtent;

  /// See: [ScrollView.cacheExtent]
  final double cacheExtent;

  /// See: [ScrollView.anchor]
  final double anchor;

  /// See: [ListView.childrenDelegate]
  final SliverChildDelegate negativeChildrenDelegate;

  /// See: [ListView.childrenDelegate]
  final SliverChildDelegate positiveChildrenDelegate;

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = _buildSlivers(context, negative: false);
    final List<Widget> negativeSlivers = _buildSlivers(context, negative: true);
    final AxisDirection axisDirection = _getDirection(context);
    final scrollPhysics = AlwaysScrollableScrollPhysics(parent: physics);
    return Scrollable(
      axisDirection: axisDirection,
      controller: controller,
      physics: scrollPhysics,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return Builder(builder: (BuildContext context) {
          /// Build negative [ScrollPosition] for the negative scrolling [Viewport].
          final state = Scrollable.of(context);
          final negativeOffset = BidirectionalScrollPosition(
            physics: scrollPhysics,
            context: state,
            initialPixels: -offset.pixels,
            keepScrollOffset: controller.keepScrollOffset,
            negativeScroll: true,
          );

          /// Keep the negative scrolling [Viewport] positioned to the [ScrollPosition].
          offset.addListener(() {
            negativeOffset._forceNegativePixels(offset.pixels);
          });

          /// Stack the two [Viewport]s on top of each other so they move in sync.
          return Stack(
            children: <Widget>[
              Viewport(
                axisDirection: flipAxisDirection(axisDirection),
                anchor: 1.0 - anchor,
                offset: negativeOffset,
                slivers: negativeSlivers,
                cacheExtent: cacheExtent,
              ),
              Viewport(
                axisDirection: axisDirection,
                anchor: anchor,
                offset: offset,
                slivers: slivers,
                cacheExtent: cacheExtent,
              ),
            ],
          );
        });
      },
    );
  }

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, scrollDirection, false);
  }

  List<Widget> _buildSlivers(BuildContext context, {bool negative = false}) {
    Widget sliver;
    if (itemExtent != null) {
      sliver = SliverFixedExtentList(
        delegate:
            negative ? negativeChildrenDelegate : positiveChildrenDelegate,
        itemExtent: itemExtent,
      );
    } else {
      sliver = SliverList(
          delegate:
              negative ? negativeChildrenDelegate : positiveChildrenDelegate);
    }
    if (padding != null) {
      sliver = new SliverPadding(
        padding: negative
            ? padding - EdgeInsets.only(bottom: padding.bottom)
            : padding - EdgeInsets.only(top: padding.top),
        sliver: sliver,
      );
    }
    return <Widget>[sliver];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new EnumProperty<Axis>('scrollDirection', scrollDirection));
    properties.add(new DiagnosticsProperty<ScrollController>(
        'controller', controller,
        showName: false, defaultValue: null));
    properties.add(new DiagnosticsProperty<ScrollPhysics>('physics', physics,
        showName: false, defaultValue: null));
    properties.add(new DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding', padding,
        defaultValue: null));
    properties
        .add(new DoubleProperty('itemExtent', itemExtent, defaultValue: null));
    properties.add(
        new DoubleProperty('cacheExtent', cacheExtent, defaultValue: null));
  }
}

/// Same as a [ScrollController] except it provides [ScrollPosition] objects with infinite bounds.
class BidirectionalScrollController extends ScrollController {
  /// Creates a new [BidirectionalScrollController]
  BidirectionalScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    return new BidirectionalScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class BidirectionalScrollPosition extends ScrollPositionWithSingleContext {
  BidirectionalScrollPosition({
    @required ScrollPhysics physics,
    @required ScrollContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition oldPosition,
    String debugLabel,
    this.negativeScroll = false,
  })  : assert(negativeScroll != null),
        super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        ) {
    if (oldPosition != null &&
        oldPosition.minScrollExtent != null &&
        oldPosition.maxScrollExtent != null) {
      _minScrollExtent = oldPosition.minScrollExtent;
      _maxScrollExtent = oldPosition.maxScrollExtent;
    }
  }

  final bool negativeScroll;

  void _forceNegativePixels(double value) {
    super.forcePixels(-value);
  }

  @override
  double get minScrollExtent => _minScrollExtent;
  double _minScrollExtent = 0.0;

  @override
  double get maxScrollExtent => _maxScrollExtent;
  double _maxScrollExtent = 0.0;

  void setMinMaxExtent(double minExtent, double maxExtent) {
    _minScrollExtent = minExtent;
    _maxScrollExtent = maxExtent;
  }

  @override
  void saveScrollOffset() {
    if (!negativeScroll) {
      super.saveScrollOffset();
    }
  }

  @override
  void restoreScrollOffset() {
    if (!negativeScroll) {
      super.restoreScrollOffset();
    }
  }
}
