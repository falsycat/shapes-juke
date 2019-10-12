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
  enum Projection = mat4.perspective(1, 1, 60, 0.1, 100);

  ///
  this(ProgramSet programs) {
    background_   = new Background(programs.Get!BackgroundProgram);
    cube_program_ = programs.Get!CubeProgram;
  }

  ///
  void Draw() {
    gl.Disable(GL_DEPTH_TEST);
    gl.DepthMask(false);
    background_.Draw();

    gl.Enable(GL_DEPTH_TEST);
    gl.DepthMask(true);
    cube_program_.Draw(
        cubes.map!"a.Create()",
        Projection, view.Create(), light_pos, cube_material);
  }

  ///
  @property Background background() {
    return background_;
  }

  ///
  ModelMatrixFactory!4[] cubes;
  ///
  ViewMatrixFactory view;
  ///
  vec3 light_pos = vec3(0, 10, 0);
  ///
  CubeProgram.Material cube_material;

 private:
  Background background_;

  CubeProgram cube_program_;
}
