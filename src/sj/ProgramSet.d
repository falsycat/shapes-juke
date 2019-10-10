/// License: MIT
module sj.ProgramSet;

static import sjplayer = sjplayer.ProgramSet;

///
class ProgramSet {
 public:
  ///
  this() {
    for_players_ = new sjplayer.ProgramSet;
  }
  ~this() {
    for_players_.destroy();
  }

  ///
  @property sjplayer.ProgramSet forPlayers() {
    return for_players_;
  }

 private:
  sjplayer.ProgramSet for_players_;
}
