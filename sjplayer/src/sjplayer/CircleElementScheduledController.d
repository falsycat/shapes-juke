/// License: MIT
module sjplayer.CircleElementScheduledController;

import std.typecons;

import sjplayer.CircleElement,
       sjplayer.ElementScheduledController,
       sjplayer.ScheduledControllerFactory;

///
alias CircleElementScheduledController = ElementScheduledController!(
    CircleElement,
    [
      "damage":       "damage",
      "nearness_coe": "nearness_coe",
      "weight":       "weight",
      "smooth":       "smooth",
      "color_r":      "color.r",
      "color_g":      "color.g",
      "color_b":      "color.b",
      "color_a":      "color.a",
    ]
  );
static assert(CircleElementScheduledController.AliveManagementAvailable);
static assert(CircleElementScheduledController.MatrixModificationAvailable);

///
alias CircleElementScheduledControllerFactory =
  ElementScheduledControllerFactory!(
      CircleElementScheduledController,
      CircleElementDrawer);
