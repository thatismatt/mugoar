-- bootstrap fennel
fennel = require("lib.fennel")
table.insert(package.loaders, fennel.make_searcher({ correlate = true }))
pp = function (x) print(require("lib.fennelview")(x)) end
lume = require("lib.lume")
fu = require("lib.fu")

require("core")
