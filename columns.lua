---------------------------------------------------------------------------
-- @author James Wilmot &lt;djameswilmot2000@gmail.com&gt;
-- @copyright 2014 James Wilmot
---------------------------------------------------------------------------

local ipairs = ipairs
local client = require("awful.client")
local math = math
local naughty = require("naughty")
local beautiful = require("beautiful")
--local write = io.stderr:write
local io = io

module("awful.layout.suit.columns")

-- stuff for debugging

function dbg(vars)
    local text = ""
    for i=1, #vars do text = text .. vars[i] .. " | " end
    naughty.notify({ text = text, timeout = 5 })
end

function log_dbg_heading(heading)
    io.stderr:write("\n".."*** "..heading.." ***".."\n")
end
function log_dbg_var(msg, var, tabs)
    local text = ""
    for i=1, tabs do text = "\t"..text end 
    text = text..msg.." : "..var.."\n"
    io.stderr:write(text)
end

function log_dbg_message(msg, tabs)
    local text = ""
    for i=1, tabs do text = "\t"..text end 
    text = text..msg.."\n"
    io.stderr:write(text)
end

local function cols_arrange(p, cols)
    -- globals for geometry strings 
    x = "x"
    y = "y"
    height = "height"
    width = "width"

    -- screen context:
    -- number of clients, clients,
    -- screen work area 
    local wa = p.workarea
    local cls = p.clients
    local n = #cls

    -- for few clients
    -- want to make best use of 
    -- screen real estate
    -- number of cols is then number of clients 
    if n <= cols then
        cols = n
    end 

    -- column book keeping
    -- how many clients per column
    -- how many clients that have been
    -- arranged in columns 
    local n_cls_col = 0 
    local cls_arranged = 0
    local col_cls = {} 
    local col_geom = {}

    col_geom[width] = math.ceil(wa[width]/cols) - ( cols * beautiful.border_width )
    col_geom[height] = wa[height]
    col_geom[x] = wa[x] 
    col_geom[y] = wa[y]  

    --notify("test issue")

    n_cls_col = math.floor(n/cols)
    local start = 1
    local finish = n_cls_col
    local cls_arranged = 0
    local cls_not_arranged = 0

    -- iterate over columns
    -- arranging each column 
    for col=1,cols,1 do
        -- get clients for column
        cols_cls = table_slice(cls,start,finish)  

        -- arrange single column
        arrange_column(cols_cls, col_geom)

        -- move x over for new column
        col_geom[x] = col_geom[x] + col_geom[width]
 
        -- tally clients arranged
        -- determine clients not arranged
        cls_arranged = n_cls_col + cls_arranged  
        cls_not_arranged = n - cls_arranged 
 
        -- algorithm for next column
        local cols_left = cols - col
        local spare_cls = cls_not_arranged - cols_left*n_cls_col   
        if spare_cls == cols_left then
            n_cls_col = n_cls_col + 1
        end
        
        -- increment indices
        start = finish + 1
        finish = finish + n_cls_col
    end
end

function arrange_column(clients, col_geom) 
    local geom = {}
    local n = #clients

    -- all clients in a column:
    -- same width and x position
    geom[width] = col_geom[width]
    geom[x] = col_geom[x]

    -- each client in column
    -- is same height
    geom[height] = math.floor(col_geom[height]/n)
    geom[y] = col_geom[y]

    for k, c in ipairs(clients) do
        c:geometry(geom)
        --http://tychoish.com/rhizome/window-sizes-in-tiling-window-managers/
        c.size_hints_honor = false  
        geom[y] = geom[height] + geom[y]  
    end
end

-- given a table: values
-- return subtable between
-- indices start and finish
--
-- Source: http://snippets.luacode.org/?p=snippets/Table_Slice_116
function table_slice(values, start, finish)
    local res = {}
    local n = #values
    
    -- default values for range
    start = start or 1
    finish = finish or n
    if finish < 0 then
        finish = n + finish + 1
    elseif finish > n then
        finish = n
    end
    if start < 1 or start > n then
        return {}
    end
    local k = 1
    for i = start,finish do
        res[k] = values[i]
        k = k + 1
    end
    return res
end

two = {}
two.name = "twocols"

function two.arrange(p)
    return cols_arrange(p, 2) 
end

three = {}
three.name = "threecols"

function three.arrange(p)
    return cols_arrange(p, 3) 
end
