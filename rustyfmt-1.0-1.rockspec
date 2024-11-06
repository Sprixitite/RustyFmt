---@diagnostic disable: lowercase-global
package = "RustyFmt"
version = "1.0-1"
source = {
    url = "git://github.com/Sprixitite/RustyFmt",
    tag = "v1.0"
}
description = {
    summary = "Dependency free, Rust-esque string formatting function.",
    
}
dependencies = {
    "lua >= 5.1, <= 5.4"
}
build = {
    type = "builtin",
    modules = {
        RustyFmt = "src/rustyFmt.lua"
    }
}