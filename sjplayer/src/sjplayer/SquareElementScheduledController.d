/// License: MIT
module sjplayer.SquareElementScheduledController;

import std.typecons;

import sjplayer.ElementScheduledControllerFactory,
       sjplayer.ScheduledController,
       sjplayer.SquareElement;

///
alias SquareElementScheduledController = ScheduledController!(
    SquareElement,
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
static assert(SquareElementScheduledController.AliveManagementAvailable);
static assert(SquareElementScheduledController.MatrixModificationAvailable);
static assert(SquareElementScheduledController.AutoInitializationAvailable);

///
alias SquareElementScheduledControllerFactory =
  ElementScheduledControllerFactory!(
      SquareElementScheduledController,
      SquareElementDrawer);
