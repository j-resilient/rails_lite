require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req, @res = req, res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
  end

  # Set the response status code and header
  def redirect_to(url)
    # there is a Rack method - #redirect - but they explicitly told us not to use it
    # so this code sets the status for the redirect and the new location
    # then sets @already_built_response so that the controller can't render/redirect twice
    @res.status = 302
    @res.location = url
    @already_built_response = true
    @res.finish
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    # set content-type header
    @res['Content-Type'] = content_type
    # append the content to the body of the response and update Content-Length
    @res.write(content)
    # set variable to prevent to show that content has already been rendered
    @already_built_response = true

    @res.finish
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

