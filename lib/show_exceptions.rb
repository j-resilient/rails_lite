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
      render_exception(e)
      ['500', {'Content-type' => 'text/html'}, [e.message]]
    end
  end

  private

  def render_exception(e)
    print e
    # render the stack trace
    # preview the code where the exception was raised
    # display the exception method
  end

end
