local pb = require "pb"
local lfs = require "lfs"
local currentdir = lfs.currentdir()
local skynet = require "skynet"
local serverdir = skynet.getenv("serverdir")
assert(pb.loadfile (currentdir .. "/" .. serverdir  .. "/src/proto/test.pb"))
assert(pb.loadfile (currentdir .. "/" .. serverdir .. "/src/proto/player.pb"))
