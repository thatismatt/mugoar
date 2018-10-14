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

(world.add state :a {:unit :dragster :colour [0.8 0 0.6] :heading 0 :speed 2} [4 4])
(world.add state :b {:unit :dragster :colour [0 0.7 0.3] :heading 0 :speed 2} [5 6])
(world.add state :f {:unit :factory  :colour [0 0.7 0.3] :heading 0 :speed 0} [3 3])
(world.add state :g {:unit :factory  :colour [0.8 0 0.6] :heading 0 :speed 0} [1 1])

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
       (draw.entities state)))
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 1 1))

(var elapsed-time 0)

(fn love.update [dt]
  (set elapsed-time (+ elapsed-time dt))
  (set state.entities.a.heading (+ state.entities.a.heading dt)) ;; send a in a circle
  (set state.entities.b.heading (if (> (math.cos (/ elapsed-time 2)) 0) 0 math.pi)) ;; send b back and forth
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
