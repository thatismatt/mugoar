(local world (require "world"))

(local level {:name :units})

(fn level.init
  [state]
  (let [w/2 (/ state.world.w 2)
        h/2 (/ state.world.h 2)]
    (world.add state {:unit :dragster :colour [0 0.5 0.9] :commands [] :heading 0 :speed 0} [1 1])
    (world.add state {:unit :dragster :colour [0 0.5 0.9] :commands [] :heading 0 :speed 0} [3 3])
    (world.add state {:unit :dragster :colour [0.8 0 0.6] :commands [] :heading 0 :speed 0} [(+ w/2 4) (+ h/2 4)])
    (world.add state {:unit :tank     :colour [0 0.7 0.3] :commands [] :heading 0 :speed 0} [(+ w/2 5) (+ h/2 4)])
    (world.add state {:unit :factory  :colour [0 0.7 0.3]} [(+ w/2 3) (+ h/2 2)])
    (world.add state {:unit :barracks :colour [0.8 0 0.6]} [(+ w/2 1) (+ h/2 1)])))

level
