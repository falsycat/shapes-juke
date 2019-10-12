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
        CreateCubes(cube_matrix.Create(), cube_interval)[],
        Projection, view.Create(), light_pos, cube_material);
  }

  ///
  @property Background background() {
    return background_;
  }

  ///
  ViewMatrixFactory view;
  ///
  vec3 light_pos = vec3(0, 10, 0);
  ///
  CubeProgram.Material cube_material;
  ///
  ModelMatrixFactory!4 cube_matrix;
  ///
  float cube_interval = 0.005;

 private:
  static mat4[8] CreateCubes(mat4 model, float interval) {
    mat4[8] cubes;

    enum  sz = 0.05;
    const si = sz + interval;

    auto m = mat4.identity;
    m.scale(sz, sz, sz);
    cubes[] = m;

    cubes[0].translate( si,  si,  si);
    cubes[1].translate(-si,  si,  si);
    cubes[2].translate( si, -si,  si);
    cubes[3].translate(-si, -si,  si);
    cubes[4].translate( si,  si, -si);
    cubes[5].translate(-si,  si, -si);
    cubes[6].translate( si, -si, -si);
    cubes[7].translate(-si, -si, -si);

    cubes[].each!((ref x) => x = model * x);
    return cubes;
  }

  Background background_;

  CubeProgram cube_program_;
}
