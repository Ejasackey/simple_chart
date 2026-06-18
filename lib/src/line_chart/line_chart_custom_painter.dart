import 'package:flutter/material.dart';
import 'package:quick_chart/src/chart_helper_functions.dart';
import 'package:quick_chart/src/extensions/double_extension.dart';

enum XLabelAlignment {
  showAllCentered,
  showAllWithFirstAndLastInLine,
  showFirstAndLast,
}

enum UnitAlignment { left, right }

class LineChartCustomPainter extends CustomPainter {
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
  int initialDotPositionIndex;
  Color hLinesColor;
  Color vLinesColor;
  Color zeroLineColor;
  Color yLabelColor;
  Color xLabelColor;
  List<Color> fillGradient;
  Color lineColor;
  Color dotColor;
  Color dashesColor;
  double hLineWidth;
  double lineWidth;
  bool useCurvedLines;
  TextStyle yLabelStyle;
  TextStyle xLabelStyle;
  LineChartCustomPainter({
    required this.touchPosition,
    required this.yLabelSpacing,
    required this.xLabelSpacing,
    required this.xLabelHeight,
    required this.graphPadding,
    this.xLabelAlignment = XLabelAlignment.showAllCentered,
    required this.values,
    required this.labels,
    this.onTap,
    required this.unit,
    required this.unitAlignment,
    this.yAxisLineCount = 6,
    this.drawVerticalLines = false,
    this.drawHorizontalLines = true,
    required this.initialDotPositionIndex,
    required this.hLinesColor,
    required this.zeroLineColor,
    required this.yLabelColor,
    required this.vLinesColor,
    required this.xLabelColor,
    required this.fillGradient,
    required this.lineColor,
    required this.dotColor,
    required this.dashesColor,
    required this.useCurvedLines,
    required this.hLineWidth,
    required this.lineWidth,
    required this.yLabelStyle,
    required this.xLabelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (yAxisLineCount < 3) {
      yAxisLineCount = 3;
    }
    //--------------------------------------------------------------------------------------------
    // * TRANSFORM THE VALUES TO COORDINATES
    //--------------------------------------------------------------------------------------------

    // List<double> yValues = [0, 100, 100, 100, 100, -200];
    List<double> yValues = values;
    if (yValues.last == 0) {
      yValues.last = 0.005;
    }

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
      source: 'LINE CHART',
      valueMargin: .05,
    );
    int yAxisMax = calVals['max']!;
    int yAxisMin = calVals['min']!;
    int yLabelStep = calVals['step']!;
    yAxisLineCount = calVals['lineCount']!;
    // int yAxisMax = calYAxisMax(maxYValue);
    // int yAxisMin = calYAxisMin(minYValue);
    // int yAxisRange = yAxisMax - yAxisMin;
    if (yLabelStep == 0) {
      yLabelStep = 1;
      yAxisLineCount = 1;
    }

    //--------------------------------------------------------------------------------------------
    double getYPos(double value) {
      if (yAxisMax == 0) {
        return 0;
      }
      double percent = (value - yAxisMin) / (yAxisMax - yAxisMin);
      double heightFromTop = percent * usableHeight;
      double heightFromBottom = usableHeight - heightFromTop;
      return heightFromBottom;
    }

    yValues = yValues.map((e) => getYPos(e)).toList();
    // dev.log(yValues.toString(), name: "LINE CHARTY VALUES");

    //--------------------------------------------------------------------------------------------
    // * DRAW BACKGROUND HORIZONTAL LINES AND Y LABELS
    //--------------------------------------------------------------------------------------------
    Paint yLinePaint = Paint()
      ..color = hLinesColor
      ..strokeWidth = hLineWidth;

    Paint zeroYLinePaint = Paint()
      ..color = zeroLineColor
      ..strokeWidth = hLineWidth;
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
            //todo customize style
            color: ((yAxisMin < 0 && yAxisMax > 0) && text == zeroLabel)
                ? zeroLineColor
                : yLabelColor,
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

    // for (int i = 0; i <= yDiv; i++) {
    //   double y = (i * yStep);

    //   // since the full size.height represents the max value
    //   // we can calc the value of each line position
    //   // by calculating valueStep "max / yDiv" and subtracting it  based on index

    //   double labelValue = yAxisMax - (i * yLabelStep.toDouble());
    //   // double labelValue = yAxisMax - (i * yAxisRange / yDiv);

    //   String text = labelValue.floor().shorten;
    //   // String text = labelValue.floor().toString();
    //   text = unitAlignment == UnitAlignment.left ? "$unit$text" : "$text$unit";
    //   final textPainter = TextPainter(
    //     text: TextSpan(
    //       text: text,
    //       style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
    //     ),
    //     textDirection: TextDirection.ltr,
    //     textAlign: .right,
    //     textWidthBasis: TextWidthBasis.longestLine,
    //   )..layout(minWidth: yTextWidth ?? 0.0);
    //   if (i == 0) {
    //     yTextWidth = textPainter.width;
    //   }
    //   textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    //   if (drawHorizontalLines) {
    //     canvas.drawLine(
    //       Offset(yTextWidth! + yLabelSpacing, y),
    //       Offset(size.width, y),
    //       yLinePaint,
    //     );
    //   }
    // }

    //--------------------------------------------------------------------------------------------
    // * SETTINGS NEEDED FOR VALUE POINTS FILL AND X LABELS
    //--------------------------------------------------------------------------------------------
    double xOffset = yTextWidth! + yLabelSpacing;
    double usableWidth = size.width - xOffset - graphPadding.horizontal;
    double xStep =
        usableWidth / (yValues.length - (yValues.length > 1 ? 1 : 0));
    // add offset in calculating the valuePoints with xStep
    // to move the whole thing by offset
    List<Offset> valuePoints = yValues
        .asMap()
        .entries
        .map(
          (e) => Offset((e.key * xStep) + xOffset + graphPadding.left, e.value),
        )
        .toList();

    List<Offset> drawPoints = valuePoints;

    if (valuePoints.length > 3 && useCurvedLines) {
      final spline = CatmullRomSpline(valuePoints);
      drawPoints = spline.generateSamples().map((e) => e.value).toList();
    }

    //--------------------------------------------------------------------------------------------
    // * DRAW BACKGROUND VERTICAL LINES AND X LABELS
    //--------------------------------------------------------------------------------------------
    Paint xLinePaint = Paint()..color = vLinesColor;

    int xDivs = labels.length - 1;
    // double xLabelStep = usableWidth / (xDivs == 0 ? 1 : xDivs);

    for (int i = 0; i <= xDivs; i++) {
      double x = (i * xStep) + xOffset + graphPadding.left;
      String labelText = labels.toList()[i];
      // String labelText = ["6", "10", "2", "12"][i];
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(color: xLabelColor, fontSize: 10).merge(xLabelStyle),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      double xLabelDy = usableHeight + yLabelSpacing;
      if (xLabelAlignment == XLabelAlignment.showAllCentered) {
        textPainter.paint(
          canvas,
          Offset(
            x - textPainter.width / 2,
            // i == 0 ? x : x - textPainter.width,
            xLabelDy,
          ),
        );
      } else if (xLabelAlignment ==
          XLabelAlignment.showAllWithFirstAndLastInLine) {
        textPainter.paint(
          canvas,
          Offset(
            i == 0
                ? x // first label in line, last label inline, the rest centered
                : i == xDivs
                ? x - textPainter.width
                : x - textPainter.width / 2,
            xLabelDy,
          ),
        );
      } else {
        if ((i == 0 || i == xDivs)) {
          textPainter.paint(
            canvas,
            Offset(i == 0 ? x : x - textPainter.width, xLabelDy),
          );
        }
      }
      if (drawVerticalLines) {
        canvas.drawLine(Offset(x, usableHeight), Offset(x, 0), xLinePaint);
      }
    }

    //--------------------------------------------------------------------------------------------
    // * DRAW FILL
    //--------------------------------------------------------------------------------------------
    final fillPaint = Paint();

    if (fillGradient.length == 1) {
      fillPaint.color = fillGradient.first;
    } else {
      fillPaint.shader = LinearGradient(
        begin: .topCenter,
        end: .bottomCenter,
        colors: fillGradient,
      ).createShader(Rect.fromLTRB(0, 0, size.width, usableHeight));
    }

    final fillPath = Path();
    fillPath.moveTo(drawPoints.first.dx, drawPoints.first.dy);
    for (var sample in drawPoints) {
      fillPath.lineTo(sample.dx, sample.dy);
    }

    fillPath.lineTo(drawPoints.last.dx, usableHeight);
    fillPath.lineTo(xOffset + graphPadding.left, usableHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    //--------------------------------------------------------------------------------------------
    // * DRAW LINE
    //--------------------------------------------------------------------------------------------
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(drawPoints.first.dx, drawPoints.first.dy);
    for (var sample in drawPoints) {
      linePath.lineTo(sample.dx, sample.dy);
    }
    canvas.drawPath(linePath, linePaint);

    //--------------------------------------------------------------------------------------------
    // * DRAW DOT &  VERTICAL LINE ON TOUCH
    //--------------------------------------------------------------------------------------------
    final dotPaint = Paint()..color = dotColor; //TODO: MAKE CUSTOMIZABLE;
    final borderPaint = Paint()..color = Colors.white;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: .3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    late Offset dotPosition;
    if (touchPosition == null) {
      dotPosition = valuePoints.last;
    } else {
      // find value nearest to touch position
      dotPosition = valuePoints
          // .map((e) => e) //LOOKS UNECESSARY, REMOVE OVER TIME
          .reduce(
            (v, e) =>
                (v.dx - touchPosition!.dx).abs() <
                    (e.dx - touchPosition!.dx).abs()
                ? v
                : e,
          );

      // create dashes
      final dashPaint = Paint()..color = dashesColor;
      // ..strokeWidth = 1;
      double dashHeight = 5;
      double dashSpace = 5;
      double startY = usableHeight;
      while (startY > 0) {
        canvas.drawLine(
          Offset(dotPosition.dx, startY),
          Offset(dotPosition.dx, startY - dashHeight),
          dashPaint,
        );
        startY -= dashHeight + dashSpace;
      }
    }
    canvas.drawCircle(dotPosition, 6.0, shadowPaint);
    canvas.drawCircle(dotPosition, 4, borderPaint);
    canvas.drawCircle(dotPosition, 3, dotPaint);

    //--------------------------------------------------------------------------------------------
    // * ON TAP CALLBACK
    //--------------------------------------------------------------------------------------------
    int dotPositionIndex = valuePoints.indexOf(dotPosition);
    if (dotPositionIndex != initialDotPositionIndex) {
      // log(dotPositionIndex.toString(), name: "DOT POSITION INDEX");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onTap?.call(dotPositionIndex);
      });
    }

    //--------------------------------------------------------------------------------------------
    // * DRAW ZERO LINE
    //--------------------------------------------------------------------------------------------

    // if (yAxisMin < 0 && yAxisMax > 0) {
    //   Paint zeroLinePaint = Paint()..color = red;
    //   String text = unitAlignment == UnitAlignment.left ? "${unit}0" : "0$unit";
    //   final zeroTextPainter = TextPainter(
    //     text: TextSpan(
    //       text: text,
    //       style: TextStyle(color: red, fontSize: 10),
    //     ),
    //     textDirection: TextDirection.ltr,
    //     textAlign: .right,
    //     textWidthBasis: TextWidthBasis.longestLine,
    //   )..layout(minWidth: yTextWidth);

    //   double zeroY = getYPos(0.0);
    //   zeroTextPainter.paint(
    //     canvas,
    //     Offset(0, zeroY - zeroTextPainter.height / 2),
    //   );
    //   canvas.drawLine(
    //     Offset(yTextWidth + yLabelSpacing, zeroY),
    //     Offset(size.width, zeroY),
    //     zeroLinePaint,
    //   );
    // }
  }

  //--------------------------------------------------------------------------------------------
  // * HELPER FUNCTIONS
  //--------------------------------------------------------------------------------------------

  // Map<String, int> calAxisBounds(double max, double min) {
  //   double range = (max - min).abs();
  //   if (range == 0) range = max == 0 ? 1 : max.abs();

  //   double step = range / (yAxisLineCount - 1);
  //   // we divide by  `ln10` to convert the log to base 10
  //   // that way log10(value) will give us the magnitude (exponent of 10 that makes that value)
  //   double exp = (log(step) / ln10).floorToDouble();
  //   // magnitude is the actual tens (eg 1000/ 1000000)
  //   double mag = pow(10, exp).toDouble();
  //   // the residual helps us know where in the tens(magnitude)
  //   // the step is, and based on that we round it to the
  //   // nearest nice number (120 - 100, 165 - 200)
  //   double residual = step / mag;

  //   double multiplier;
  //   if (residual < 1.5) {
  //     multiplier = 1.0;
  //   } else if (residual < 3.0) {
  //     multiplier = 2.0;
  //   } else if (residual < 7.0) {
  //     multiplier = 5.0;
  //   } else {
  //     multiplier = 10.0;
  //   }

  //   step = multiplier * mag;
  //   dev.log(step.toString(), name: "INITIAL STEP");

  //   // round max to be a multiple of step
  //   max = max + (max * 0.05);
  //   max = (max / step).ceilToDouble() * step;

  //   double minStepVal = max - (step * (yAxisLineCount - 1));

  //   // round min to a multiple of step
  //   if (min.isNegative) {
  //     min = (min / step).floorToDouble() * step;
  //     dev.log(min.toString(), name: 'NEGATIVE MIN ROUNDING');
  //   } else if (min <= 20) {
  //     min = 0;
  //   } else {
  //     min = (min / step).floorToDouble() * step;
  //     dev.log(min.toString(), name: 'POSITIVE MIN ROUNDING');
  //   }

  //   if (min.isNegative) {
  //     // adust count to accommodate the range of the rounded range
  //     yAxisLineCount = ((max - min) / step).round() + 1;
  //     dev.log(yAxisLineCount.toString(), name: "YAXISCOUNT UPDATE");
  //     minStepVal = max - (step * (yAxisLineCount - 1));
  //     min = minStepVal;
  //   }

  //   //------------------------------------------------------
  //   dev.log(minStepVal.toString(), name: 'MIN STEP VALUE');
  //   if (minStepVal > min) {
  //     // bump multiplier up
  //     if (multiplier == 1.0) {
  //       multiplier = 2.0;
  //     } else if (multiplier == 2.0) {
  //       multiplier = 5.0;
  //     } else if (multiplier == 5.0) {
  //       multiplier = 10.0;
  //     }
  //     // update step
  //     step = multiplier * mag;
  //     max = (max / step).ceilToDouble() * step;
  //     minStepVal = max - (step * (yAxisLineCount - 1));
  //     // min = minStepVal;

  //     // if we're not dealing with negative numbers //? Could (will) always be positive
  //     // but after bumping up the step the last value will be a neg, then
  //     //

  //     //  else if (min.isNegative) {
  //     //   yAxisLineCount++;
  //     //   min = stepMinValue;
  //     // }
  //   }
  //   // if (!min.isNegative && minStepVal < min) {
  //   // here I'm finding the count that will ensure
  //   // the stepMinValue is nearest to the min value but less than it.
  //   // adust count to accommodate range
  //   yAxisLineCount = ((max - min) / step).round() + 1;
  //   dev.log(yAxisLineCount.toString(), name: "YAXISCOUNT UPDATE");
  //   // yAxisLineCount--;
  //   // }

  //   Map<String, int> data = {
  //     'min': min.toInt(),
  //     'max': max.toInt(),
  //     'step': step.toInt(),
  //   };
  //   dev.log(data.toString(), name: "DATA");
  //   return data;
  // }

  //--------------------------------------------------------------------------------------------
  int calYAxisMax(double maxVal) {
    maxVal *= 1.02; //todo let users define percentage
    double factor = (maxVal / (yAxisLineCount - 1));
    // check if it's an exact factor (integer) otherwise increase by 1;
    int nextFactor = factor % 1 == 0 ? factor.floor() : factor.floor() + 1;
    int result = (yAxisLineCount - 1) * nextFactor;

    int tens = 1;

    while (true) {
      if (result / tens < 10) {
        break;
      } else {
        tens *= 10;
      }
    }

    // this is a round up mechanism
    // use 4 steps if tens is 100s and above
    // take the max, round it to the next quarter(4) or half (2) of it's tens

    double step =
        tens /
        (tens > 10
            ? 4
            : tens < 10
            ? 1
            : 2);

    return (result / step).ceil() * step.toInt();
  }

  //--------------------------------------------------------------------------------------------
  int calYAxisMin(double minVal) {
    if (minVal < 50) {
      return 0;
    }
    minVal *= 1.05; //todo let users define percentage
    double factor = (minVal / (yAxisLineCount - 1));
    // check if it's an exact factor (integer) otherwise increase by 1;
    int nextFactor = factor % 1 == 0 ? factor.floor() : factor.floor() - 1;
    int result = (yAxisLineCount - 1) * nextFactor;
    // int result = maxVal.ceil();
    int tens = 1;

    while (true) {
      if (result.abs() / tens < 10) {
        break;
      } else {
        tens *= 10;
      }
    }

    // this is a round up mechanism
    // use 4 steps if tens is 100s and above
    // take the max, round it to the next quarter(4) or half (2) of it's tens

    double step =
        tens /
        (tens > 10
            ? 4
            : tens < 10
            ? 1
            : 2);

    return (result / step).floor() * step.toInt();
  }

  //--------------------------------------------------------------------------------------------
  int calYAxisDiv(int max) {
    // we've to calculate the smallest factor of the value and use that
    // return 2;
    if (max < 4) return 5;
    for (int i = 4; i < max; i++) {
      if (max % i == 0) {
        // RULE: If max is even, the division count (i) should be even

        // if (i.isEven) return i;

        if (i % 5 == 0) return i;
      }
    }

    return 5;
  }

  //--------------------------------------------------------------------------------------------
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
