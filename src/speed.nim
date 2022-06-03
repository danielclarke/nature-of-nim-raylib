import std/monotimes
import std/random

type
  Sortable[T] = concept
    proc len(a: Self): int
    proc cmp(a, b: T): int

  Vec3 = tuple
    x, y, z: float

func len(self: Vec3): int =
  return 3

func sort(s: Sortable) =
  let s = 1

func reduce(ar: openArray[float], start: float, f: proc(a,
    b: float): float{.noSideEffect.}): float =
  var s = start
  for v in ar:
    s = f(s, v)
  return s

func sum(ar: openArray[float]): float =
  for v in ar:
    result = result + v

proc main() =
  randomize()

  let v: Vec3 = (x: 0.0, y: 0.0, z: 0.0)
  echo(cmp(v, v))
  sort(v)

  const numFloats = 1_000_00
  var ar1: array[numFloats, float]

  for i in 0 ..< numFloats:
    ar1[i] = random.rand(10.0)

  let t0 = getMonoTime()
  let s = ar1.reduce(0.0, func(a, b: float): float = a + b)
  # let s = sum(ar1)
  let t1 = getMonoTime()
  echo(t1 - t0)
  echo(s)

main()
