(local utils {})

(fn utils.random-string [n]
  (var s "")
  (for [i 1 n]
    (set s (.. s (string.char (lume.random 97 122)))))
  s)

(fn utils.euclidean
  [[x1 y1] [x2 y2]]
  (let [dx (- x2 x1)
        dy (- y2 y1)]
    (+ (* dx dx) (* dy dy))))

(fn utils.hash
  [[x y]]
  (.. x "-" y))

utils
