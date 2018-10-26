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

(fn draw.object [state unit colour coord selected?]
  (love.graphics.setColor colour)
  (let [[x y] coord
        transform (love.math.newTransform 0 0  0 1 1 (- x) (- y))
        [w h] unit.size]
    (when state.debug.draw-bounding-box?
      (love.graphics.setLineWidth 0.1)
      (love.graphics.line (-> [[0 0] [0 h] [w h] [w 0] [0 0]]
                              (lume.map (fn [pt] [(: transform :transformPoint (unpack pt))]))
                              (lume.reduce lume.concat))))
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
                                    12)))))
    (when selected?
      (love.graphics.setColor [1 1 1 0.5])
      (love.graphics.setLineWidth 0.1)
      (let [(cx cy) (: transform :transformPoint (/ w 2) (/ h 2))]
        (love.graphics.ellipse :line cx cy (/ w 2) (/ h 2) 12)))))

(fn draw.entities [state]
  (-> state.entities
      (lume.map (fn [e] {:entity e
                         :position (world.position state e)
                         :selected? (. state.selection e.id)}))
      (lume.sort (fn [x] (-> x.position (. 2) (* -1))))
      (lume.map (fn [x] (draw.object state (. units x.entity.unit) x.entity.colour x.position x.selected?)))))

(fn draw.hud [state]
  ;; draw background
  (love.graphics.setColor [1 1 1 0.4])
  (love.graphics.polygon :fill [0 0
                                state.hud.w 0
                                state.hud.w state.window.h
                                0 state.window.h])
  (each [i entity-id (lume.ripairs (lume.keys state.selection))]
    (let [padding 10
          entity (. state.entities entity-id)
          unit (. units entity.unit)
          [uw uh] unit.size
          scale (/ (- state.hud.w (* 2 padding)) 4)]
      ;; draw unit name
      (love.graphics.setFont (love.graphics.newFont 36))
      (love.graphics.setColor [1 1 1])
      (love.graphics.print entity.unit
                           padding
                           (+ padding
                              100
                              (* (- i 1) 50)
                              scale))
      ;; draw unit
      (love.graphics.push)
      (love.graphics.translate (+ padding
                                  (* (- i 1) scale 0.5)
                                  (* (- 2 (/ uw 2)) scale)) ;; center the unit
                               (- 100 ;; HACK: account for units that exceed their bbox
                                  (* (- i 1) scale 0.1)))
      (love.graphics.scale scale)
      (draw.object state unit entity.colour [0 0] false)
      (love.graphics.pop))))

(fn draw.draw [state]
  ;; draw map canvas
  (love.graphics.setCanvas state.layers.map)
  (love.graphics.clear)
  (: state.camera.main :draw
     (fn [l t w h]
       ;; TODO: only draw what is visible
       (draw.map state)
       (draw.entities state)))
  ;; draw hud canvas
  (love.graphics.setCanvas state.layers.hud)
  (love.graphics.clear)
  (draw.hud state)
  (when state.debug.draw-fps?
    (love.graphics.setColor [1 1 1])
    (love.graphics.print (tostring (love.timer.getFPS)) 10 10))
  ;; draw canvases to screen
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw state.layers.map 0 0 0 1 1)
  (love.graphics.draw state.layers.hud (- state.window.w state.hud.w)
                      0 0 1 1))

(fn draw.resize [state]
  (set state.layers {:map (love.graphics.newCanvas state.window.w state.window.h)
                     :hud (love.graphics.newCanvas state.hud.w state.window.h)}))

draw
