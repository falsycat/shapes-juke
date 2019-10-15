/// License: MIT
module sjplayer.ShapeElementScheduledController;

import sjplayer.CircleElement,
       sjplayer.ElementInterface,
       sjplayer.ElementScheduledControllerFactory,
       sjplayer.ScheduledController;

///
template ShapeElementScheduledController(Element)
    if (is(Element : ElementInterface)) {
  alias ShapeElementScheduledController = ScheduledController!(
      Element,
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
  static assert(ShapeElementScheduledController.AliveManagementAvailable);
  static assert(ShapeElementScheduledController.MatrixModificationAvailable);
  static assert(ShapeElementScheduledController.AutoInitializationAvailable);
}
