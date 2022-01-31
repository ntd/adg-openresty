local lgi   = require 'lgi'
local cairo = lgi.require 'cairo'
local Adg   = lgi.require 'Adg'

local app = {}
local args = ngx.req.get_uri_args()

local function DATA()
    local fallbacks = {
        width   = 800,
        height  = 600,
        A       = 55,
        B       = 20.6,
        C       = 2,
        DHOLE   = 2,
        LHOLE   = 3,
        D1      = 9.3,
        D2      = 6.5,
        D3      = 13.8,
        D4      = 6.5,
        D5      = 4.5,
        D6      = 7.2,
        D7      = 2,
        RD34    = 1,
        RD56    = 0.2,
        LD2     = 7,
        LD3     = 3.5,
        LD5     = 5,
        LD6     = 1,
        LD7     = 0.5,
        GROOVE  = false,
        ZGROOVE = 16,
        DGROOVE = 8.3,
        LGROOVE = 1,
        CHAMFER = 0.3,
        TITLE   = 'SAMPLE DRAWING',
        DRAWING = 'PISTON',
        AUTHOR  = 'adg-openresty',
        DATE    = os.date('%d/%m/%Y'),
    }
    local data = {}
    for k in pairs(fallbacks) do
        data[k] = args[k] or fallbacks[k]
    end
    return data
end

local function CANVAS(data)
    local canvas = Adg.Canvas {}
    canvas:set_size_explicit(800, 600)
    canvas:set_margins(10, 10, 10, 10)
    canvas:set_paddings(0, 0, 0, 0)

    canvas:set_title_block(Adg.TitleBlock {
            title      = data.TITLE,
            author     = data.AUTHOR,
            date       = data.DATE,
            drawing    = data.DRAWING,
            logo       = Adg.Logo {},
            projection = Adg.Projection { scheme = Adg.ProjectionScheme.FIRST_ANGLE },
            size       = 'A4',
        })

    return canvas
end

local function MODEL(data)
    return nil
end


local function VIEW(model)
    return Adg.Text.new('This is a text string')
end


function app.log()
    ngx.say('ENVIRONMENT:')
    ngx.say('  GI_TYPELIB_PATH: "', os.getenv('GI_TYPELIB_PATH'), '"')
    ngx.say('  LD_LIBRARY_PATH: "', os.getenv('LD_LIBRARY_PATH'), '"')
    ngx.say('  XDG_DATA_DIRS: "', os.getenv('XDG_DATA_DIRS'), '"')

    ngx.say('REQUEST:')
    ngx.say('  URI: "', ngx.var.uri, '"')

    ngx.say('  HEADERS:')
    for k,v in pairs(ngx.req.get_headers()) do
        ngx.say('    ', k, ': "', v, '"')
    end

    ngx.say('  ARGUMENTS:')
    for k,v in pairs(args) do
        ngx.say('    ', k, ': "', v, '"')
    end

    ngx.say('\nDATA:')
    for k,v in pairs(DATA()) do
        ngx.say('  ', k, ': "', v, '"')
    end
end


function app.png()
    ngx.header.content_type = 'image/png';

    local data   = DATA()
    local model  = MODEL(data)
    local canvas = CANVAS(data)

    canvas:add(VIEW(model))
    canvas:autoscale()

    local contents, err = canvas:export_data(cairo.SurfaceType.IMAGE)
    if err then error(err) end
    ngx.print(contents)
end


-- Call the proper code depending on the extension (log, png, pdf, ...)
local extension = ngx.var.uri:match('[^.]*$')
local handler = app[extension]
if handler then
    handler()
else
    ngx.header.content_type = 'text/plain';
    ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say('Unrecognized extension (', extension, ')')
end
