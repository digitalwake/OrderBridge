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
		@function = case gets.chomp
			when 1 then self.ProcessAdvanced
			when 2 then self.ProcessCurrent
	else
		puts "We're outta here"
	end
else
	puts "Login Failed - Quitting now."
end

def ProcessAdvance
	puts "*- Advanced Orders -*"
	puts "Enter FROM Date ( MMDDYYYY ):"
	@start_date = gets.chomp
	puts "Enter TO Date   ( MMDDYYYY ):"
	@to_date = gets.chomp
	puts "Enter Borough   ( (M/K/A(ll) ):"
	@boro = gets.chomp
	puts "Advanced Orders: Processing From Date: To Date: for Borough:"
	print "Continue? (Y/N):"
	continue = gets.chomp.upcase
	if continue == "Y"
		puts "Preparing Connections and Downloading Orders..."
		session.prepare
		puts "Processing Orders..."
		session.process
		puts "Closing Connections"
		session.close
		puts "Processing Complete"
	else
		puts "We're outta here"
	end
end

def ProcessCurrent
	puts "*- Current Orders -*"
	puts "Enter Date   ( MMDDYYYY ):"
	@start_date = gets.chomp
	puts "Enter Borough   ( (M/K/A(ll) ):"
	@boro = gets.chomp
	print "Continue? (Y/N):"
	continue = gets.chomp.upcase
	if continue == "Y"
		puts "Preparing Connections and Downloading Orders..."
		session.prepare
		puts "Processing Orders..."
		session.process
		puts "Closing Connections"
		session.close
		puts "Processing Complete"
	else
		puts "We're outta here"
	end
end
