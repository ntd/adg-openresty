local lgi   = require 'lgi'
local cairo = lgi.require 'cairo'
local Cpml  = lgi.require 'Cpml'
local Adg   = lgi.require 'Adg'

local args  = ngx.req.get_uri_args()
local SQRT3 = math.sqrt(3)


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
        ZGROOVE = 16,
        DGROOVE = 8.3,
        LGROOVE = 1,
        CHAMFER = 0.3,
        TITLE   = 'Generated by adg-openresty',
        DRAWING = 'SAMPLE',
        AUTHOR  = 'piston.lua',
        DATE    = os.date('%d/%m/%Y'),
    }
    local data = {}
    for k in pairs(fallbacks) do
        data[k] = args[k] or fallbacks[k]
    end
    return data
end

local function MODELS(data)
    local models = {}
    local model, pair

    -- AXIS
    model = Adg.Path {}
    model:move_to_explicit(-1, 0)
    model:line_to_explicit(data.A + 1, 0)
    models.axis = model

    -- HOLE
    model = Adg.Path {}
    pair = Cpml.Pair { x = data.LHOLE, y = 0 }
    model:move_to(pair)
    model:set_named_pair('LHOLE', pair)
    pair.y = data.DHOLE / 2
    pair.x = pair.x - pair.y / SQRT3
    model:line_to(pair)
    model:set_named_pair('EHOLE', pair)
    pair.x = 0
    model:line_to(pair)
    model:set_named_pair('DHOLE', pair)
    model:line_to_explicit(0, (data.D1 + data.DHOLE) / 4)
    model:curve_to_explicit(data.LHOLE / 2, data.DHOLE / 2,
                            data.LHOLE + 2, data.D1 / 2,
                            data.LHOLE + 2, 0)
    model:reflect()
    model:join()
    model:close()
    -- No need to incomodate an AdgEdge model for two reasons:
    -- it is only a single line and it is always needed
    pair = model:get_named_pair('EHOLE')
    model:move_to(pair)
    pair.y = -pair.y
    model:line_to(pair)
    models.hole = model

    -- BODY
    model = Adg.Path {}
    pair = Cpml.Pair { x = 0, y = data.D1 / 2 }
    model:move_to(pair)
    model:set_named_pair('D1I', pair)
    if data.DGROOVE and data.LGROOVE and data.ZGROOVE then
        pair = Cpml.Pair { x = data.ZGROOVE, y = data.D1 / 2 }
        model:line_to(pair)
        model:set_named_pair('DGROOVEI_X', pair)
        pair.y = data.D3 / 2
        model:set_named_pair('DGROOVEY_POS', pair)
        pair.y = data.DGROOVE / 2
        model:line_to(pair)
        model:set_named_pair('DGROOVEI_Y', pair)
        pair.x = pair.x + data.LGROOVE
        model:line_to(pair)
        pair.y = data.D3 / 2
        model:set_named_pair('DGROOVEX_POS', pair)
        pair.y = data.D1 / 2
        model:line_to(pair)
        model:set_named_pair('DGROOVEF_X', pair)
    end
    pair.x = data.A - data.B - data.LD2
    model:set_named_pair('D1F', pair)
    model:line_to(pair)
    pair.y = data.D3 / 2
    model:set_named_pair('D2_POS', pair)
    pair.x = pair.x + (data.D1 - data.D2) / 2
    pair.y = data.D2 / 2
    model:line_to(pair)
    model:set_named_pair('D2I', pair)
    pair.x = data.A - data.B
    model:line_to(pair)
    model:fillet(0.4)
    pair.x = data.A - data.B
    pair.y = data.D3 / 2
    model:line_to(pair)
    model:set_named_pair('D3I', pair)
    pair.x = data.A
    model:set_named_pair('East', pair)
    pair.x = 0
    model:set_named_pair('West', pair)
    model:chamfer(data.CHAMFER, data.CHAMFER)
    pair.x = data.A - data.B + data.LD3
    pair.y = data.D3 / 2
    model:line_to(pair)
    local primitive = model:over_primitive()
    local tmp = primitive:put_point(0)
    model:set_named_pair('D3I_X', tmp)
    tmp = primitive:put_point(-1)
    model:set_named_pair('D3I_Y', tmp)
    model:chamfer(data.CHAMFER, data.CHAMFER)
    pair.y = data.D4 / 2
    model:line_to(pair)
    primitive = model:over_primitive()
    tmp = primitive:put_point(0)
    model:set_named_pair('D3F_Y', tmp)
    tmp = primitive:put_point(-1)
    model:set_named_pair('D3F_X', tmp)
    model:fillet(data.RD34)
    pair.x = pair.x + data.RD34
    model:set_named_pair('D4I', pair)
    pair.x = data.A - data.C - data.LD5
    model:line_to(pair)
    model:set_named_pair('D4F', pair)
    pair.y = data.D3 / 2
    model:set_named_pair('D4_POS', pair)
    primitive = model:over_primitive()
    tmp = primitive:put_point(0)
    tmp.x = tmp.x + data.RD34
    model:set_named_pair('RD34', tmp)
    tmp.x = tmp.x - math.cos(math.pi / 4) * data.RD34
    tmp.y = tmp.y - math.sin(math.pi / 4) * data.RD34
    model:set_named_pair('RD34_R', tmp)
    tmp.x = tmp.x + data.RD34
    tmp.y = tmp.y + data.RD34
    model:set_named_pair('RD34_XY', tmp)
    pair.x = pair.x + (data.D4 - data.D5) / 2
    pair.y = data.D5 / 2
    model:line_to(pair)
    model:set_named_pair('D5I', pair)
    pair.x = data.A - data.C
    model:line_to(pair)
    model:fillet(0.2)
    pair.y = data.D6 / 2
    model:line_to(pair)
    primitive = model:over_primitive()
    tmp = primitive:put_point(0)
    model:set_named_pair('D5F', tmp)
    model:fillet(0.1)
    pair.x = pair.x + data.LD6
    model:line_to(pair)
    model:set_named_pair('D6F', pair)
    primitive = model:over_primitive()
    tmp = primitive:put_point(0)
    model:set_named_pair('D6I_X', tmp)
    primitive = model:over_primitive()
    tmp = primitive:put_point(-1)
    model:set_named_pair('D6I_Y', tmp)
    pair.x = data.A - data.LD7
    pair.y = pair.y - (data.C - data.LD7 - data.LD6) / SQRT3
    model:line_to(pair)
    model:set_named_pair('D67', pair)
    pair.y = data.D7 / 2
    model:line_to(pair)
    pair.x = data.A
    model:line_to(pair)
    model:set_named_pair('D7F', pair)
    model:reflect()
    model:join()
    model:close()
    models.body = model

    -- BODY EDGES
    models.edges = Adg.Edges { source = models.body }

    return models
end

local function CANVAS(data)
    local canvas = Adg.Canvas {}
    canvas:set_size_explicit(1123, 794)
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

local function VIEW(canvas, models)
    canvas:add(Adg.Stroke { trail = models.body })
    canvas:add(Adg.Stroke { trail = models.edges })
    canvas:add(Adg.Hatch  { trail = models.hole })
    canvas:add(Adg.Stroke { trail = models.hole })
    canvas:add(Adg.Stroke {
        trail = models.axis,
        line_dress = Adg.Dress.LINE_AXIS
    })

    local dim
    local body = models.body
    local hole = models.hole

    -- ADD NORTH DIMENSIONS
    dim = Adg.LDim.new_full_from_model(body, '-D3I_X', '-D3F_X', '-D3F_Y', -math.pi/2)
    dim:set_outside(Adg.ThreeState.OFF)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, '-D6I_X', '-D67', '-East', -math.pi/2)
    dim:set_level(0)
    dim:switch_extension1(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, '-D6I_X', '-D7F', '-East', -math.pi/2)
    dim:set_limits('-0.06', nil)
    canvas:add(dim)

    dim = Adg.ADim.new_full_from_model(body, '-D6I_Y', '-D6F', '-D6F', '-D67', '-D6F')
    dim:set_level(2)
    canvas:add(dim)

    dim = Adg.RDim.new_full_from_model(body, '-RD34', '-RD34_R', '-RD34_XY')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, '-DGROOVEI_X', '-DGROOVEF_X', '-DGROOVEX_POS', -math.pi/2)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D2I', '-D2I', '-D2_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'DGROOVEI_Y', '-DGROOVEI_Y', '-DGROOVEY_POS', math.pi)
    dim:set_limits('-0.1', nil)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)

    -- ADD SOUTH DIMENSIONS
    dim = Adg.ADim.new_full_from_model(body, 'D1F', 'D1I', 'D2I', 'D1F', 'D1F')
    dim:set_level(2)
    dim:switch_extension2(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', nil, 'West', math.pi / 2)
    dim:set_ref2_from_model(hole, '-LHOLE')
    dim:switch_extension1(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', 'DGROOVEI_X', 'West', math.pi / 2)
    dim:switch_extension1(false)
    dim:set_level(2)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D4F', 'D6I_X', 'D4_POS', math.pi / 2)
    dim:set_limits(nil, '+0.2')
    dim:set_outside(Adg.ThreeState.OFF)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1F', 'D3I_X', 'D2_POS', math.pi / 2)
    dim:set_level(2)
    dim:switch_extension2(false)
    dim:set_outside(Adg.ThreeState.OFF)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D3I_X', 'D7F', 'East', math.pi / 2)
    dim:set_limits(nil, '+0.1')
    dim:set_level(2)
    dim:set_outside(Adg.ThreeState.OFF)
    dim:switch_extension2(false)
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', 'D7F', 'D3F_Y', math.pi / 2)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(3)
    canvas:add(dim)

    dim = Adg.ADim.new_full_from_model(body, 'D4F', 'D4I', 'D5I', 'D4F', 'D4F')
    dim:set_level(1.5)
    dim:switch_extension2(false)
    canvas:add(dim)

    -- ADD EAST DIMENSIONS
    dim = Adg.LDim.new_full_from_model(body, 'D6F', '-D6F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(4)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D4F', '-D4F', 'East', 0)
    dim:set_level(3)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D5F', '-D5F', 'East', 0)
    dim:set_limits('-0.1', nil)
    dim:set_level(2)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D7F', '-D7F', 'East', 0)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)


    -- ADD WEST DIMENSIONS
    dim = Adg.LDim.new_full_from_model(hole, 'DHOLE', '-DHOLE', nil, math.pi)
    dim:set_pos_from_model(body, '-West')
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D1I', '-D1I', '-West', math.pi)
    dim:set_limits('-0.05', '+0.05')
    dim:set_level(2)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)

    dim = Adg.LDim.new_full_from_model(body, 'D3I_Y', '-D3I_Y', '-West', math.pi)
    dim:set_limits('-0.25', nil)
    dim:set_level(3)
    dim:set_value(Adg.UTF8_DIAMETER .. '<>')
    canvas:add(dim)
end


local function log()
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

local function draw(mime, format)
    ngx.header.content_type = mime

    local data   = DATA()
    local models = MODELS(data)
    local canvas = CANVAS(data)

    VIEW(canvas, models)
    canvas:autoscale()

    local contents, err = canvas:export_data(format)
    if err then error(err) end
    ngx.print(contents)
end


local handlers = {
    log = log,
    png = function () draw('image/png', cairo.SurfaceType.IMAGE) end,
    svg = function () draw('image/svg+xml', cairo.SurfaceType.SVG) end,
    pdf = function () draw('application/pdf', cairo.SurfaceType.PDF) end,
    ps  = function () draw('application/postscript', cairo.SurfaceType.PS) end,
}

-- Call the proper handler depending on the extension (log, png, pdf, ...)
local extension = ngx.var.uri:match('[^.]*$')
local handler   = handlers[extension]
if handler then
    handler()
else
    ngx.header.content_type = 'text/plain';
    ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say('Unrecognized extension (', extension, ')')
end
