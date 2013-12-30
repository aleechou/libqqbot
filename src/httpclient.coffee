https = require "https"
http  = require 'http'
querystring  = require 'querystring'
URL  = require('url')


# 设置全局cookie
all_cookies = []
global_cookies = (cookie)->
    all_cookies = cookie if cookie
    return all_cookies

http_request = (options , params , callback) ->
    aurl = URL.parse( options.url )
    options.host = aurl.host
    options.path = aurl.path
    options.headers ||= {} 
    
    client =  if aurl.protocol == 'https:' then https else http
    body = ''
    if params and options.method == 'POST'
        data = querystring.stringify params
        options.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        options.headers['Content-Length']= Buffer.byteLength(data)
        
    options.headers['Cookie'] = all_cookies
    options.headers['Referer'] = 'http://d.web2.qq.com/proxy.html?v=20110331002&callback=1&id=3'
    
    req = client.request options, (resp) ->
        # log "response: #{resp.statusCode}"
        resp.on 'data', (chunk) ->
            body += chunk
        resp.on 'end', ->
            callback( body )
    req.on "error" , (e)->
        callback(null,e)
        
    if params and options.method == 'POST'
        # log data
        req.write(data);
    req.end();


http_get  = (options , callback) ->
    options.method = 'GET'
    http_request( options , null , callback)
    
http_post = (options , body, callback) ->
    options.method = 'POST'
    http_request( options , body , callback)
    
# 导出方法
module.exports = 
    global_cookies: global_cookies
    request: http_request
    get:     http_get
    post:    http_post
    