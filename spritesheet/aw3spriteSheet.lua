--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:ef76cea692ab98b529fcb0be9c06c702:ac08980661ce8f525f0b745d576d94ba:0a630aae80390403ac71cd20ea8e4bc5$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {

        {
            --1 AW_atkLeft2
            x=1,
            y=1,
            width=135,
            height=102,

        },
        {
            --2 AW_atkRight2
            x=1,
            y=105,
            width=135,
            height=102,

        },
        {
            --3 AW_dmgLeft
            x=1,
            y=841,
            width=68,
            height=171,

        },
        {
            --4 AW_dmgRight
            x=71,
            y=841,
            width=68,
            height=171,

        },
        {
            --5 AW_jumpingLeftt1
            x=141,
            y=769,
            width=104,
            height=96,

        },
        {
            --6 AW_jumpingLeftt2
            x=138,
            y=1,
            width=113,
            height=157,

        },
        {
            --7 AW_jumpingRight1
            x=141,
            y=867,
            width=104,
            height=96,

        },
        {
            --8 AW_jumpingRight2
            x=138,
            y=160,
            width=113,
            height=157,

        },
        {
            --9 AW_RunningLeft1
            x=122,
            y=663,
            width=119,
            height=104,

        },
        {
            --10 AW_RunningLeft2
            x=124,
            y=548,
            width=119,
            height=113,

        },
        {
            --11 AW_RunningLeft3
            x=1,
            y=438,
            width=121,
            height=89,

        },
        {
            --12 AW_RunningLeft4
            x=1,
            y=209,
            width=122,
            height=109,

        },
        {
            --13 AW_RunningRight1
            x=1,
            y=735,
            width=119,
            height=104,

        },
        {
            --14 AW_RunningRight2
            x=1,
            y=620,
            width=119,
            height=113,

        },
        {
            --15 AW_RunningRight3
            x=1,
            y=529,
            width=121,
            height=89,

        },
        {
            --16 AW_RunningRight4
            x=125,
            y=319,
            width=122,
            height=109,

        },
        {
            --17 AW_staticLeft
            x=1,
            y=320,
            width=121,
            height=116,

        },
        {
            --18 AW_staticRight
            x=124,
            y=430,
            width=121,
            height=116,

        },
    },

    sheetContentWidth = 252,
    sheetContentHeight = 1013
}

SheetInfo.frameIndex =
{

    ["AW_atkLeft2"] = 1,
    ["AW_atkRight2"] = 2,
    ["AW_dmgLeft"] = 3,
    ["AW_dmgRight"] = 4,
    ["AW_jumpingLeftt1"] = 5,
    ["AW_jumpingLeftt2"] = 6,
    ["AW_jumpingRight1"] = 7,
    ["AW_jumpingRight2"] = 8,
    ["AW_RunningLeft1"] = 9,
    ["AW_RunningLeft2"] = 10,
    ["AW_RunningLeft3"] = 11,
    ["AW_RunningLeft4"] = 12,
    ["AW_RunningRight1"] = 13,
    ["AW_RunningRight2"] = 14,
    ["AW_RunningRight3"] = 15,
    ["AW_RunningRight4"] = 16,
    ["AW_staticLeft"] = 17,
    ["AW_staticRight"] = 18,
}

function SheetInfo:getSheet()
    return SheetInfo.sheet;
end

function SheetInfo:getFrameIndex(name)
    return SheetInfo.frameIndex[name];
end

return SheetInfo
