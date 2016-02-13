package = 'lua-quickcheck'
version = '0.0-1'
source = {
    url = 'https://github.com/Primordus/lua-quickcheck.git'
}
description = {
    summary = 'QuickCheck for Lua',
    detailed = [[
       Quickcheck for Lua: use the power of property based testing to
       test your code more thoroughly! 
       
       'Dont't write tests.. generate them!' - John Hughes
    ]],
    homepage = 'https://github.com/Primordus/lua-quickcheck.git',
    license = 'MIT'
}
dependencies = {
    'lua ~> 5.1'
}
build = {
    type = 'builtin',
    modules = {
        random = 'src/random.lua'
        arg_parser = 'src/arg_parser.lua'
        -- TODO add other modules!
    }
}
