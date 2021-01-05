require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue Exception => e
      # render a template with the data from the exception
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    context_info = e.backtrace.first.split(":")
    context_file = IO.readlines(context_info.first, chomp: true)
    index = context_info[1].to_i
    context = context_file[(index - 5),(index + 5)]

    contents = File.read("lib/templates/rescue.html.erb")
    view = ERB.new(contents).result(binding)
    ['500', {'Content-type' => 'text/html'}, [view]]

    # this rack response is what the tests are expecting
      # ['500', {'Content-type' => 'text/html'}, [e.message]]
  end

end
