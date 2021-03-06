require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    # set req and res as instance variables
    @req, @res = req, res
    @params = req.params.merge(route_params)

    # class variable defining whether the controller that
    # inherits from controller_base called protect_from_forgery
    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    # set @already_built_response to false unless it's already set to true
    @already_built_response ||= false
  end

  # Set the response status code and header
  def redirect_to(url)
    before_render
    # there is a Rack method - #redirect - but they explicitly told us not to use it
    # so this code sets the status for the redirect and the new location
    # then sets @already_built_response so that the controller can't render/redirect twice
    @res.status = 302
    @res.location = url
  end
  
  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    before_render
    # set the response's content-type header
    @res.content_type = content_type
    # append the content to the body of the response and update Content-Length
    @res.write(content)
  end

  def before_render
    raise "Double render" if already_built_response?
    # set the cookies
    session.store_session(res)
    flash.store_flash(res)
    # set variable to prevent to show that the response has been built - 
    # aka the content has already been rendered
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    # __FILE__ is a special variable that gives the filename of this file - 
    # the one code is executing from right now
    current_dir = File.dirname(__FILE__)
    # here we join the directory info with the file name, creating a path
    # relative to controller_base.rb
    # template_path = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    template_path = File.join(
      current_dir, '..', 'views', 
      self.class.name.underscore, "#{template_name}.html.erb")
    # read in the contents of the file at the template path
    template_contents = File.read(template_path)
    # create an ERB file from the path then call binding on the result
    # so that the context - variable data, methods, etc - is saved with the file
    view = ERB.new(template_contents).result(binding)
    # call render_content on the ERB file
    render_content(view, "text/html")
  end

  # method exposing a `Session` object
  def session
    # if a session ivariable doesn't exist,
    # initialize and store a new Session object
    @session ||= Session.new(@req)
  end

  # method exposing a 'Flash' object
  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(action_name)
    if @req.request_method != 'GET' && @@protect_from_forgery
      check_authenticity_token
    else
      form_authenticity_token
    end
    self.send(action_name)
    # if the dev didn't render a template, render the corresponding template
    render(action_name) unless already_built_response?
  end

  def self.protect_from_forgery
    # set protect_from_forgery to true
    # so check_authenticity_token is actually run
    @@protect_from_forgery = true
  end

  def check_authenticity_token
    # validates the auth token
    # needs to be called from within #invoke_action
    # !!! but neither params nor req.params HAS an auth_token
    token = req.cookies['authenticity_token']
    unless token && token.to_s == params["authenticity_token"] 
      raise "Invalid authenticity token"
    end 
  end

  def form_authenticity_token
    #  provides the developer with a way to include the CSRF token in a form
    # note that we don't get a database
    # it's going to be stored in the cookie
    @auth_token ||= self.class.generate_auth_token
    @res.set_cookie('authenticity_token', {path: "/", value: @auth_token})
    @auth_token
  end

  def self.generate_auth_token
    SecureRandom::urlsafe_base64(16)
  end
end

