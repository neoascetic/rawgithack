local json = require("cjson.safe")
local http = require("resty.http")
local cfg = require("config")


local function error(desc)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.say(json.encode({success = false, response = desc}))
   ngx.exit(ngx.status)
end


local domain_to_origin = {
   ['gl'] = 'gitlab.com',
   ['bb'] = 'bitbucket.org',
   ['raw'] = 'raw.githubusercontent.com',
   ['gist'] = 'gist.githubusercontent.com',
   ['gt'] = 'gitea.com',
   ['cb'] = 'codeberg.org'
}


local function validate_files(raw_files)
   if type(raw_files) ~= 'table' then error("invalid request") end

   local files, invalid_files = {}, {}
   for _, l in pairs(raw_files) do
      if type(l) ~= 'string' then error("invalid request") end
      local url = l:gsub('^%s*(.*)%s*$', '%1') -- trailing whitespaces
      local domain = url:match('^https?://(%w+)cdn%.githack%.com/') or url:match('^https?://(%w+)%.githack%.com/')
      table.insert(domain_to_origin[domain] and files or invalid_files, url)
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
       body=json.encode({files=files})
   }
   local res = http.new():request_uri(purge_url, params)
   local res_body = json.decode(res.body)
   if type(res_body) ~= 'table' or not res_body.success then
      ngx.log(ngx.ERR, "CDN response error: " .. res.body)
      return false
   end
   return true
end


local function purge_request()
   ngx.req.read_body()
   local args = json.decode(ngx.req.get_body_data())
   if not args then error("invalid request") end

   local files = validate_files(args.files)
   ngx.log(ngx.WARN, "got a request to purge #" .. #files .. " files")
   if not cdn_purge(files) then error("CDN response error") end
   ngx.say(json.encode({success = true, response = 'cache was successfully invalidated!'}))
end


return {
   purge_request = purge_request
}
