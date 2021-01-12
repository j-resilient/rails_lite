# RailsLite
The sister project to [my_active_record](https://github.com/j-resilient/my_active_record) project, RailsLite is a very  
simplified version of Rails.  
[Specs](https://open.appacademy.io/learn/full-stack-online/rails/rails-lite-part-1)
## bin/p01_basic_server.rb
A very simple server that takes the path from the request and prints it on the page.  
A warm up to get familiar with Rack.
## lib/controller_base.rb
ControllerBase is our version of ActionController::Base, the class that all  
Rails Controllers inherit from.
- Renders templates.
- Redirects to another page.
- Returns the actual response to the Rack server.
- Initializes both the flash and session objects.
- It provides CSRF by generating a random number and storing it in the cookie and then comparing the authentication token in the cookie with the one the user uploads.
## lib/session.rb
The Session class handles the session cookie. It deserializes or creates it,  
updates it, allows hash-like access to it, and then saves it with a universal path  
so it's available everywhere on the app.
## lib/router.rb
Contains both the Route and the Router classes. The Route class defines Route objects  
that contain all of the route data as ivariables as well as #matches? which checks  
if the requested route matches the route and #run which initializes the corresponding  
controller and invokes the action on it.  
The Router class stores the routes and has several methods. #run checks if the route  
in the request matches any of the stored routes and returns a 404 error if it doesn't;  
#match looks through the stored routes for a given route; #add_route adds a route;  
and #draw takes a block of routes and calls the corresponding method defined in the  
each block defined beneath #draw - the each block creating all of the HTTP verb methods.
## lib/flash.rb
Manages the flash object, a hash-like object that stores data between HTTP request cycles. Contains both the flash, which lives for the current and next request cycle, and flash.now which is only available for the current request cycle.
## lib/show_exceptions.rb
Rack middleware that formats the error page, displaying the exception method, the stack trace, and a section of the code where the exception started.
## lib/static.rb
Rack middleware that makes static assets (images, CSS, etc) available to the client. All resources must be stored in the lib/public directory.