import std/math

type
  Vec2* = object
    x*, y*: float

func `+`*(u, v: Vec2): Vec2 =
  Vec2(x: u.x + v.x, y: u.y + v.y)

func `-`*(u, v: Vec2): Vec2 =
  Vec2(x: u.x - v.x, y: u.y - v.y)

func `-`*(v: Vec2): Vec2 =
  Vec2(x: -v.x, y: -v.y)

func `*`*(v: Vec2, s: float): Vec2 =
  Vec2(x: v.x * s, y: v.y * s)

func `+=`*(u: var Vec2; v: Vec2) =
  u = u + v

func `-=`*(u: var Vec2; v: Vec2) =
  u = u - v

func `*=`*(v: var Vec2, s: float) =
  v = v * s

func `*`*(s: float, v: Vec2): Vec2 =
  v * s

func `/`*(v: Vec2, s: float): Vec2 =
  Vec2(x: v.x / s, y: v.y / s)

func mag*(v: Vec2): float =
  sqrt(v.x * v.x + v.y * v.y)

func norm*(v: Vec2): Vec2 =
  let m = mag(v)
  if m == 0.0:
    return v
  else:
    return v / m

func limit*(v: Vec2, l: float): Vec2 =
  let m = mag(v)
  if l < m:
    return v / m * l
  else:
    return v
