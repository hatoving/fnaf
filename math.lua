function math.clamp(x, min, max) return math.min(math.max(x, min), max) end
function math.lerp(a, b, t) return a + (b - a) * t end