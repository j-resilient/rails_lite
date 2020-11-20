require 'rack'
require_relative '../lib/controller_base'

# creates the MyController class which inherits from ControllerBase
class MyController < ControllerBase
  def go
    # depending on the requests path call either #render_content or #redirect_to
    # both of which are defined in ControllerBase
    if req.path == "/cats"
      render_content("hello cats!", "text/html")
    else
      redirect_to("/cats")
    end
  end
end

# the rack app
app = Proc.new do |env|
  # create a request object with all of the data from env
  # which is all of the data from the HTTP request
  req = Rack::Request.new(env)
  # create a blank response object
  res = Rack::Response.new
  # instantiate a copy of the MyController controller
  # passing req and res to #initialize, which is defined in ControllerBase
  # then call #go
  MyController.new(req, res).go
  # now that the response has been updated, use #finish to convert it
  # to the rack standard array format
  # then return it
  res.finish
end

# start the server listening on port 3000
# and mount the rack app on it
Rack::Server.start(
  app: app,
  Port: 3000
)

