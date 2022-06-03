# ******************************************************************************************
#
#    raylib [core] example - Basic window
#
#    Welcome to raylib!
#
#    To test examples, just press F6 and execute raylib_compile_execute script
#    Note that compiled executable is placed in the same folder as .c file
#
#    You can find all basic examples on C:\raylib\raylib\examples folder or
#    raylib official webpage: www.raylib.com
#
#    Enjoy using raylib. :)
#
#    This example has been created using raylib 1.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2013-2016 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import std/strformat
import std/random
import std/math
import nimraylib_now
import perlin

const SCREEN_WIDTH: int = 800
const SCREEN_HEIGHT: int = 450

type
  Walker = tuple
    x, y: float

  Vec2 = tuple
    x, y: float

proc monteCarlo(): float =
  while (true):
    var r1 = rand(1.0)
    var r2 = rand(1.0)
    if r2 < r1:
      return r1

proc interpolate(a, b, w: float): float =
  return (a - b) * w + a

proc project(v: float, a: Vec2, b: Vec2): float =
  let scale = (b.y - b.x) / (a.y - a.x)
  return (v - a.x) * scale + b.x

randomize()

initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window")
setTargetFPS(60)

var buffer = loadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
beginTextureMode(buffer):
  clearBackground(White)

var walker: Walker
walker = (x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2)
walker.x += gauss() * monteCarlo()
walker.y += gauss() * monteCarlo()

var hue = 0.0

while not windowShouldClose():
  # walker.x += gauss() * monteCarlo()
  # walker.y += gauss() * monteCarlo()
  let dx = noise(walker.x + 0.137, walker.y + 0.259, 127.127) * 10.0
  let dy = noise(walker.x + 0.137, walker.y + 0.259, 249.249) * 10.0
  if dx == 0.0 and dy == 0.0:
    walker.x += gauss() * monteCarlo()
    walker.y += gauss() * monteCarlo()
  else:
    walker.x += noise(walker.x + 0.137, walker.y + 0.259, 127.127) * 10.0
    walker.y += noise(walker.x + 0.137, walker.y + 0.259, 249.249) * 10.0

  if walker.x < 0.0:
    walker.x = 0.0 + gauss() * monteCarlo()
  elif walker.x > toFloat(SCREEN_WIDTH):
    walker.x = toFloat(SCREEN_WIDTH) + gauss() * monteCarlo()

  if walker.y < 0.0:
    walker.y = 0.0 + gauss() * monteCarlo()
  elif walker.y > toFloat(SCREEN_HEIGHT):
    walker.y = toFloat(SCREEN_HEIGHT) + gauss() * monteCarlo()

  beginTextureMode(buffer):
    drawCircle(toInt walker.x, toInt walker.y, 8, colorFromHSV(hue, 1.0, 1.0))

  beginDrawing:
    drawTexture(buffer.texture, 0, 0, Raywhite)
    drawFPS(10, 10)

  hue += 0.1

closeWindow()
