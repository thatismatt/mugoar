(local utils {})

(fn utils.random-string [n]
  (var s "")
  (for [i 1 n]
    (set s (.. s (string.char (lume.random 97 122)))))
  s)

utils
