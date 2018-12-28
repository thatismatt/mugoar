(local nav (require "nav"))
(local draw (require "draw"))

(local nav-debug
       {:goal [2 3]
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
  (let [goal-hash (nav.hash nav-debug.goal)]
    (for [i 1 state.world.w]
      (for [j 1 state.world.h]
        (let [dist (-> state.nav.integration (. goal-hash) (. i) (. j))
              flow (-> state.nav.flow (. i) (. j))]
          (if (= dist math.huge)
              (do (love.graphics.setColor [0 0 1])
                  (draw.shape {:shape :polygon
                               :pts [[0.3 0.3] [0.3 0.7] [0.7 0.7] [0.7 0.3]]}
                              [(- i 1) (- j 1)]))
              flow
              (do (love.graphics.setColor [1 0 0 (/ dist 20)])
                  (draw.shape {:shape :polygon
                               :pts [[0.1 0.1] [0.1 0.9] [0.9 0.9] [0.9 0.1]]}
                              [(- i 1) (- j 1)])
                  (love.graphics.setColor [0 1 0 0.7])
                  (draw.shape {:shape :polygon
                               :pts (if (= dist 0)
                                        [[0.3 0.3] [0.3 0.7] [0.7 0.7] [0.7 0.3]]
                                        (. nav-debug.arrows flow))}
                              [(- i 1) (- j 1)]))))))))

nav-debug
