class LogWriter

@@warning_file = "logs/warnings.txt"
@@error_file = "logs/errors.txt"
@@inactive_item_file = "logs/inactive_items.txt"

	def initialize
		Dir.mkdir('./logs') unless Dir.exists?('./logs')
		#File.new(@@warning_file)
		#File.new(@@error_file)
		@wfh = File.open(@@warning_file, "w")
		@wfh.puts "OrderBridge 2.0 WARNING Report (run at: #{Time.now})"
		@efh = File.open(@@error_file, "w")
		@efh.puts "OrderBridge 2.0 ERROR Report (run at: #{Time.now})"
		#@ifh = File.open(@@inactive_item_file, "w")
		#@ifh.puts "OrderBridge 2.0 INACTIVE ITEM Report (run at: #{Time.now})"
	end
	
	def error(parms = {})
		@efh.puts "#{parms[:msg]} **********"
		@efh.print "Date: #{format("%10s", parms[:date])}  Customer: #{format("%10s", parms[:cust])}  Ship-to: #{format("%10s", parms[:ship])}"
		@efh.puts "  Order: #{format("%10s", parms[:order])} Item: #{format("%10s", parms[:item])}  Qty: #{format("%6s", parms[:qty])}"		
	end
	
	def warning(rs, parms = {})
		@wfh.puts "#{parms[:msg]} **********"
		@wfh.print "Date: #{format("%10s", parms[:date])}  Customer: #{format("%10s", parms[:cust])}  Ship-to: #{format("%10s", parms[:ship])}"
		@wfh.puts "  Order: #{format("%10s", parms[:order])}  Item: #{format("%10s", parms[:item])}  Qty: #{format("%6s", parms[:qty])}"
		rs.each do |x|
			@wfh.puts "item: #{x[:item]}"
		end
		@wfh.puts "---------------------------------------------------------------------------"
	end
	
	def inactive(parms = {})
		@ifh.puts "Order: #{format("%10s", parms[:order])} Customer Item: #{format("%20s", parms[:spec])} Qty: #{format("%10s", parms[:qty])}"
	end
	
	def close
		#day = Time.day
		#month = Time.month
		#year = Time.year
		#filename = "#{year}#{month}#{day}.txt"
		#File.rename(@@warning_file, "logs/warnings" + filename)
		#File.rename(@@error_file, "logs/errors" + filename)
		#File.rename(@@inactive_item_file, "logs/inactive_items" + filename)
		File.close(@@warning_file)
		File.close(@@error_file)
		#File.close(@@inactive_item_file)
	end
	
end
