(local gamera (require "lib.gamera"))

(local camera {})

(fn camera.new [world]
  (let [c (gamera.new 0 0 world.w world.h)]
    (: c :setScale 64)
    (: c :setPosition 0 0)
    ;; TODO: determine amount of window to use
    ;; (: c :setWindow 0 0 500 500)
    c))

(fn camera.zoom [state dt dir]
  (let [scale-factor (if (= dir :in)   32
                         (= dir :out) -32
                         :else 0)
        old-scale (: state.camera.main :getScale)
        new-scale (+ old-scale (* scale-factor dt))]
    (: state.camera.main :setScale (lume.clamp new-scale 12 128))))

(fn camera.move [state dt dir]
  (let [(x y) (: state.camera.main :getPosition)
        p (if (= dir :left)  [(- x (* 12 dt)) y]
              (= dir :right) [(+ x (* 12 dt)) y]
              (= dir :up)    [x (- y (* 12 dt))]
              (= dir :down)  [x (+ y (* 12 dt))])]
    (: state.camera.main :setPosition (unpack p))))

camera