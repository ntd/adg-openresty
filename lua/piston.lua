local lgi = require 'lgi'
local Adg = lgi.require 'Adg'

ngx.say('-- URI parameters')
local h = ngx.req.get_uri_args()
for k, v in pairs(h) do
    ngx.say(k, ': ', v)
end

ngx.say('\n\n-- ADG API list')
for k, v in pairs(Adg:_resolve(true)) do
    -- Skip implementation details
    if k:sub(1, 1) ~= '_' then
        ngx.say(k, ': ', tostring(v))
    end
end
