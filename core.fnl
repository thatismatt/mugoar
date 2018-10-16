(local repl (require "lib.repl"))
(local units (require "units"))
(local draw (require "draw"))
(local world (require "world"))
(local camera (require "camera"))

(local canvas
  (love.graphics.newCanvas 1024 768))

(local state
  (let [world (world.new 50 50)]
    {:world world
     :camera {:main (camera.new world)}
     :entities {}
     :debug {:draw-bounding-box? false}}))

(let [w/2 (/ state.world.w 2)
      h/2 (/ state.world.h 2)]
  (world.add state {:unit :dragster :colour [0.8 0 0.6] :heading 0 :speed 2} [(+ w/2 4) (+ h/2 4)])
  (world.add state {:unit :dragster :colour [0 0.7 0.3] :heading 0 :speed 2} [(+ w/2 5) (+ h/2 6)])
  (world.add state {:unit :factory  :colour [0 0.7 0.3] :heading 0 :speed 0} [(+ w/2 3) (+ h/2 2)])
  (world.add state {:unit :factory  :colour [0.8 0 0.6] :heading 0 :speed 0} [(+ w/2 1) (+ h/2 1)])
  (camera.position state [(+ w/2 5) (+ h/2 5)]))

(fn love.load []
  (: canvas :setFilter "nearest" "nearest")
  (repl.start))

(fn love.draw []
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (: state.camera.main :draw
     (fn [l t w h]
       ;; TODO: only draw what is visible
       (draw.map state)
       (draw.entities state)))
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 1 1))

(var elapsed-time 0)

(fn love.update [dt]
  (set elapsed-time (+ elapsed-time dt))
  (let [[a b] (lume.filter state.entities (fn [e] (= e.unit :dragster)))]
    (set a.heading (+ a.heading dt)) ;; send a in a circle
    (set b.heading (if (> (math.cos (/ elapsed-time 2)) 0) 0 math.pi))) ;; send b back and forth
  (if (love.keyboard.isDown "=")     (camera.zoom state dt :in)
      (love.keyboard.isDown "-")     (camera.zoom state dt :out))
  (if (love.keyboard.isDown "up")    (camera.move state dt :up)
      (love.keyboard.isDown "down")  (camera.move state dt :down))
  (if (love.keyboard.isDown "left")  (camera.move state dt :left)
      (love.keyboard.isDown "right") (camera.move state dt :right))
  (lume.map state.entities (fn [e] (world.move state dt e (fn [x y] :slide)))))

(fn love.keypressed [key]
  (if (or (= key "escape")
          (and (love.keyboard.isDown "lctrl" "rctrl" "capslock")
               (= key "q")))
      (love.event.quit)))
