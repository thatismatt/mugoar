(local repl (require "lib.repl"))
(local bump (require "lib.bump"))
(local units (require "units"))
(local draw (require "draw"))
(local world (require "world"))

(local canvas (love.graphics.newCanvas 1024 768))

(local state {:world (bump.newWorld)
              :entities {}})

(world.add state :a {:unit units.dragster :colour [0.8 0 0.6] :heading 0 :speed 2} [4 4] [1 1])
(world.add state :b {:unit units.dragster :colour [0 0.7 0.3] :heading 0 :speed 2} [5 6] [1 1])

(fn love.load []
  (: canvas :setFilter "nearest" "nearest")
  (repl.start))

(fn love.draw []
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (lume.map state.entities (partial draw.entity state))
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 1 1))

(var elapsed-time 0)

(fn love.update [dt]
  (set elapsed-time (+ elapsed-time dt))
  (set state.entities.a.heading (+ state.entities.a.heading dt)) ;; send a in a circle
  (set state.entities.b.heading (if (> (math.cos (/ elapsed-time 2)) 0) 0 math.pi)) ;; send b back and forth
  (lume.map state.entities (fn [e] (world.move state dt e (fn [x y] :slide)))))

(fn love.keypressed [key]
  (if (or (= key "escape")
          (and (love.keyboard.isDown "lctrl" "rctrl" "capslock")
               (= key "q")))
      (love.event.quit)))
