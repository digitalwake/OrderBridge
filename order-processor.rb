require 'rdbi'
require 'rdbi-driver-odbc'
require 'rdbi-driver-sqlite3'
require 'savon'
require 'nokogiri'
require './doe.rb'
require './order-writer.rb'

class OrderProcessor

	def initialize
		@writer = OrderWriter.new
		@orders_processed = 0
		@purchase_order = 0
		@delivery_date = 0
		@special_instructions = ""
		@cust_num = 0
		@ship_to = 0
		@spec_num = ""
		@qty= 0
		return self
	end
	
	def login
		correct = 'N'
		while correct =='N'
			print "Please enter your DOE username:"
			@doe_user = gets.chomp
			print "Please enter your DOE password:"
			@doe_pass = gets.chomp

			print "Please enter your S2K username:"
			@s2k_user=gets.chomp
			print "Please enter your S2K password:"
			@s2k_pass = gets.chomp
			puts ""

			puts "Your S2k user information for this session are:"
			puts "User:#{@s2k_user}"
			puts "Pass:#{@s2k_pass}"
			puts ""

			puts "Your DOE user information for this session are:"
			puts "User:#{@doe_user}"
			puts "Pass:#{@doe_pass}"
			puts ""
			puts "Is this correct? (Y/N) or (X - to cancel)"
			correct = gets.chomp.upcase
		end
		if correct == 'X'
			puts "success is FALSE" 
			return false
		end
		
		puts "Success is TRUE"
		return true
	end
	
	def processCurrentOrders
		#Prepare for processing
		#self.login
		puts "*-------- Current Orders --------*"
		print "         Enter Date [MM/DD/YYYY]:"
		parms = {:advanced => 'N', :date => gets.chomp}
		print "Enter Borough ['M'/'K1'/'A'(ll)]:"
		parms[:boro] = gets.chomp.upcase
		#print "Lock the Orders? (Y/N)"
		#parms[:locked] = case gets.chomp.upcase
			#when "Y" then 1
			##when "N" then 0
			end
		
		#puts "Flag = #{parms[:locked]}"
		print "**This will LOCK ALL the orders for this date.** Continue? (Y/N):"
		continue = gets.chomp.upcase
		
		if continue == "Y"
			puts "Preparing Connections and Downloading Orders..."
			self.prepare(parms)
			puts "Processing Orders..."
			#self.processCurrentOrders
			#iterate through the orders (elements marked "elements")
			
			i=0
			x=0
			@ns.each do |node| 
				@purchase_order = node.at_xpath("order_id").content
				@delivery_date = node.at_xpath("delivery_date").content
				@ship_to = node.at_xpath("school_id").content.to_i
				@cust_num = ((@ship_to/1000)*1000)+999
				#puts "Mie #{@ship_to} converted to #{@mie}"
				@special_instructions = node.at_xpath("special_instruction").content
			
				i += 1
				#puts "Order id from node: #{node.name} is: #{@purchase_order}"
				puts "Orders: #{i}" #indexing starts at zero
				process_order_header @purchase_order, @cust_num, @ship_to, @delivery_date, @special_instructions

				#iterate through the element details
				node.children.each do |child|
					#print child.name
					x += 1
					@spec_num = child['item_key']
					@qty      = child['ordered_quantity']
					process_order_detail @spec_num, @qty
				end
			end
			
			puts "Closing Connections"
			self.close
			puts "Processing Complete"
		else
			puts "We're outta here"
		end
	end
	
	def processAdvancedOrders
		#login and prepare for processing
		#self.login
		#self.prepare
		puts "*--------- Advanced Orders --------*"
		print "      Enter FROM Date [MM/DD/YYYY]:"
		parms = {:advanced => 'Y', :date => gets.chomp}
		print "        Enter TO Date [MM/DD/YYYY]:"
		parms[:end_date] = gets.chomp
		print "Enter Borough   ['M'/'K1'/'A'(ll)]:"
		parms[:boro] = gets.chomp.upcase
		puts "Advanced Orders: Processing From Date: #{parms[:date]} To Date: #{parms[:end_date]} for Borough: #{parms[:boro]}"
		print "Continue? (Y/N):"
		continue = gets.chomp.upcase
		
		if continue == "Y"
			puts "Preparing Connections and Downloading Orders..."
			self.prepare(parms)
			puts "Processing Orders..."
			#iterate through the orders (elements marked "elements")
			i=0
			x=0
			@ns.each do |node| 
				@purchase_order = node.at_xpath("order_id").content
				@delivery_date = node.at_xpath("delivery_date").content
				@ship_to = node.at_xpath("school_id").content.to_i
				@cust_num = ((@ship_to/1000)*1000)+999
				#puts "Mie #{@ship_to} converted to #{@mie}"
				@special_instructions = node.at_xpath("special_instruction").content
			
				i += 1
				#puts "Order id from node: #{node.name} is: #{@purchase_order}"
				puts "Orders: #{i}" #indexing starts at zero
				process_order_header @purchase_order, @cust_num, @ship_to, @delivery_date, @special_instructions

				#iterate through the element details
				node.children.each do |child|
					#print child.name
					x += 1
					@spec_num = child['item_key']
					@qty      = child['ordered_quantity']
					process_order_detail @spec_num, @qty
				end
			end
			
			puts "Closing Connections"
			self.close
			puts "Processing Complete"
		else
			puts "We're outta here"
		end
		#puts "OrderProcessor::processAdvancedOrders called"
	end
	
	def close
		@cust_items.finish
		@database_handle.disconnect
		@db_local.disconnect
		puts "#{@writer.orders} Orders Processed with a total of #{@writer.total_order_lines} order lines."
	end
	
	protected
	def prepare (parms)
	
		#puts "parms[:advanced] = #{parms[:advanced]}"
		#puts "parms[:date] = #{parms[:date]}"
		#puts "parms[:boro] = #{parms[:boro]}"
		#puts "parms[:locked] = #{parms[:locked]}"
		#puts "parms[:end_date] = #{parms[:end_date]}"
		
		doe_service = DoeOrders.new
		doe_service.pass = @doe_pass
		doe_service.vendor_id = @doe_user
		doe_service.date = parms[:date]
		
		if parms[:advanced]=='N'
			#Get the DOE Orders and save off to a file
			#doe_service.boro = parms[:boro]
			#doe_service.locked_flag = parms[:locked]
			#puts "doe_service.pass = #{doe_service.pass}"
			#puts "doe_service.vendor_id = #{doe_service.vendor_id}"
			#puts "doe_service.date = #{doe_service.date}"
			#puts "doe_service.boro = #{doe_service.boro}"
			#puts "doe_service.lockeD_flag = #{doe_service.locked_flag}"
			@orders = doe_service.GetCurrentOrders
		
			#Get Current XML orders from the Web Service File
			doc = Nokogiri::XML(open("tmp/current_orders.xml"))
			
		else
			doe_service.end_date = parms[:end_date]
			doe_service.boro = parms[:boro]
			@orders = doe_service.GetAdvancedOrders
		
			#Get Future XML orders from the Web Service File
			doc = Nokogiri::XML(open("tmp/advanced_orders.xml"))
		end			

		#A NodeSet of the child elements - The DOE WebService names the elements "elements"
		@ns = doc.xpath("//elements")
		
		#Connect to S2K via ODBC and get a handle
		@database_handle = RDBI.connect :ODBC, :db => "S2K"
		if @database_handle.connected
			puts "We're connected to S2K"
		else
			puts "We're not connected to S2K"
		end
		
		#Connect to local sqlite3 database for preferences and local processing
		@db_local = RDBI.connect(RDBI::Driver::SQLite3, :database => '/tmp/obtest.sqlite3')
		if @db_local.connected
			puts "We're connected to SQLite3"
		else
			puts "We're not connected to SQLite3"
		end
				
		#Get Customer Item number details						
		@cust_items = @database_handle.execute("select ficdel,ficdonated,oncitm,onitem from 
																			vcoitem inner join r37files.finitem on onitem=ficitem where oncust=100000")
		
		@item_master = @database_handle.execute("select ficdel,ficdonated,oncitm,onitem from 
																			vcoitem inner join r37files.finitem on onitem=ficitem where oncust=100000")
		#@cust_items.each {|r| puts "#{r}"}
		
		puts "Customer Item# result count is: #{@cust_items.result_count}"
				
	end
	
	def process_order_header(cust_po,cust,ship_to,delivery_date,sp_inst)
		#stub
		puts "process_order_header called for PO: #{cust_po} CUST: #{cust} SHIP_TO: #{ship_to} DATE: #{delivery_date}"
		@writer.write_order_header(@database_handle)
	end
	
	def process_order_detail(cust_item,cust_qty)
		#stub
		puts "process_order_detail for Spec:#{cust_item} Qty: #{cust_qty}"
		@writer.write_order_detail(@database_handle)
	end
	
	#private_class_method :prepare, :process_order_header, :process_order_detail
			
end
