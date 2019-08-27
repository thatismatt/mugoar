(local repl (require "lib.repl"))
(local units (require "units"))
(local draw (require "draw"))
(local world (require "world"))
(local entity (require "entity"))
(local camera (require "camera"))
(local nav (require "nav"))
(local utils (require "utils"))

(local nav-debug (require "nav-debug"))

(local core {})

(fn core.window-resize [state w h]
  (set state.window {:w w :h h})
  (draw.resize state)
  (camera.window state))

(fn core.init
  [level]
  ;; global for use at repl
  (global state
          {:entities {} ;; entity-id -> entity
           :selection {} ;; entity-id -> true (i.e. a set)
           :hud {:w 400
                 :visible? false}
           :level level
           :debug {;; TODO :draw-bounding-shape?
                   :draw-fps? false
                   :overlay nav-debug}})
  (world.init state)
  (camera.init state)
  (nav.init state)
  (core.window-resize state (love.graphics.getWidth) (love.graphics.getHeight))
  (when state.level.init
    (state.level.init state))
  (when (and state.debug.overlay state.debug.overlay.init)
    (state.debug.overlay.init state)))

;; (core.init (require "level.units"))
(core.init (require "level.small"))

(fn love.load []
  (repl.start))

(fn love.draw []
  (draw.draw state))

(fn love.update [dt]
  (when (< dt (/ 1 30))
    (love.timer.sleep (- (/ 1 30) dt))) ;; crude 30fps limit
  (if (love.keyboard.isDown "=")     (camera.zoom state dt :in)
      (love.keyboard.isDown "-")     (camera.zoom state dt :out))
  (if (love.keyboard.isDown "up")    (camera.move state dt :up)
      (love.keyboard.isDown "down")  (camera.move state dt :down))
  (if (love.keyboard.isDown "left")  (camera.move state dt :left)
      (love.keyboard.isDown "right") (camera.move state dt :right))
  (entity.update-entities state)
  (entity.move-entities state dt))

(fn love.resize [w h]
  (core.window-resize state w h))

(fn love.keypressed [key]
  (if (or (= key "escape")
          (and (love.keyboard.isDown "lctrl" "rctrl" "capslock")
               (= key "q")))
      (love.event.quit)
      (= key "f11")
      (love.window.setFullscreen (not (love.window.getFullscreen)))))

(fn core.entity-action [state pt shift?]
  ;; TODO: choose action depending on what is at pt
  (lume.map (lume.keys state.selection)
            (fn [entity-id]
              (let [entity (. state.entities entity-id)
                    unit (. units entity.unit)]
                (when (= unit.category :vehicle)
                  (if shift?
                      (table.insert entity.commands pt)
                      (set entity.commands [pt])))))))

(fn core.mouse-pressed [state button wx wy]
  (let [outside? (or (< wx 0) (< wy 0)
                     (> wx state.world.w) (> wy state.world.h))
        selection (-> (world.query-point state wx wy 0.2)
                      (lume.map :id))
        old-n (lume.count state.selection)
        new-n (lume.count selection)
        shift? (love.keyboard.isDown "lshift" "rshift")]
    (if outside?
        nil
        (and (not (= old-n 0))
             (= new-n 0))
        (core.entity-action state [wx wy] shift?)
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
        (core.mouse-pressed state button wx wy))
      (= button 2)
      (set state.selection {})))

;; TODO: handle click & drag selection
;; (fn love.mousereleased [x y button]
;;   (if (= button 1) left-click-release
;;       (= button 2) right-click-release))

core
