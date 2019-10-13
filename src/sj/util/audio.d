/// License: MIT
module sj.util.audio;

import derelict.sfml2.audio;

///
sfSoundBuffer* CreateSoundBufferFromBuffer(in ubyte[] buf) {
  return sfSoundBuffer_createFromMemory(buf.ptr, buf.length);
}
