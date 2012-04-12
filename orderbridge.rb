require './order-processor.rb'
	
session = OrderProcessor.new

if session.login
	print "Continue? (Y/N):"
	continue = gets.chomp.upcase
			
	if continue == "Y"
		puts "Please select from the following Menu options:"
		puts "1.Get Advanced Orders for a Date Range"
		puts "2.Process and 'Lock' Orders for a Specific Date"
		print "Enter option:"
		@function = gets.chomp
			case @function
			when "1" then session.processAdvancedOrders
			when "2" then session.processCurrentOrders
			end
	else
		puts "We're outta here"
	end
	
else
	puts "Login Failed - Quitting now."
end

