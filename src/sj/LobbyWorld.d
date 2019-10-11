/// License: MIT
module sj.LobbyWorld;

import std.algorithm;

import gl4d;

import sjplayer.Background;

import sj.CubeProgram,
       sj.ProgramSet;

///
class LobbyWorld {
 public:
  ///
  enum Perspective = mat4.perspective(-0.5, 0.5, -0.5, 0.5, 0.1, 100);

  ///
  this(ProgramSet programs) {
    background_ = new Background(programs.Get!BackgroundProgram);
    cube_       = programs.Get!CubeProgram;
  }

  ///
  void Draw() {
    gl.Disable(GL_DEPTH_TEST);
    gl.DepthMask(false);
    background_.Draw();

    gl.Enable(GL_DEPTH_TEST);
    gl.DepthMask(true);
    cube_.Draw(
        cubes.map!(x => Perspective * view * x),
        light_color, light_direction, ambient_color);
  }

  ///
  @property Background background() {
    return background_;
  }

  ///
  mat4[] cubes;
  ///
  mat4 view = mat4.look_at(vec3(0, 0, -1), vec3(0, 0, 0), vec3(0, 1, 0));
  ///
  vec3 light_color = vec3(1, 1, 1, 1);
  ///
  vec3 light_direction = vec3(0, 1, 0);
  ///
  vec3 ambient_color = vec3(0.1, 0.1, 0.1);

 private:
  Background background_;

  CubeProgram cube_;
}
