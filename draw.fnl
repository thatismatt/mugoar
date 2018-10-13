(local draw {})

(fn draw.object [obj colour coord]
  (love.graphics.setColor colour)
  (let [[x y] coord
        cell-size 64
        ;;                                x y  angle scale               offset
        scale     (love.math.newTransform 0 0  0     cell-size cell-size 0 0) ;; scale only, no offset (e.g. for radius)
        transform (love.math.newTransform 0 0  0     cell-size cell-size (- x) (- y))]
    ;; bounding box
    (love.graphics.polygon :line
                           (-> [[0 0] [0 1] [1 1] [1 0]]
                               (lume.map (fn [pt] [(: transform :transformPoint (unpack pt))]))
                               (lume.reduce lume.concat)))
    (lume.map
     obj
     (fn [s]
       (if (= s.shape :polygon)
           (love.graphics.polygon :fill
                                  (-> s.pts
                                      (lume.map (fn [pt] [(: transform :transformPoint (unpack pt))]))
                                      (lume.reduce lume.concat)))
           (= s.shape :ellipse)
           (let [r (if (= (type s.r) "table") s.r [s.r s.r])
                 (cx cy) (: transform :transformPoint (unpack s.c))
                 (rx ry) (: scale :transformPoint (unpack r))]
             (love.graphics.ellipse :fill
                                    cx cy rx ry
                                    12)))))))

draw
