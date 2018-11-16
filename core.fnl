(local repl (require "lib.repl"))
(local units (require "units"))
(local draw (require "draw"))
(local world (require "world"))
(local camera (require "camera"))

;; global for use at repl
(global state
  (let [world (world.new 20 10)]
    {:world world
     :camera {:main (camera.new world)}
     :entities {} ;; entity-id -> entity
     :selection {} ;; entity-id -> true (i.e. a set)
     :hud {:w 400}
     :debug {:draw-bounding-box? false
             :draw-fps? false}}))

(let [w/2 (/ state.world.w 2)
      h/2 (/ state.world.h 2)]
  (world.add state {:unit :dragster :colour [0.8 0 0.6] :commands [] :heading 0 :speed 0} [(+ w/2 4) (+ h/2 4)])
  (world.add state {:unit :tank     :colour [0 0.7 0.3] :commands [] :heading 0 :speed 0} [(+ w/2 5) (+ h/2 4)])
  (world.add state {:unit :factory  :colour [0 0.7 0.3]} [(+ w/2 3) (+ h/2 2)])
  (world.add state {:unit :barracks :colour [0.8 0 0.6]} [(+ w/2 1) (+ h/2 1)]))

(fn window-resize [state w h]
  (set state.window {:w w :h h})
  (draw.resize state)
  (camera.window state))

;; required for dynamic reloading of fennel modules
(window-resize state (love.graphics.getWidth) (love.graphics.getHeight))

(fn love.load []
  (repl.start))

(fn love.draw []
  (draw.draw state))

(fn update-entities [state]
  (-> state.entities
      (lume.filter (fn [e] (and e.commands
                                (> (lume.count e.commands) 0))))
      (lume.map (fn [entity]
                  (let [[px py] (lume.first entity.commands)
                        unit (. units entity.unit)
                        [uw uh] unit.size
                        (rx ry) (: state.world.physics :getRect entity)
                        [ex ey] [(+ rx (/ uw 2)) (+ ry (/ uh 2))]
                        [dx dy] [(- px ex) (- py ey)]]
                    (if (< (+ (* dx dx) (* dy dy)) 0.05)
                        (do (table.remove entity.commands 1)
                            (set entity.heading nil)
                            (set entity.speed nil))
                        (do (set entity.heading (math.atan2 dy dx))
                            (set entity.speed unit.speed))))))))

(fn love.update [dt]
  (if (love.keyboard.isDown "=")     (camera.zoom state dt :in)
      (love.keyboard.isDown "-")     (camera.zoom state dt :out))
  (if (love.keyboard.isDown "up")    (camera.move state dt :up)
      (love.keyboard.isDown "down")  (camera.move state dt :down))
  (if (love.keyboard.isDown "left")  (camera.move state dt :left)
      (love.keyboard.isDown "right") (camera.move state dt :right))
  (update-entities state)
  (world.move-entities state dt))

(fn love.resize [w h]
  (window-resize state w h))

(fn love.keypressed [key]
  (if (or (= key "escape")
          (and (love.keyboard.isDown "lctrl" "rctrl" "capslock")
               (= key "q")))
      (love.event.quit)
      (= key "f11")
      (love.window.setFullscreen (not (love.window.getFullscreen)))))

(fn entity-action [state pt shift?]
  ;; TODO: choose action depending on what is at pt
  (lume.map (lume.keys state.selection)
            (fn [entity-id]
              (let [entity (. state.entities entity-id)
                    unit (. units entity.unit)]
                (when (= unit.category :vehicle)
                  (if shift?
                      (table.insert entity.commands pt)
                      (set entity.commands [pt])))))))

(fn mouse-pressed [state button wx wy]
  (let [near-by (: state.world.physics :queryRect (- wx 0.2) (- wy 0.2) 0.4 0.4)
        selection (-> near-by
                      (lume.filter :id) ;; remove non id-ed "rects" i.e. world edges
                      (lume.map :id))
        old-n (lume.count state.selection)
        new-n (lume.count selection)
        shift? (love.keyboard.isDown "lshift" "rshift")]
    (if (and (not (= old-n 0))
             (= new-n 0))
        (entity-action state [wx wy] shift?)
        (and shift?
             (= new-n 1)
             (. state.selection (. selection 1)))
        (tset state.selection (. selection 1) nil)
        shift?
        (lume.map selection (fn [id] (tset state.selection id true)))
        :else
        (set state.selection (lume.reduce selection (fn [a id] (tset a id true) a) {})))))

(fn love.mousepressed [x y button]
  (if (= button 1)
      (let [[wx wy] [(: state.camera.main :toWorld x y)]]
        (mouse-pressed state button wx wy))
      (= button 2)
      (set state.selection {})))

;; TODO: handle click & drag selection
;; (fn love.mousereleased [x y button]
;;   (if (= button 1) left-click-release
;;       (= button 2) right-click-release))
