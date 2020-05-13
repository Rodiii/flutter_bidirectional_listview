
# Flutter Bidirectional ListView

ListView with items that can be scrolled in both directions with a fixed item count and scroll boundaries.

With this library the following is possible:
- ListView can be scrolled in up (negative indices) and down (positive indices) direction
- Lazy loading is possible for up and down direction
- Scroll boundaries for top and bottom
- ItemCount for negative and positive indices can/must be set

Limitations:
- Min- and MaxExtents for scrolling must be set manually


## Quick Usage

Replace your existing `ListView` with `BidirectionalListView`. Builder pattern must be used because of its infinite nature.

Please refer to the example for usage: [Quick-Link](https://github.com/Rodiii/flutter_bidirectional_listview/blob/master/example/lib/main.dart)

### Example
![Example](https://github.com/Rodiii/flutter_bidirectional_listview/raw/master/example.gif)

## Bugs/Requests
If you encounter any problems feel free to open an issue. If you feel the library is
missing a feature, please raise a ticket on Github and I'll look into it.
Pull Request are also welcome.
