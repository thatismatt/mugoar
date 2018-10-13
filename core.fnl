(local repl (require "lib.repl"))
(local units (require "units"))
(local draw (require "draw"))

(local canvas (love.graphics.newCanvas 1024 768))

(fn love.load []
  (: canvas :setFilter "nearest" "nearest")
  (repl.start))

(fn love.draw []
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (draw.object units.dragster [0 1 0] [1 1])
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 1 1))

(fn love.update [dt]
  )

(fn love.keypressed [key]
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock")
           (= key "q"))
      (love.event.quit)))
