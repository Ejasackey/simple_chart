import 'package:flutter/material.dart';
import 'package:quick_chart/src/bar_chart/bar_chart_custom_painter.dart';
import 'package:quick_chart/src/enums.dart';

// ignore: must_be_immutable
class BarChart extends StatefulWidget {
  /// spacing for the Y axis labels
  double yLabelSpacing;

  ///spacing for x axis labels
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

  /// height of the chart
  double height;

  /// width of the chart
  double width;

  /// color of horizontal lines
  Color hLinesColor = Colors.grey.shade600;

  /// color of vertical lines
  Color vLinesColor = Colors.green;

  /// color of zero line
  Color zeroLineColor = Colors.red;

  /// TextStyle for the y labels
  TextStyle yLabelStyle;

  /// TextStyle for the y labels
  TextStyle xLabelStyle;

  /// color of bars
  Color barColor;

  /// color of bars with negative numbers
  Color negativeBarColor;

  /// color of selected bar
  Color selectedBarColor;

  /// width of horizontal lines
  double hLineWidth;

  /// Draw horizontal lines
  bool drawHLines;

  ///Draw vertical lines
  bool drawVLines;

  BarChart({
    super.key,
    this.yLabelSpacing = 6,
    this.xLabelSpacing = 6,
    this.xLabelHeight = 15,
    this.graphPadding = .zero,
    this.xLabelAlignment = XLabelAlignment.showAllCentered,
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
    this.yLabelStyle = const TextStyle(),
    this.xLabelStyle = const TextStyle(),
    this.barColor = Colors.blue,
    this.negativeBarColor = Colors.red,
    this.selectedBarColor = Colors.amber,
    this.hLineWidth = .08,
    this.drawHLines = true,
    this.drawVLines = false,
  });

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  Offset? touchPosition;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTapDown: (details) {
          touchPosition = details.localPosition;
          setState(() {});
        },
        child: CustomPaint(
          painter: BarChartCustomPainter(
            touchPosition: touchPosition,
            yLabelSpacing: widget.yLabelSpacing,
            xLabelHeight: widget.xLabelHeight,
            xLabelSpacing: widget.xLabelSpacing,
            xLabelAlignment: widget.xLabelAlignment,
            graphPadding: widget.graphPadding,
            values: widget.values,
            labels: widget.labels,
            onTap: widget.onTap,
            unit: widget.unit,
            unitAlignment: widget.unitAlignment,
            yAxisLineCount: widget.yAxisLineCount,
            xLabelStyle: widget.xLabelStyle,
            hLinesColor: widget.hLinesColor,
            vLinesColor: widget.vLinesColor,
            zeroLineColor: widget.zeroLineColor,
            yLabelStyle: widget.yLabelStyle,
            barColor: widget.barColor,
            negativeBarColor: widget.negativeBarColor,
            selectedBarColor: widget.selectedBarColor,
            hLinesWidth: widget.hLineWidth,
            drawHorizontalLines: widget.drawHLines,
            drawVerticalLines: widget.drawVLines,
          ),
          willChange: true,
        ),
      ),
    );
  }
}
