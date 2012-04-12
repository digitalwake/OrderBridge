require './order-processor.rb'
	
session = OrderProcessor.new
@start_date = ""
@to_date = ""
@locked_flag = 0
@boro = ""

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
			when "1" then self.processAdvanced
			when "2" then self.processCurrent
			end
	else
		puts "We're outta here"
	end
else
	puts "Login Failed - Quitting now."
end


def processAdvance
	puts "*- Advanced Orders -*"
	print "Enter FROM Date ( MMDDYYYY ):"
	@start_date = gets.chomp
	print "Enter TO Date   ( MMDDYYYY ):"
	@to_date = gets.chomp
	print "Enter Borough   ( (M/K/A(ll) ):"
	@boro = gets.chomp
	puts "Advanced Orders: Processing From Date: To Date: for Borough:"
	print "Continue? (Y/N):"
	continue = gets.chomp.upcase
	if continue == "Y"
		puts "Preparing Connections and Downloading Orders..."
		session.prepare
		puts "Processing Orders..."
		session.processAdvancedOrders
		puts "Closing Connections"
		session.close
		puts "Processing Complete"
	else
		puts "We're outta here"
	end
end

def processCurrent
	puts "*- Current Orders -*"
	print "Enter Date   ( MMDDYYYY ):"
	@start_date = gets.chomp
	print "Enter Borough   ( (M/K/A(ll) ):"
	@boro = gets.chomp
	print "Continue? (Y/N):"
	continue = gets.chomp.upcase
	if continue == "Y"
		puts "Preparing Connections and Downloading Orders..."
		session.prepare
		puts "Processing Orders..."
		session.processCurrentOrders
		puts "Closing Connections"
		session.close
		puts "Processing Complete"
	else
		puts "We're outta here"
	end
end
