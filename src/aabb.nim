import std/options
import vec2

type
  Aabb* = concept a
    a.p0 is Vec2
    a.p1 is Vec2

func timeToOverlap(a0, a1, b0, b1: float, va, vb: float): Option[float] {.inline.} =
  if a0 < b0 and a1 < b0 and va != vb:
    return some((a1 - b0) / (vb - va))
  elif b0 < a0 and b1 < a0 and va != vb:
    return some((b1 - a0) / (va - vb))
  elif a0 < b0 and (b0 - a0).abs() <= (a1 - a0):
    return some(0.0)
  elif (b0 - a0).abs() <= (b1 - b0):
    return some(0.0)
  else:
    return none(float)

func timeToDisjoint(a0, a1, b0, b1: float, va, vb: float): Option[float] {.inline.} =
  #  |a0------|a1
  #  |-----------t----------|
  #                |b0------|b1 <-v
  #      ~ or ~
  #       |a0------|a1
  #       |-t-|
  #  |b0------|b1 <-v
  #      ~ or ~
  #  |a0------|a1
  #      |-t--|
  #      |b0------|b1 <-v
  #      ~ or ~
  #     |a0------|a1
  #     |-----t-----|
  #  |b0------------|b1 <-v
  #      ~ or ~
  # |a0------------|a1
  # |------t----|
  #     |b0-----|b1 <-v
  let v = vb - va
  if v < 0.0:
    return some(-(b1 - a0) / v)
  elif v > 0.0:
    return some((a1 - b0) / v)
  else:
    return none(float)


func timeToOverlap[T, U: Aabb](a: T; b: U; va, vb: Vec2): Option[float] =
  var timeToOverlapX = timeToOverlap(a.p0.x, a.p1.x, b.p0.x, b.p1.x, va.x, vb.x)
  var timeToOverlapY = timeToOverlap(a.p0.y, a.p1.y, b.p0.y, b.p1.y, va.y, vb.y)

  if timeToOverlapX.isSome() and timeToOverlapY.isSome():
    return some(max(timeToOverlapX.get(), timeToOverlapY.get()))
  else:
    return none(float)

func timeToDisjoint[T, U: Aabb](a: T; b: U; va, vb: Vec2): Option[float] =
  var timeToDisjointX = timeToDisjoint(a.p0.x, a.p1.x, b.p0.x, b.p1.x, va.x, vb.x)
  var timeToDisjointY = timeToDisjoint(a.p0.y, a.p1.y, b.p0.y, b.p1.y, va.y, vb.y)

  if timeToDisjointX.isSome() and timeToDisjointY.isSome():
    return some(min(timeToDisjointX.get(), timeToDisjointY.get()))
  elif timeToDisjointX.isSome():
    return timeToDisjointX
  elif timeToDisjointY.isSome():
    return timeToDisjointY
  else:
    return none(float)

func timeToCollision*[T, U: Aabb](a: T; b: U; va, vb: Vec2): Option[float] =
  let overlapTime = timeToOverlap(a, b, va, vb)
  let disjointTime = timeToDisjoint(a, b, va, vb)

  if overlapTime.isSome() and disjointTime.isSome():
    if overlapTime.get() < disjointTime.get():
      return overlapTime
    else:
      return none(float)
  elif overlapTime.isSome():
    return overlapTime
  else:
    return none(float)

func overlap*[T, U: Aabb](a: T; b: U): Vec2 =
  let dx = max(0.0, min(a.p1.x, b.p1.x) - max(a.p0.x, b.p0.x))
  let dy = max(0.0, min(a.p1.y, b.p1.y) - max(a.p0.y, b.p0.y))
  return Vec2(x: dx, y: dy)