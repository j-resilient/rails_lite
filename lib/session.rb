require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    # if the request already has our cookie, deserialize and store it so we can update it
    # otherwise start the hash for a new cookie
    @session = (req.cookies['_rails_lite_app'] ? JSON.parse(req.cookies["_rails_lite_app"]) : {})
  end

  # get session content
  def [](key)
    @session[key]
  end

  # set session content
  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    # Response#set_cookie takes the name of the cookie and then a hash
    # containing first the path - "/" is root and will make sure the cookie is 
    # available on every page of the site
    # and then the value of the cookie, which is the session hash serialized to 
    # a json string
    res.set_cookie("_rails_lite_app", {path: "/", value: @session.to_json})
  end
end
