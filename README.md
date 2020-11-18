# bin/p01_basic_server.rb
A very simple server that takes the path from the request and prints it on the page.  
A warm up to get familiar with Rack.
# lib/controller_base.rb
# lib/session.rb
The Session class handles the session cookie. It deserializes or creates it,  
updates it, allows hash-like access to it, and then saves it with a universal path  
so it's available everywhere on the app.