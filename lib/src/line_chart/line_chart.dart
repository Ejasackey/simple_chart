import 'package:flutter/material.dart';
import 'package:quick_chart/src/line_chart/line_chart_custom_painter.dart';

// ignore: must_be_immutable
class LineChart extends StatefulWidget {
  /// spacing for the Y axis labels
  double yLabelSpacing;

  /// height of the chart
  double height;

  /// width of the chart
  double width;

  /// spacing for X axis labels
  double xLabelSpacing;

  /// imagine this as the height of a container containing the x axis label texts,
  /// you can use it to add more vertical space if needed, but space will appear below since
  /// the label text is aligned to the top of the imaginary container.
  double xLabelHeight;

  /// Padding around the graph area
  EdgeInsets graphPadding;

  /// Configuration on how to render x label
  XLabelAlignment xLabelAlignment;

  /// The values you want to plot on the chart
  List<double> values;

  /// Labels for the values, eg MON, TUE, WED...
  List<String> labels;

  /// onTap function provides the index of the selected (tapped) value
  Function(int)? onTap;

  /// unit of the X axis labels
  String unit;

  /// unit alignment
  UnitAlignment unitAlignment;

  /// basically the amount of horizontal lines, it's automatically calculated, but you can
  /// override by setting this value, it shouldn't be below 3 tho
  int yAxisLineCount;

  /// color of horizontal lines
  Color hLinesColor = Colors.grey.shade600;

  /// color of vertical lines
  Color vLinesColor = Colors.green;

  /// color of zero line
  Color zeroLineColor = Colors.red;

  /// color of y axis labels
  Color yLabelColor = Colors.grey.shade600;

  /// color of x axis labels
  Color xLabelColor = Colors.grey.shade600;

  /// fill color under the line, for a solid color instead of a gradient, add only one color in the list
  List<Color> fillGradient;

  /// color of the main line mapping the values
  Color lineColor = Colors.blue;

  /// color of the selection indicator
  Color dotColor = Colors.red;

  /// color of selection dashes
  Color dashesColor;

  /// whether to use curved lines or not
  bool useCurvedLines;

  /// width of horizontal lines
  double hLineWidth;

  /// width of the main line mapping the values
  double lineWidth;

  /// TextStyle for the y labels
  TextStyle yLabelStyle;

  /// TextStyle for the y labels
  TextStyle xLabelStyle;

  LineChart({
    super.key,
    this.yLabelSpacing = 6,
    this.xLabelSpacing = 6,
    this.xLabelHeight = 10,
    this.graphPadding = .zero,
    this.xLabelAlignment = XLabelAlignment.showAllWithFirstAndLastInLine,
    required this.values,
    required this.labels,
    this.onTap,
    this.unit = "",
    this.unitAlignment = UnitAlignment.right,
    this.yAxisLineCount = 6,
    this.height = 200,
    this.width = .infinity,
    this.hLinesColor = Colors.grey,
    this.vLinesColor = Colors.green,
    this.zeroLineColor = Colors.red,
    this.yLabelColor = Colors.grey,
    this.xLabelColor = Colors.grey,
    this.fillGradient = const [Color(0xAC2195F3), Color(0x002195F3)],
    this.lineColor = Colors.blue,
    this.dotColor = Colors.red,
    this.dashesColor = Colors.grey,
    this.useCurvedLines = true,
    this.lineWidth = 1.5,
    this.hLineWidth = .08,
    this.yLabelStyle = const TextStyle(),
    this.xLabelStyle = const TextStyle(),
  });

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  Offset? touchPosition;
  // Offset initialTouchPosition = Offset.zero;
  late int previousDotPositionIndex;

  @override
  void initState() {
    super.initState();
    previousDotPositionIndex = widget.values.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTapDown: (details) {
          touchPosition = details.localPosition;
          setState(() {});
          // initialTouchPosition = touchPosition ?? Offset.zero;
        },
        child: CustomPaint(
          painter: LineChartCustomPainter(
            touchPosition: touchPosition,
            // initialTouchPosition: initialTouchPosition,
            initialDotPositionIndex: previousDotPositionIndex,
            yLabelSpacing: widget.yLabelSpacing,
            xLabelHeight: widget.xLabelHeight,
            xLabelSpacing: widget.xLabelSpacing,
            xLabelAlignment: widget.xLabelAlignment,
            graphPadding: widget.graphPadding,
            values: widget.values,
            labels: widget.labels,
            onTap: (index) {
              widget.onTap?.call(index);
              previousDotPositionIndex = index;
            },
            unit: widget.unit,
            unitAlignment: widget.unitAlignment,
            yAxisLineCount: widget.yAxisLineCount,
            hLinesColor: widget.hLinesColor,
            vLinesColor: widget.vLinesColor,
            zeroLineColor: widget.zeroLineColor,
            yLabelColor: widget.yLabelColor,
            xLabelColor: widget.xLabelColor,
            fillGradient: widget.fillGradient,
            lineColor: widget.lineColor,
            dotColor: widget.dotColor,
            dashesColor: widget.dashesColor,
            useCurvedLines: widget.useCurvedLines,
            hLineWidth: widget.hLineWidth,
            lineWidth: widget.lineWidth,
            yLabelStyle: widget.yLabelStyle,
            xLabelStyle: widget.xLabelStyle,
          ),
          willChange: true,
        ),
      ),
    );
  }
}
