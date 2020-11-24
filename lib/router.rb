class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    http_method == req.request_method.downcase.to_sym && pattern =~ req.path
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    # Create a new Regex object and pass in the path regex string
    # check that the regex path matches the http path
    # store the results in match_data
    regex = Regexp.new pattern
    match_data = regex.match(req.path)

    # build a route_params hash from match_data
    route_params = {}
    unless match_data.nil?
      match_data.names.each do |param|
        route_params[param] = match_data[param]
      end
    end
    # instantiate the correct controller for the given route
    controller = controller_class.new(req, res, route_params)

    # invokes the given action on the instantiated controller
    controller.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    # self refers to the current router instance
    # so the given block is executed in the context
    # of the current router instance
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    routes.find do |route|
      req.path =~ route.pattern &&
      req.request_method.downcase.to_sym == route.http_method
    end
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    # find the first matching route
    route_match = match(req)

    # if route exists, call Route#run
    # otherwise, return a 404 error
    if route_match
      route_match.run(req, res)
    else
      res.status = 404
      res.write("#{req.path} does not exist.")
    end
  end
end
