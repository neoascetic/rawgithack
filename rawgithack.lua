local json = require("cjson")
local http = require("resty.http")
local cfg = require("config")

local patrons = {}


local function dump_file(path, data)
   local file, err = io.open(path, "w")
   if err then return ngx.log(ngx.WARN, "File dumping error: " .. err) end
   file:write(data)
   file:close()
end


local function load_file(path)
   local file, err = io.open(path, "r")
   if err then return ngx.log(ngx.WARN, "File reading error: " .. err) end
   local data = file:read("*all")
   file:close()
   return data
end


local function refresh_patrons(_premature, cold_cache_path)
   local headers = {['Authorization'] = 'Bearer ' .. cfg.patreon.token}
   local next_page = table.concat({
     'https://www.patreon.com/api/oauth2/v2/campaigns',
     cfg.patreon.campaign,
     'members?fields%5Bmember%5D=email,patron_status'}, '/')
   local acc = {}
   while next_page ~= json.null do
     local res, err = http.new():request_uri(next_page, {headers=headers})
     if res and res.status ~= 200 then err = res.body end
     if err then return ngx.log(ngx.WARN, "Cannot refresh patrons list: " .. err) end
     local result = json.decode(res.body)
     for i = 1, #result['data'] do
         local user = result['data'][i]['attributes']
         if user['patron_status'] == 'active_patron' then
            acc[user['email']] = true
         end
     end
     next_page = result['meta']['pagination']['cursors']['next']
   end 
   patrons = acc
   dump_file(cold_cache_path, json.encode(acc))
end


local function init()
   local cold_cache_path = "/var/cache/nginx/rawgithack_patrons/patrons.json"
   ngx.timer.every(60, refresh_patrons, cold_cache_path)
   local cold_cache = load_file(cold_cache_path)
   if cold_cache ~= nil then patrons = json.decode(cold_cache) end
end


local function error(desc)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.say(json.encode({success = false, response = desc}))
   ngx.exit(ngx.status)
end


local function validate_files(raw_files)
   if not raw_files then error("wrong number of URLs") end

   local files, invalid_files = {}, {}
   for l in raw_files:gmatch('[^\r\n]+') do
      local url = l:gsub('^%s*(.*)%s*$', '%1') -- trailing whitespaces
      local valid = url:match('^https?://%w+cdn%.githack%.com')
      table.insert(valid and files or invalid_files, url)
   end

   if #invalid_files > 0 then error("invalid URLs: " .. table.concat(invalid_files, ', ')) end
   if #files < 1 or #files > 30 then error("wrong number of URLs") end

   return files
end


local function cdn_purge(files)
   local headers = {
      ['Content-Type'] = 'application/json',
      ['X-Auth-Email'] = cfg.cf.username,
      ['X-Auth-Key'] = cfg.cf.api_key
   }
   local purge_url = 'https://api.cloudflare.com/client/v4/zones/' .. cfg.cf.zone .. '/purge_cache'
   local params = {
       method='POST',
       headers=headers,
       body=json.encode({files=files})}
   local res = http.new():request_uri(purge_url, params)
   if res.status ~= 200 then
      ngx.log(ngx.ERR, "CDN response error: " .. res.body)
      return false
   end
   return true
end


local function url_to_cache_key(url)
   local map = {
      ['^https?://glcdn%.githack%.com'] = 'gitlab.com',
      ['^https?://bbcdn%.githack%.com'] = 'bitbucket.org',
      ['^https?://rawcdn%.githack%.com'] = 'raw.githubusercontent.com',
      ['^https?://gistcdn%.githack%.com'] = 'gist.githubusercontent.com',
      ['^https?://srhtcdn%.githack%.com'] = 'git.sr.ht',
      ['^https?://srhgtcdn%.githack%.com'] = 'hg.sr.ht'
   }
   for pattern, origin in pairs(map) do
      local cache_key, n = url:gsub(pattern, origin, 1)
      if n == 1 then return cache_key end
   end
end


local function local_purge(files)
   local dir = '/var/cache/nginx/rawgithack'
   local keys = {}
   for _, f in pairs(files) do
      keys[#keys] = ngx.md5(url_to_cache_key(f))
   end
   for _, key in pairs(keys) do
      -- TODO support arbitrary logic of cache path
      local path = table.concat({dir, key:sub(-1), key:sub(-3, -2), key}, '/')
      local _, err = os.remove(path)
      if err then
         ngx.log(ngx.WARN, "unable to remove cache file " .. path .. ", err:" .. err)
      end
   end
end


local function purge_request()
   local args, err = ngx.req.get_post_args()
   if err == "truncated" then error("truncated request") end

   if (not patrons[args.patron] and
       args.patron ~= cfg.simsim) then error("you are not our patron") end

   local files = validate_files(args.files)
   ngx.log(ngx.WARN, "got a request to purge #" .. #files .. " files")
   local_purge(files) 
   if not cdn_purge(files) then error("CDN response error") end
   ngx.say(json.encode({success = true, response = 'cache was successfully invalidated!'}))
end


return {
   init = init,
   purge_request = purge_request
}
