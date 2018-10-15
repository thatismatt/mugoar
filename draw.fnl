(local units (require "units"))
(local world (require "world"))

(local draw {})

(fn draw.map [state]
  (love.graphics.setLineWidth 0.05)
  (for [i 0 state.world.w]
    (love.graphics.setColor [0.3 0.7 1 (if (= (% i 10) 0) 0.8 0.4)])
    (love.graphics.line i 0 i state.world.h))
  (for [i 0 state.world.h]
    (love.graphics.setColor [0.3 0.7 1 (if (= (% i 10) 0) 0.8 0.4)])
    (love.graphics.line 0 i state.world.w i)))

(fn draw.object [state unit colour coord]
  (love.graphics.setColor colour)
  (let [[x y] coord
        transform (love.math.newTransform 0 0  0 1 1 (- x) (- y))]
    (if state.debug.draw-bounding-box?
        (let [[w h] unit.size]
          (love.graphics.setLineWidth 0.1)
          (love.graphics.line (-> [[0 0] [0 h] [w h] [w 0] [0 0]]
                                  (lume.map (fn [pt] [(: transform :transformPoint (unpack pt))]))
                                  (lume.reduce lume.concat)))))
    (lume.map
     unit.shapes
     (fn [s]
       (if (= s.shape :polygon)
           (love.graphics.polygon :fill
                                  (-> s.pts
                                      (lume.map (fn [pt] [(: transform :transformPoint (unpack pt))]))
                                      (lume.reduce lume.concat)))
           (= s.shape :ellipse)
           (let [[rx ry] (if (= (type s.r) "table") s.r [s.r s.r])
                 (cx cy) (: transform :transformPoint (unpack s.c))]
             (love.graphics.ellipse :fill
                                    cx cy rx ry
                                    12)))))))

(fn draw.entity [state entity]
  (draw.object state
               (. units entity.unit)
               entity.colour
               (world.position state entity)))

(fn draw.entities [state]
  (lume.map state.entities (partial draw.entity state)))

draw
