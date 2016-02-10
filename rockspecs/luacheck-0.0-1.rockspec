package = "LuaCheck"
version = "0.0-1"
source = {
    url = "https://github.com/Primordus/LuaCheck.git"
}
description = {
    summary = "QuickCheck for Lua",
    detailed = [[
       Quickcheck for Lua: use the power of property based testing to
       test your code more thoroughly! 
       
       "Dont't write tests.. generate them!" - John Hughes
    ]],
    homepage = "https://github.com/Primordus/LuaCheck.git",
    license = "MIT"
}
dependencies = {
    "lua ~> 5.1"
}
build = {
    type = "builtin",
    modules = {
        random = "src/random.lua"
        -- TODO add other modules!
    }
}
