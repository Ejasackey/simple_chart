import 'dart:math';

Map<String, int> calAxisBounds({
  required double max,
  required double min,
  required int lineCount,
  required String source,
  double valueMargin = 0.0,
}) {
  max = max + (max * valueMargin);
  min = min - (min * valueMargin);
  if (!min.isNegative && min < 5) {
    min = 0;
  } else if (max.isNegative && max > -5) {
    max = 0;
  }

  double range = (max - min).abs();
  if (range == 0) {
    min = min - .01;
    range = (max - min).abs();
  }

  double step = range / (lineCount - 1);
  // we divide by  `ln10` to convert the log to base 10
  // that way log10(value) will give us the magnitude (exponent of 10 that makes that value)
  double exp = (log(step) / ln10).floorToDouble();
  // magnitude is the actual tens (eg 1000/ 1000000)
  double mag = pow(10, exp).toDouble();
  // the residual helps us know where in the tens(magnitude)
  // the step is, and based on that we round it to the
  // nearest nice number (120 - 100, 165 - 200)
  double residual = step / mag;

  double multiplier;
  if (residual < 1.5) {
    multiplier = 1.0;
  } else if (residual < 3.0) {
    multiplier = 2.0;
  } else if (residual < 7.0) {
    multiplier = 5.0;
  } else {
    multiplier = 10.0;
  }

  step = (multiplier * mag).ceilToDouble();
  // dev.log(step.toString(), name: "$source INITIAL STEP");

  // round max to be a multiple of step
  // max = max + (max * 0.05);
  max = (max / step).ceilToDouble() * step;
  min = (min / step).floorToDouble() * step;

  // dev.log(max.toString(), name: "$source MAX AFTER ROUNDING");
  // dev.log(min.toString(), name: "$source MIN AFTER ROUNDING");

  double minStepVal = max - (step * (lineCount - 1));

  //------------------------------------------------------
  // dev.log(minStepVal.toString(), name: '$source MIN STEP VALUE');
  if (minStepVal > min) {
    // bump multiplier up
    if (multiplier == 1.0) {
      multiplier = 2.0;
    } else if (multiplier == 2.0) {
      multiplier = 5.0;
    } else if (multiplier == 5.0) {
      multiplier = 10.0;
    } else {
      multiplier = 20;
    }
    step = multiplier * mag;
    // dev.log(step.toString(), name: "$source NEW STEP");
    max = (max / step).ceilToDouble() * step;
    min = (min / step).floorToDouble() * step;

    // if we're not dealing with negative numbers //? Could (will) always be positive
    // but after bumping up the step the last value will be a neg, then
    //

    if (min.isNegative) {
      minStepVal = max - (step * (lineCount - 1));
      min = minStepVal;
    }
  }

  // dev.log(lineCount.toString(), name: "$source Y AXIS COUNT BEFORE ADJUSTMENT");
  lineCount = ((max - min) / step).round() + 1;
  // dev.log(lineCount.toString(), name: "$source Y AXIS COUNT AFTER ADJUSTMENT");

  Map<String, int> data = {
    'min': min.toInt(),
    'max': max.toInt(),
    'step': step.ceil().toInt(),
    'lineCount': lineCount,
  };
  // dev.log(data.toString(), name: "DATA");
  return data;
}
