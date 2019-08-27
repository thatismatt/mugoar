(local world (require "world"))

(local level {:name :units
              :width 5
              :height 5})

(fn level.init
  [state]
  (world.add state {:unit :dragster :colour [0 0.5 0.9] :commands [] :heading 0 :speed 0} [1 1]))

level
