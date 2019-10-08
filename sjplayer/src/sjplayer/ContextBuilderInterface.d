/// License: MIT
module sjplayer.ContextBuilderInterface;

import sjplayer.ElementDrawerInterface,
       sjplayer.ElementInterface,
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
