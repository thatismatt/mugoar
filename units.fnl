(local units {})

(set units.dragster
     {:category :vehicle
      :speed 10
      :shapes [{:shape :polygon
                :pts [[1 0.25] [0 0.7] [0.6 0.7]]}
               {:shape :polygon
                :pts [[0.1 0.7] [0.3 0.75] [0.2 0.7]]}
               {:shape :ellipse
                :c [0.84 0.62] :r 0.13}]
      :size 1})

(set units.tank
     {:category :vehicle
      :speed 1
      :shapes [{:shape :polygon
                :pts [[0.1 0.2] [1 0.2] [0.9 0.6] [0 0.6]]}
               {:shape :ellipse
                :c [0.2 0.62] :r 0.13}
               {:shape :ellipse
                :c [0.7 0.62] :r 0.13}]
      :size 1})

(set units.factory
     {:category :building
      :shapes [{:shape :polygon ;; base
                :pts [[0.0 0.8] [2.0 0.8] [2.0 1.6] [0.0 1.6]]}
               {:shape :polygon ;; left roof
                :pts [[0.0 0.8] [0.0 0.4] [0.66 0.8]]}
               {:shape :polygon ;; middle roof
                :pts [[0.66 0.8] [1.33 0.8] [0.66 0.4]]}
               {:shape :polygon ;; right roof
                :pts [[1.33 0.8] [2.0 0.8] [1.33 0.4]]}]
      :size 2})

(set units.barracks
     {:category :building
      :shapes [{:shape :polygon ;; base
                :pts [[0.0 0.5] [1.0 0.5] [1.0 0.9] [0.0 0.9]]}
               {:shape :polygon ;; roof
                :pts [[0.0 0.5] [0.3 0.2] [0.7 0.2] [1.0 0.5]]}]
      :size 1})

(fn units.category? [entity category]
  (let [unit (. units entity.unit)]
    (= unit.category category)))

(fn units.building? [entity]
  (units.category? entity :building))

(fn units.vehicle? [entity]
  (units.category? entity :vehicle))

units
