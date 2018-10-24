(local repl (require "lib.repl"))
(local units (require "units"))
(local draw (require "draw"))
(local world (require "world"))
(local camera (require "camera"))

(local state
  (let [world (world.new 50 50)]
    {:world world
     :window {:w 1024 :h 768}
     :camera {:main (camera.new world)}
     :entities {}
     :selection {}
     :debug {:draw-bounding-box? false
             :draw-fps? false}}))

(let [w/2 (/ state.world.w 2)
      h/2 (/ state.world.h 2)]
  (world.add state {:unit :dragster :colour [0.8 0 0.6] :heading 0 :speed 2} [(+ w/2 4) (+ h/2 4)])
  (world.add state {:unit :dragster :colour [0 0.7 0.3] :heading 0 :speed 2} [(+ w/2 5) (+ h/2 6)])
  (world.add state {:unit :factory  :colour [0 0.7 0.3]} [(+ w/2 3) (+ h/2 2)])
  (world.add state {:unit :barracks :colour [0.8 0 0.6]} [(+ w/2 1) (+ h/2 1)])
  (camera.position state [(+ w/2 5) (+ h/2 5)]))

(fn window-resize [w h]
  (set state.window {:w w :h h})
  (set state.canvas (love.graphics.newCanvas state.window.w state.window.h))
  (camera.window state))

(fn love.load []
  (window-resize (love.graphics.getWidth) (love.graphics.getHeight))
  (repl.start))

(fn love.draw []
  (love.graphics.setCanvas state.canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (: state.camera.main :draw
     (fn [l t w h]
       ;; TODO: only draw what is visible
       (draw.map state)
       (draw.entities state)))
  (when state.debug.draw-fps?
    (love.graphics.setColor [1 1 1])
    (love.graphics.print (tostring (love.timer.getFPS)) 10 10))
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw state.canvas 0 0 0 1 1))

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
  (world.move-entities state dt))

(fn love.resize [w h]
  (window-resize w h))

(fn love.keypressed [key]
  (if (or (= key "escape")
          (and (love.keyboard.isDown "lctrl" "rctrl" "capslock")
               (= key "q")))
      (love.event.quit)
      (= key "f11")
      (love.window.setFullscreen (not (love.window.getFullscreen)))))

(fn love.mousepressed [x y button]
  (if (= button 1)
      (let [[wx wy] [(: state.camera.main :toWorld x y)]
            selected (: state.world.physics :queryRect (- wx 0.2) (- wy 0.2) 0.4 0.4)]
        (set state.selection (-> selected
                                 (lume.filter :id) ;; remove non id-ed "rects" i.e. world edges
                                 (lume.reduce (fn [a e] (tset a e.id true) a) {}))))))

;; TODO: handle click & drag selection
;; (fn love.mousereleased [x y button]
;;   (if (= button 1) left-click-release
;;       (= button 2) right-click-release))
