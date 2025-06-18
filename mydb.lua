--
-- Author: w.l.hikaru
-- Date: 2015-07-24 19:57:03
--
package.path=package.path .. ";/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/mobdebug/?.lua"
package.path=package.path .. ";/Users/wxg/Documents/serverSpace/4DaysORM-master/?.lua"
require('mobdebug').start()
DB = {
    DEBUG = true,
    new = true,
    backtrace = true,
    type = "mysql",
    name = "test",
    username = "mysql",
    password = "",
    host = "localhost",
    port = "3306"
}
luasql = require "luasql.mysql"
local Table = require("orm.model")
local fields = require("orm.tools.fields")
----------------------------- CREATE TABLE --------------------------------
local User = Table({
    __tablename__ = "user",
    memory = false,
    username = fields.CharField({max_length = 100, unique = true}),
    password = fields.CharField({max_length = 50, unique = true}),
    age = fields.IntegerField({max_length = 2, null = true}),
    job = fields.CharField({max_length = 50, null = true}),
    time_create = fields.DateTimeField({null = true})
})
----------------------------- CREATE DATA --------------------------------
user = User.get:where({id = 1}):first()
print("User id is: " .. user.username)
-- local user = User({
--     username = "Bob Smith",
--     time_create = os.time()
-- })
-- user:save()
print("User " .. user.username .. " has id " .. user.id)
-- luasql = require "luasql.mysql"
-- env = assert (luasql.mysql())
-- con = assert (env:connect("test", "mysql", "", "localhost", 3306)) 