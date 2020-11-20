require 'rack'

# the rack app: must respond to #call, must take a variable
# that variable (env) contains all of the request data
app = Proc.new do |env|
    # create a Request object made up of the HTTP request data
    req = Rack::Request.new(env)
    # create a blank Response object
    res = Rack::Response.new
    # Set the Response Content-Type header as text/html
    res['Content-Type'] = 'text/html'
    # get the request url from the request via get header
    # and write it to the response body - literally just print it on the page
    res.write(req.get_header('REQUEST_URI'))
    # #finish converts the Response object into a properly formatted Rack array
    res.finish
end

# start the server listening on port 3000
# and mount the rack app on it
Rack::Server.start ({
    app: app,
    Port: 3000
})