# bin/p01_basic_server.rb
A very simple server that takes the path from the request and prints it on the page.  
A warm up to get familiar with Rack.
# lib/controller_base.rb
ControllerBase is our version of ActionController::Base, the class that all  
Rails Controllers inherit from.
Methods  
+ initialize sets the response and request objects as instance variables.
+ render_content(content, content_type) checks whether a response has already been  
 built and if it hasn't it sets the response's content-type header, writes the content  
 to the body of the response, sets the cookie, and sets already_built_response to true.
+ redirect_to(url) checks whether a response has already been built and if it hasn't  
 it sets the response status to 302, the response location to the given url, sets  
 the cookie, and sets already_built_response to true.
+ already_built_response if the ivariable already_built_response is set to true,  
 it returns the ivariable: otherwise it sets the ivariable to false and then returns it
+ render(template_name) creates the path to the given template, gets the contents  
 of the template, creates an ERB file from the contents, and then passes the ERB file  
 to #render_content.
+ session returns the session ivariable: if the session object doesn't exist, initializes  
 one and returns that
+ invoke_action(action_name) uses #send to find the given method on the current instance  
 and call it then, if no template has been rendered, renders the template that corresponds  
 to the action name
# lib/session.rb
The Session class handles the session cookie. It deserializes or creates it,  
updates it, allows hash-like access to it, and then saves it with a universal path  
so it's available everywhere on the app.
# lib/router.rb
Contains both the Route and the Router classes. The Route class defines Route objects  
that contain all of the route data as ivariables as well as #matches? which checks  
if the requested route matches the route and #run which initializes the corresponding  
controller and invokes the action on it.  
The Router class stores the routes and has several methods. #run checks if the route  
in the request matches any of the stored routes and returns a 404 error if it doesn't;  
#match looks through the stored routes for a given route; #add_route adds a route;  
and #draw takes a block of routes and calls the corresponding method defined in the  
each block defined beneath #draw - the each block creating all of the HTTP verb methods.