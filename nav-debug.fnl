(local nav (require "nav"))
(local draw (require "draw"))
(local utils (require "utils"))

(local nav-debug
       {:goal [13 8]
        :arrows {:N  [[0.4 0.8] [0.6 0.8] [0.5 0.2]]
                 :NE [[0.7 0.3] [0.4 0.8] [0.2 0.6]]
                 :E  [[0.2 0.4] [0.2 0.6] [0.8 0.5]]
                 :SE [[0.7 0.7] [0.4 0.2] [0.2 0.4]]
                 :S  [[0.4 0.2] [0.6 0.2] [0.5 0.8]]
                 :SW [[0.3 0.7] [0.6 0.2] [0.8 0.4]]
                 :W  [[0.8 0.4] [0.8 0.6] [0.2 0.5]]
                 :NW [[0.3 0.3] [0.6 0.8] [0.8 0.6]]}})

(fn nav-debug.init
  [state]
  (nav.run state nav-debug.goal))

(fn nav-debug.draw
  [state]
  (let [goal-hash (utils.hash nav-debug.goal)]
    (for [i 1 state.world.w]
      (for [j 1 state.world.h]
        (let [dist (-> state.nav.integration (. goal-hash) (. i) (. j))
              flow (-> state.nav.flow (. goal-hash) (. i) (. j))]
          (when flow
            (love.graphics.setColor [0 1 0 0.7])
            (draw.shape {:shape :polygon
                         :pts (if (= dist 0) ;; i.e. this is the destination
                                  [[0.3 0.3] [0.3 0.7] [0.7 0.7] [0.7 0.3]]
                                  (. nav-debug.arrows flow))}
                        [(- i 1) (- j 1)])))))))

nav-debug
