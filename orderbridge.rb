require '/home/nick/OrderBridge/Doe.rb'
require '/home/nick/OrderBridge/OrderProcessor.rb'
#require 'nokogiri'


puts "Welcome to Order Bridge 2.0"
#print "Please enter your DOE username:"
#doe_user=gets
#print "Please enter your DOE password:"
#doe_pass = gets

#print "Please enter your S2K username:"
#s2k_user=gets
#print "Please enter your S2K password:"
#s2k_pass = gets

#puts "Your S2k user information for this session are:"
#print "User:{#s2k_user} "
#print "Pass:{#s2k_pass]"

#puts "Your DOE user information for this session are:"
#print "User:{#doe_user} "
#puts "Pass:{#doe_pass]"

print "Continue? (Y/N):"
continue = gets
if continue
	puts "Beginning Processing"
	session = OrderProcessor.new
	puts "Preparing Connections"
	session.prepare
	puts "Processing Orders"
	session.process
	puts "Closing Connections"
	session.close
	puts "Processing Complete"
else
	puts "We're outta here"
end
	
#DoeOrders.GetOrders()

