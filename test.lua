local failed = 0
local function testErr(msg)
    io.stderr:write(msg .. "\n")
    io.stderr:flush()
end

local function failTestErr() end

local RustyFmt = require("rustyFmt"):WithConfig{ error = testErr }
local FailTestRustyFmt = RustyFmt:WithConfig{ error = failTestErr }

local function test(testname, result, expected)
    if result ~= expected then
        print("Test \"" .. testname .. "\" failed!\nExpected: " .. expected .. "\nGot: " .. result)
        failed = failed + 1
    else
        print("Test \"" .. testname .. "\" passed!")
    end
end

local function testForFail(testname, func)
    local success = pcall(func)
    if success == true then
        print("Test \"" .. testname .. "\" failed!")
        failed = failed + 1 
    else
        print("Test \"" .. testname .. "\" passed!")
    end
end

testForFail("No arguments should fail", function()
    FailTestRustyFmt(nil)
end)

testForFail("Argument of wrong type should fail", function()
    FailTestRustyFmt(4736251)
end)

testForFail("Empty table should fail", function()
    FailTestRustyFmt{}
end)

testForFail("Invalid format string should fail", function()
    FailTestRustyFmt{true}
end)

testForFail("Nonexistent index should fail", function()
    FailTestRustyFmt{"Doomed {2} fail"}
end)

testForFail("Nonexistent key should fail", function()
    FailTestRustyFmt{"Doomed to {fail}"}
end)

test(
    "Implicit substitution indexes",
    RustyFmt { "I love {} but {} is better. {} is SO much better.", "Hotline Miami", "Hotline 2" },
    "I love Hotline Miami but Hotline 2 is better. Hotline 2 is SO much better."
)

test(
    "Explicit substitution indexes",
    RustyFmt { "How much {1} could a {2} chuck if a {2} could chuck {1}?", "wood", "Woodchuck" },
    "How much wood could a Woodchuck chuck if a Woodchuck could chuck wood?"
)

test(
    "Mixed substitution indexes",
    RustyFmt { "How much {1} could a {} chuck if a {2} could chuck {}?", "wood", "Woodchuck", "bamboo" },
    "How much wood could a Woodchuck chuck if a Woodchuck could chuck bamboo?"
)

test(
    "Keyed substitution",
    RustyFmt { "{albumOne} is my favourite album, but {albumThree} and {albumTwo} aren't half bad either!", albumOne = "Bad Witch", albumTwo = "Timeline", albumThree = "The Fragile" },
    "Bad Witch is my favourite album, but The Fragile and Timeline aren't half bad either!"
)

test(
    "Mixed substitution indexes + Keyed substitution",
    RustyFmt { "How much {1} could a {chucker} chuck if a {chucker} could chuck {}?", "wood", "granite", chucker = "Woodchuck" },
    "How much wood could a Woodchuck chuck if a Woodchuck could chuck granite?"
)

test(
    "Escaped curly braces",
    RustyFmt { "Lua Table: {{ myVar = \":3\", myOtherVar = 69 }}" },
    "Lua Table: { myVar = \":3\", myOtherVar = 69 }"
)

test(
    "Mixed substitution indexes + Keyed substitution within escaped curly braces", -- Insanity
    RustyFmt { "table: {{ {3} = {1}, {} = {putsMyMindAtEase} }}", "\"This is absurd\"", "bestNumber", "currentlyThinking", putsMyMindAtEase = 4736251 },
    "table: { currentlyThinking = \"This is absurd\", bestNumber = 4736251 }"
)

if failed == 0 then
    print("\nAll tests passed!")
else
    print("\n" .. failed .. " tests did not pass!")
end
os.exit(failed)