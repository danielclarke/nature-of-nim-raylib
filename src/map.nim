import vec2
import tiles

type
  Wall* = object
    p0*, p1*: Vec2
  
  Water* = object
    p0*, p1*: Vec2
    c*: float

proc countElems*[w, h](tiles: array[w, array[h, int]]): int =
  var count = 0
  for i, row in tiles:
    for j, tile in row:
      if tile > 0:
        inc count
  return count

proc loadWalls*[w, h, n](walls: var array[n, Wall]; tiles: array[w, array[h, int]]) =
  var iWall = 0
  for i, row in tiles:
    for j, tile in row:
      if tile > 0:
        walls[iWall] = Wall(
          p0: Vec2(x: toFloat(i), y: toFloat(j)),
          p1: Vec2(x: toFloat(i + 1), y: toFloat(j + 1))
        )
        inc iWall

proc loadWaters*[w, h, n](waters: var array[n, Water]; tiles: array[w, array[h, int]], c: float) =
  var iWater = 0
  for i, row in tiles:
    for j, tile in row:
      if tile > 0:
        waters[iWater] = Water(
          p0: Vec2(x: toFloat(i), y: toFloat(j)),
          p1: Vec2(x: toFloat(i + 1), y: toFloat(j + 1)),
          c: c
        )
        inc iWater