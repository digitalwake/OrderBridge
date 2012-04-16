class OrderWriter
	
	def initialize
		@orders = 0
		@total_order_lines = 0
		return self
	end
	
	def write_order_header(dbh)
		#stub
		@orders += 1
		#puts "OrderWriter.write_order_header called."
	end
	
	def write_order_detail(dbh)
		#stub
		@total_order_lines += 1
		#puts "OrderWriter.write_order_detail called."
	end
	
	attr_accessor :orders, :total_order_lines
	
end
