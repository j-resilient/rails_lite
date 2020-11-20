require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = req.params.merge(route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Double render" if already_built_response?
    # there is a Rack method - #redirect - but they explicitly told us not to use it
    # so this code sets the status for the redirect and the new location
    # then sets @already_built_response so that the controller can't render/redirect twice
    @res.status = 302
    @res.location = url
    @already_built_response = true
    # set the cookie
    session.store_session(res)
    @res.finish
  end
  
  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Double render" if already_built_response?
    # set content-type header
    @res.content_type = content_type
    # append the content to the body of the response and update Content-Length
    @res.write(content)
    # set variable to prevent to show that content has already been rendered
    @already_built_response = true
    # set the cookie
    session.store_session(res)

    @res.finish
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    # creating the path is supposed to use File.dirname and File.join but
    # I don't understand how right now. Something to do with flexibility and making a gem
    # so when errors pop up in making a gem: this is the problem
    template_path = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    template_contents = File.read(template_path)
    view = ERB.new(template_contents).result(binding)
    render_content(view, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(action_name)
    self.send(action_name)
    render(action_name) unless already_built_response?
  end
end

