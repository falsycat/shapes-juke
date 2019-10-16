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

    view.pos    = vec3(0, -0.15, -1);
    view.target = vec3(0, -0.15, 0);
    view.up     = vec3(0, 1, 0);

    background.inner_color = vec4(0, 0, 0, 0);
    background.outer_color = vec4(0, 0, 0, 0);

    cube_material.diffuse_color  = vec3(0.1, 0.1, 0.1);
    cube_material.light_color    = vec3(1, 1, 1);
    cube_material.light_power    = vec3(100, 100, 100);
    cube_material.ambient_color  = vec3(0.2, 0.2, 0.2);
    cube_material.specular_color = vec3(0.2, 0.2, 0.2);
  }

  ///
  void Draw() {
    background_.Draw();

    gl.Enable(GL_DEPTH_TEST);
    cube_program_.Draw(
        CreateCubes(cube_matrix.Create(), cube_interval)[],
        Projection, view.Create(), light_pos, cube_material);
    gl.Disable(GL_DEPTH_TEST);
  }

  ///
  @property Background background() {
    return background_;
  }

  ///
  ViewMatrixFactory view;
  ///
  vec3 light_pos = vec3(0, 9, -1);
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
