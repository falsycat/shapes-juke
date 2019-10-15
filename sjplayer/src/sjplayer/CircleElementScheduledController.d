/// License: MIT
module sjplayer.CircleElementScheduledController;

import sjplayer.CircleElement,
       sjplayer.ElementScheduledControllerFactory,
       sjplayer.ScheduledController,
       sjplayer.ShapeElementScheduledController;

///
alias CircleElementScheduledController =
  ShapeElementScheduledController!CircleElement;

///
alias CircleElementScheduledControllerFactory =
  ElementScheduledControllerFactory!(
      CircleElementScheduledController,
      CircleElementDrawer);
