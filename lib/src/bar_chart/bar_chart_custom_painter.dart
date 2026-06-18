import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:simple_chart/src/chart_helper_functions.dart';
import 'package:simple_chart/src/extensions/double_extension.dart';

enum XLabelAlignment {
  showAllCentered,
  showFirstAndLast,
  showAllWithFirstAndLastInLine,
}

enum UnitAlignment { left, right }

class BarChartCustomPainter extends CustomPainter {
  Offset? touchPosition;
  double yLabelSpacing;
  double xLabelSpacing;
  double xLabelHeight;
  EdgeInsets graphPadding;
  XLabelAlignment xLabelAlignment;
  List<double> values;
  List<String> labels;
  String unit;
  UnitAlignment unitAlignment;
  Function(int)? onTap;
  int yAxisLineCount;
  bool drawVerticalLines;
  bool drawHorizontalLines;
  Color hLinesColor;
  Color vLinesColor;
  Color zeroLineColor;
  TextStyle yLabelStyle;
  TextStyle xLabelStyle;
  Color barColor;
  Color negativeBarColor;
  Color selectedBarColor;
  BarChartCustomPainter({
    required this.touchPosition,
    required this.yLabelSpacing,
    required this.xLabelSpacing,
    required this.xLabelHeight,
    required this.graphPadding,
    required this.xLabelAlignment,
    required this.values,
    required this.labels,
    this.onTap,
    required this.unit,
    required this.unitAlignment,
    this.yAxisLineCount = 6,
    this.drawVerticalLines = false,
    this.drawHorizontalLines = true,
    required this.hLinesColor,
    required this.vLinesColor,
    required this.zeroLineColor,
    required this.yLabelStyle,
    required this.xLabelStyle,
    required this.barColor,
    required this.negativeBarColor,
    required this.selectedBarColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (yAxisLineCount < 3) {
      yAxisLineCount = 3;
    }

    // List<double> yValues = [1, 1, 1, 2, 1, 1, 1];
    List<double> yValues = values;
    if (yValues.first == 0) {
      yValues.first = 0.005;
    }
    double usableHeight = size.height - xLabelHeight - xLabelSpacing;
    double maxYValue = yValues.reduce((v, e) => v > e ? v : e);
    double minYValue = yValues.reduce((v, e) => v < e ? v : e);
    Map<String, int> calVals = calAxisBounds(
      max: maxYValue,
      min: minYValue,
      lineCount: yAxisLineCount,
      source: "BAR CHART",
      valueMargin: 0.0,
    );
    int yAxisMax = calVals['max']!;
    int yAxisMin = calVals['min']!;
    int yLabelStep = calVals['step']!;
    yAxisLineCount = calVals['lineCount'] ?? yAxisLineCount;
    // if step is 0, then data only contains values between
    // 0 - 1, to avoid all y labels being 1 do the following
    if (yLabelStep == 0) {
      yLabelStep = 1;
      yAxisLineCount = 1;
    }

    //--------------------------------------------------------------------------------------------
    double getYPos(double value) {
      // if (yAxisMax == 0) {
      //   return 0;
      // }
      double percent = (value - yAxisMin) / (yAxisMax - yAxisMin);
      double heightFromTop = percent * usableHeight;
      double heightFromBottom = usableHeight - heightFromTop;
      return heightFromTop;
    }

    yValues = yValues.map((e) => getYPos(e)).toList();
    dev.log(yValues.toString(), name: "BAR CHART Y VALUES");

    //--------------------------------------------------------------------------------------------
    // * DRAW BACKGROUND HORIZONTAL LINES AND Y LABELS
    //--------------------------------------------------------------------------------------------
    Paint yLinePaint = Paint()..color = hLinesColor;
    Paint zeroYLinePaint = Paint()..color = zeroLineColor;
    double? yTextWidth;
    // int yDiv = calYAxisDiv(yAxisMax);
    int yDiv = yAxisLineCount - 1;

    double yStep = usableHeight / ((yDiv == 0) ? 1 : yDiv);
    List<TextPainter> textPainters = [];
    for (int i = 0; i <= yDiv; i++) {
      double labelValue = yAxisMax - (i * yLabelStep.toDouble());

      String text = labelValue.floor().shorten;
      // String text = labelValue.floor().toString();
      text = unitAlignment == UnitAlignment.left ? "$unit$text" : "$text$unit";
      String zeroLabel = unitAlignment == UnitAlignment.left
          ? "${unit}0"
          : "0$unit";
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: ((yAxisMin < 0 && yAxisMax > 0) && text == zeroLabel)
                ? zeroLineColor
                : hLinesColor,
            fontSize: 10,
          ).merge(yLabelStyle),
        ),
        textDirection: TextDirection.ltr,
        textAlign: .right,
        textWidthBasis: TextWidthBasis.longestLine,
      )..layout();
      textPainters.add(textPainter);
    }

    yTextWidth = textPainters.fold(0.0, (v, p) => v! < p.width ? p.width : v);

    for (int i = 0; i <= yDiv; i++) {
      double y = (i * yStep);
      textPainters[i].layout(minWidth: yTextWidth!);
      textPainters[i].paint(canvas, Offset(0, y - textPainters[i].height / 2));
      if (drawHorizontalLines) {
        String zeroLabel = unitAlignment == UnitAlignment.left
            ? "${unit}0"
            : "0$unit";
        canvas.drawLine(
          Offset(yTextWidth + yLabelSpacing, y),
          Offset(size.width, y),
          ((yAxisMin < 0 && yAxisMax > 0) &&
                  textPainters[i].plainText == zeroLabel)
              ? zeroYLinePaint
              : yLinePaint,
        );
      }
    }

    //--------------------------------------------------------------------------------------------
    // * SETTINGS NEEDED FOR VALUE POINTS FILL AND X LABELS
    //--------------------------------------------------------------------------------------------
    double barWidth = 15;
    double usableWidth = size.width;
    double xStep =
        usableWidth / (yValues.length - (yValues.length > 1 ? 1 : 0));
    barWidth = (xStep - (xStep * .5)).clamp(2, 15);

    // create xOffset with unsymmetric values first
    // so it doesn't affect the usableWidth calculations;
    double xOffset = yTextWidth! + yLabelSpacing;
    usableWidth = size.width - xOffset - graphPadding.horizontal - barWidth;
    xStep = usableWidth / (yValues.length - (yValues.length > 1 ? 1 : 0));
    // add offset in calculating the valuePoints with xStep
    // to move the whole thing by offset
    // but update it with padding and barwidth (only considering the left size so half the values)
    xOffset = xOffset + graphPadding.left + (barWidth / 2);

    List<Offset> valuePoints = yValues
        .asMap()
        .entries
        .map((e) => Offset((e.key * xStep) + xOffset, e.value))
        .toList();

    List<Offset> drawPoints = valuePoints;

    //--------------------------------------------------------------------------------------------
    // * DRAW BACKGROUND VERTICAL LINES AND X LABELS
    //--------------------------------------------------------------------------------------------
    Paint xLinePaint = Paint()..color = vLinesColor;

    int xDivs = labels.length - 1;
    // double xLabelStep = usableWidth / (xDivs == 0 ? 1 : xDivs);

    for (int i = 0; i <= xDivs; i++) {
      double x = (i * xStep) + xOffset;
      String labelText = labels.toList()[i];
      // String labelText = ["6", "10", "2", "12"][i];
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ).merge(xLabelStyle),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      double xLabelDy = usableHeight + xLabelSpacing;
      if (xLabelAlignment == XLabelAlignment.showAllCentered) {
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, xLabelDy));
      } else {
        if ((i == 0 || i == xDivs)) {
          textPainter.paint(
            canvas,
            Offset(
              x -
                  textPainter.width / 2 +
                  (i == 0 ? barWidth / 2 : -barWidth / 2),
              xLabelDy,
            ),
          );
        }
      }
      if (drawVerticalLines) {
        canvas.drawLine(Offset(x, usableHeight), Offset(x, 0), xLinePaint);
      }
    }

    //--------------------------------------------------------------------------------------------
    // * FIND SELECTED BAR
    //--------------------------------------------------------------------------------------------
    late Offset selectedBar;
    if (touchPosition == null) {
      selectedBar = valuePoints.last;
    } else {
      selectedBar = valuePoints.reduce(
        (v, e) =>
            (v.dx - touchPosition!.dx).abs() < (e.dx - touchPosition!.dx).abs()
            ? v
            : e,
      );
    }

    //--------------------------------------------------------------------------------------------
    // * DRAW BARS
    //--------------------------------------------------------------------------------------------
    final barPaint = Paint()..color = barColor;
    final negativeBarPaint = Paint()..color = negativeBarColor;
    final selectedBarPaint = Paint()..color = selectedBarColor;

    for (int i = 0; i < drawPoints.length; i++) {
      usableWidth -=
          barWidth; // half barwith left half barwidth right so there's equal distance between bars
      double dx = drawPoints[i].dx;

      double startYLine = (yAxisMin < 0 && yAxisMax > 0)
          ? getYPos(0)
          : (!yAxisMin.isNegative)
          ? getYPos(
              yAxisMin.toDouble(),
            ) // if it's only pos numbers, use bottom line as base
          : getYPos(
              yAxisMax.toDouble(),
            ); // if it's only neg numbers, use top line as base
      bool isPos = (startYLine - drawPoints[i].dy) > 0;
      bool isSelected = drawPoints[i] == selectedBar;
      Rect rect = Rect.fromCenter(
        // start at the position of zero from the bottom and move up
        // half the height so the bar starts at zero (center moves up by half the height)

        //? when value is zero, subtracting (or offsetting) by startYLine
        //? will make it zero
        //? if value is above zero, then it will become it's appropriate height with center being half
        //? the height above zero
        //? if it's below zero, then center will be halp the height below zero
        center: Offset(
          dx,
          (usableHeight - startYLine) - ((drawPoints[i].dy - startYLine) / 2),
        ),
        width: barWidth,
        height: drawPoints[i].dy - startYLine,
      );
      RRect roundedRect = RRect.fromRectAndCorners(
        rect,
        // topLeft: .circular(100),
        // topRight: .circular(100),
        // bottomLeft: .circular(100),
        // bottomRight: .circular(100),
      );
      canvas.drawRRect(
        roundedRect,
        isSelected
            ? selectedBarPaint
            : isPos
            ? negativeBarPaint
            : barPaint,
      );
    }

    //--------------------------------------------------------------------------------------------
    // * ON TAP CALLBACK
    //--------------------------------------------------------------------------------------------
    if (touchPosition != null) {
      int dotPositionIndex = valuePoints.indexOf(selectedBar);
      onTap?.call(dotPositionIndex);
    }
  }

  //--------------------------------------------------------------------------------------------
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
