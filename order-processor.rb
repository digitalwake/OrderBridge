require 'rdbi'
require 'rdbi-driver-odbc'
require 'savon'
require 'nokogiri'
require './doe.rb'
require './order-writer.rb'
require './preferences.rb'

class OrderProcessor

	def initialize
		@writer = OrderWriter.new
		@prefs = Preferences.new
		@orders_processed = 0
		@purchase_order = 0
		@delivery_date = 0
		@special_instructions = ""
		@cust_num = 0
		@ship_to = 0
		@spec_num = ""
		@qty= 0
		@drop_ship = false
		@item=""
		@item_weight=0
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
	
	def process_current_orders
		puts "*-------- Current Orders --------*"
		print "         Enter Date [MM/DD/YYYY]:"
		parms = {:advanced => 'N', :date => gets.chomp}
		print "Enter Borough ['M'/'K1'/'A'(ll)]:"
		parms[:boro] = gets.chomp.upcase
		
		print "**This will LOCK ALL the orders for this date.** Continue? (Y/N):"
		continue = gets.chomp.upcase
		
		if continue == "Y"
			puts "Preparing Connections and Downloading Orders..."
			self.prepare(parms)
			puts "Processing Orders..."
			self.process
			puts "Closing Connections"
			self.close
			puts "Processing Complete"
		else
			puts "We're outta here"
		end
	end
	
	def process_advanced_orders
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
			self.process
			puts "Closing Connections"
			self.close
			puts "Processing Complete"
		else
			puts "We're outta here"
		end
		#puts "OrderProcessor::processAdvancedOrders called"
	end
	
	def maintain_items_to_break
		@prefs.maintenance :type => "broken"
	end
	
	def maintain_items_to_weight
		@prefs.maintenance :type => "weight"
	end
	
	def close
		#@cust_items.finish
		#@item_master.finish
		@database_handle.disconnect
		#@db_local.disconnect
		puts "#{@writer.orders} Orders Processed with a total of #{@writer.total_order_lines} order lines."
	end
	
	protected
	def prepare(parms = {})
			
		doe_service = DoeOrders.new
		doe_service.pass = @doe_pass
		doe_service.vendor_id = @doe_user
		doe_service.date = parms[:date]
		
		if parms[:advanced]=='N'
			#@orders = doe_service.get_current_orders
		
			#Get Current XML orders from the Web Service File
			doc = Nokogiri::XML(open("tmp/current_orders.xml"))		
		else
			doe_service.end_date = parms[:end_date]
			doe_service.boro = parms[:boro]
			#@orders = doe_service.get_advanced_orders
		
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
				
		#Get Customer Item number details						
		#@cust_items = @database_handle.execute("select ficdel,ficdonated,oncitm,onitem from 
																					#vcoitem inner join r37files.finitem on onitem=ficitem where oncust=100000")
																					#.fetch(:all,:Struct)
																					#.fetch(:all)
		#Get item info
		@item_master = @database_handle.execute("SELECT DISTINCT R37MODSDTA.VCOITEM.ONITEM, R37MODSDTA.VCOITEM.ONCITM,
																						R37FILES.FINITEM.FICBRAND, R37FILES.VINITEM.ICDSC1,R37FILES.VINITEM.ICWGHT,
																						R37FILES.VINITEM.ICDEL, R37MODSDTA.VCOITEM.ONCUST, R37FILES.VINITMB.IFDROP 
																						FROM (R37FILES.VINITEM INNER JOIN R37MODSDTA.VCOITEM ON 
																						(R37FILES.VINITEM.ICITEM = R37MODSDTA.VCOITEM.ONITEM)) INNER JOIN R37FILES.FINITEM ON 
																						R37MODSDTA.VCOITEM.ONITEM = R37FILES.FINITEM.FICITEM INNER JOIN R37FILES.VINITMB ON 
																						R37FILES.VINITMB.IFITEM=R37FILES.FINITEM.FICITEM WHERE 
																						(((R37MODSDTA.VCOITEM.ONCUST)='100000 ')) AND ICDEL <> 'I'").fetch(:all,:Struct)
																						#.fetch(:all)
																						
		#Clear EDI tables
		@database_handle.execute("delete from t37files.vedxpohw")
		@database_handle.execute("delete from t37files.vedxpodh")
		
		#puts "Customer Item# result count is: #{@cust_items.result_count}"
		#puts "Item Master result count is: #{@item_master.result_count}"
		
		#@item_master.each {|r| puts "#{r}"}				
	end
	
	def get_uom
		#CS or EA
		return "CS"
	end
	
	def get_s2k_item(cust_item)
		@item_master.each do |row|
			if row.ONCITM == cust_item
				@item_master.each do |items|
					if items.FICBRAND == ('DONATED' || 'COMMODITY')
						@item = items.ONITEM
						@item_weight = items.ICWGHT
					else
						@item = row.ONITEM
						@item_weight = row.ICWGHT	
					end				
			else
				item_found = false
			end
		end
		return item_found
	end
	
	def drop_ship?(item)
		@item_master.each do |row|
			if row.IFDROP == 'Y'
				return true
			else
				return false
			end
		end
	end
	
  def process
	#iterate through the orders (elements marked "elements")
		i=0
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
				
			#iterate through the element details looking for drop shipments
			orderline=0
			node.xpath('details').each do |child|
				#print child.name
				spec_num = child['item_key']
				qty = child['ordered_quantity']
				
				#puts "First iteration: spec = #{child['item_key']}, qty = #{child['ordered_quantity']}"
				item = self.get_s2k_item(spec_num)
				if drop_ship?(item)
					@drop_ship = true
					if item_to_break(item,@uom)
						item += "-BC"
					#uom = self.get_uom
					#process_order_detail @purchase_order, @spec_num, @qty
					orderline += 1
					@writer.write_order_detail_drop_ship(@database_handle, @cust_num, @purchase_order, orderline, item, spec_num, uom, @ship_to, qty)
						
					#Remove the drop ship item from the node set
					child.remove
				else
					#do nothing
				end						
			end
				
			if @drop_ship == true
				@writer.write_order_header_drop_ship(@database_handle, @purchase_order, @cust_num, @ship_to, @delivery_date, @special_instructions)
					
				#set drop ship to no for the next iteration since the drop ships have been processed
				@drop_ship = false
			end
					
			unless node.xpath('details').empty?
				@writer.write_order_header(@database_handle, @purchase_order, @cust_num, @ship_to, @delivery_date, @special_instructions)
				#iterate through the element details again for the regular shipment
				orderline=0
				node.xpath('details').each do |child|
					spec_num = child['item_key']
					qty = child['ordered_quantity']
					item = self.get_s2k_item(spec_num)
					#uom = self.get_uom
							
					orderline += 1
					@writer.write_order_detail(@database_handle, @cust_num, @purchase_order, orderline, item, spec_num, uom, @ship_to, qty)
											
					#Remove the item from the node set
					child.remove
				end
			end #unless
			#@ns.each do |child|
				#puts "Node: #{child}"
			#end
		end
  end
	#private_class_method :prepare, :process_order_header, :process_order_detail
end
