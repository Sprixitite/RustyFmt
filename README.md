# RustyFmt
A zero-dependency rust-esque formatter for strings.  
Tested to be compatible with Lua 5.1 through 5.4

# Examples
## Basics
### Prerequesites
For all of the following examples, please assume that:
```lua
local rustyFmt = require "RustyFmt"
```
Is at the top of them. My fingers are already bleeding writing the rest of this out.

### Implicit substitution
Absolute basic use is as so:

```lua
-- Note the curly braces!!
-- Will print "Hello from RustyFmt!"
print( rustyFmt { "Hello from {}!", "RustyFmt" } )
```
<br>
When given more than one unnamed argument, the formatter will go through them in order, stopping at the final argument.

```lua
-- Will print "One, two, three, four, next comes... four? I might have forgot my count."
print(rustyFmt {
    "{}, {}, {}, {}, next comes... {}? I might have forgot my count.",
    "One",
    "two",
    "three",
    "four"
})
```
## Less-Basics
### Keyed Substitution
Okay, but what if we have 20 arguments and a string which reuses some, no problem! Arguments can be passed by name like so:
```lua
-- "I hate Bash, it sucks. I much prefer Lua. Seriously, don't get me started on Bash"
print(rustyFmt {
    "I hate {badLang}, it sucks. I much prefer {goodLang}. Seriously, don't get me started on {badLang}",
    badLang = "Bash",
    goodLang = "Lua",
})
```
### Escapes

I'm sure you're absolutely thrilled about this, but what if I want curly braces in my string?? Taking "inspiration" from Rust's `fmt!` and `println!`, "`{{`" and "`}}`" will do the trick!

```lua
-- "table: { bestNumber = 4736251 }
print(rustyFmt {
    "table: {{ {key} = {value} }}",
    key = "bestNumber",
    value = 4736251
})
```

# Notes
## Configuration
Calling "`rustyFmt:WithConfig{}`" will return an instance of `rustyFmt` with the given config.<br>
Valid config entries are as so:
- `error`, a function which handles any thrown errors.
- `tostring`, a function which handles the conversion of arguments to strings.

All config entries are optional, they default to whatever `_G.error` and `_G.tostring` were at require-time otherwise.

## Quirks
There are a few quirks I am aware of. The following behaviour is not to be relied on as they may be changed in a future version:

Single "`}`" characters are treated the same as "`}}`" outside of an active substitution, therefore both of the following will produce the same result:
```lua
-- Both the same
rustyFmt { "Look at my {} sideways parasol -} ", "cool" }
rustyFmt { "Look at my {} sideways parasol -}}", "cool" }
```

All "`{`" characters are accepted in substitution keys, so the following is valid:
```lua
-- This is regrettably valid
rustyFmt { "Hello enjoyer of {-{} keys!", ["-{"] = "weird" }
```

This is less of a quirk and more of a design decision, however for any key where `tonumber(key) ~= nil`, only the numeric index is checked, e.g:
```lua
rustyFmt { "I love {1.5} keys!", [1.5]   = "numeric" } -- This is valid
rustyFmt { "I love {1.5} keys!", ["1.5"] = "numeric" } -- This is invalid
```

Similarly, all curly braces within substitutions are invalid, excluding the aforementioned quirk with "`{`" characters.<br>
If any of these are a substantial problem, open an issue and I'll see if I can't do anything about it.