/// License: MIT
module sjplayer.ContextBuilderInterface;

import sjplayer.ElementInterface,
       sjplayer.ScheduledControllerInterface;

///
interface ContextBuilderInterface {
 public:
  ///
  void AddElement(ElementInterface element);
  ///
  void AddElementDrawer(ElementDrawerInterface drawer);
  ///
  void AddScheduledController(ScheduledControllerInterface controller);
}
