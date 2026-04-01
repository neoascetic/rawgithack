local json = require("cjson.safe")
local http = require("resty.http")
local cfg = require("config")


local function error(desc)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.say(desc)
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
   local url = ngx.var.arg_url
   if type(url) ~= 'string' or url == '' then error("missing url parameter") end
   url = ngx.unescape_uri(url)
   local domain = url:match('^https?://(%w+)cdn%.githack%.com/') or url:match('^https?://(%w+)%.githack%.com/')
   if not domain or not domain_to_origin[domain] then error("invalid URL") end
   ngx.log(ngx.WARN, "got a request to purge: " .. url)
   if not cdn_purge({url}) then error("CDN response error") end
   ngx.exit(ngx.HTTP_OK)
end


return {
   purge_request = purge_request
}
