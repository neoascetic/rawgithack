local json = require "cjson"

local cfg = require "config"
local url = 'https://api.cloudflare.com/client/v4/zones/' .. cfg.cf.zone .. '/purge_cache'


local function post(url, data, headers)
   return ngx.location.capture(
      '/proxy',
      {
         ctx = {headers = headers},
         vars = {_url = url},
         method = ngx.HTTP_POST,
         body = data
      })
end


local function error(desc)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.say(json.encode({success = false, response = desc}))
   ngx.exit(ngx.status)
end


local function get_files()
   local args, err = ngx.req.get_post_args()

   if err == "truncated" then error("truncated request") end
   if not args.files then error("wrong number of URLs") end

   local files, invalid_files = {}, {}
   for l in args.files:gmatch('[^\r\n]+') do
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
   local res = post(url, json.encode({files = files}), headers)
   if res.status == 200 then
      ngx.say(json.encode({success = true, response = 'cache was successfully invalidated!'}))
   else
      ngx.log(ngx.ERR, "CDN purge cache error: " .. res.body)
      error("cdn response error")
   end
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
   local files = get_files()
   ngx.log(ngx.WARN, "got a request to purge #" .. #files .. " files")
   local_purge(files) 
   cdn_purge(files)
end


local function patch_proxy()
   local req = ngx.req
   for k,v in pairs(req.get_headers()) do
      if k ~= 'content-length' then
         req.clear_header(k)
      end
   end
   if ngx.ctx.headers then
      for k,v in pairs(ngx.ctx.headers) do
         req.set_header(k, v)
      end
   end
end


return {
   purge_request = purge_request,
   patch_proxy = patch_proxy
}
