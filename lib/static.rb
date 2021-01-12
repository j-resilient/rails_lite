require 'mimemagic'
class Static
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)

    if req.path.index("/public/") == 0
      return_static_media(req)
    else
      @app.call(env)
    end
  end

  def return_static_media(req)
    res = Rack::Response.new

    dir = File.dirname(__FILE__)
    file_name = File.join(dir, '..', req.path)

    # if file exists, open it and write it to response
    # else 404 error
    if File.exist?(file_name)
      res.content_type = MimeMagic.by_magic(file_name)
      res.write(File.read(file_name))
    else
      res.status = 404
      res.content_type = "text/html"
      res.write("File not found.")
    end

    res.finish
  end
end
