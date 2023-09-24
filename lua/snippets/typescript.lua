---@diagnostic disable: undefined-global

local get_visual_stored = require("utils.snipFunc").get_visual_stored

return {
  s(
    {
      trig = "cl",
      desc = "Create Javascript console.log",
      priority = 2000,
    },
    fmt(
      [[
        console.log({});
      ]],
      { d(1, get_visual_stored) }
    )
  ),

  s(
    {
      trig = "js",
      desc = "Create jsdoc comment.",
      priority = 2000,
    },
    fmt(
      [[
        /**
         * {}
         */
      ]],
      {
        i(1),
      }
    )
  ),

  s(
    {
      trig = "af",
      desc = "Create Javascript arrow function.",
      priority = 2000,
    },
    fmta(
      [[
        const <> = <>(<>) =>> {
          <><>
        };
      ]],
      {
        i(1),
        i(4),
        i(2),
        i(3),
        i(0),
      }
    )
  ),

  s(
    {
      trig = "fu",
      desc = "Create Javascript function.",
      priority = 2000,
    },
    fmta(
      [[
        <>function <>(<>) {
          <><>
        }
      ]],
      {
        i(4),
        i(1),
        i(2),
        i(3),
        i(0),
      }
    )
  ),

  s(
    {
      trig = "im",
      desc = "Create ES6 import.",
      priority = 2000,
    },
    fmta(
      [[
        import { <> } from '<>';
      ]],
      {
        i(2),
        i(1),
      }
    )
  ),

  s(
    {
      trig = "ia",
      desc = "Create ES6 import as.",
      priority = 2000,
    },
    fmta(
      [[
        import <> as <> from '<>';
      ]],
      {
        i(2, "*"),
        i(3),
        i(1),
      }
    )
  ),

  s(
    {
      trig = "id",
      desc = "Create ES6 import default.",
      priority = 2000,
    },
    fmta(
      [[
        import <> from '<>';
      ]],
      {
        i(2),
        i(1),
      }
    )
  ),
}
