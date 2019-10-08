/// License: MIT
module sjplayer.util.Period;

import sjscript;

///
bool IsTimeInPeriod(in Period period, float time) {
  return period.start <= time && time < period.end;
}

///
bool IsPeriodIntersectedToPeriod(in Period p1, in Period p2) {
  return p1.start < p2.end && p2.start < p1.end;
}

///
float ConvertToRelativeTime(in Period period, float src)
    in (period.start < period.end) {
  return (src - period.start) / (period.end - period.start);
}
