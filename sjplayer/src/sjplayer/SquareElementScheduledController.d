/// License: MIT
module sjplayer.SquareElementScheduledController;

import sjplayer.ElementScheduledControllerFactory,
       sjplayer.ScheduledController,
       sjplayer.ShapeElementScheduledController,
       sjplayer.SquareElement;

///
alias SquareElementScheduledController =
  ShapeElementScheduledController!SquareElement;

///
alias SquareElementScheduledControllerFactory =
  ElementScheduledControllerFactory!(
      SquareElementScheduledController,
      SquareElementDrawer);
