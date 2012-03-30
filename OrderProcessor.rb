require 'rdbi'
require 'rdbi-driver-odbc'
require 'rdbi-driver-sqlite3'
require 'savon'
require 'nokogiri'


class OrderProcessor

	def new
		return self
	end
	
	def prepare
		#file_handle=File.open("order_teri.xml")
		
		#Get XML orders from the Web Service File
		doc = Nokogiri::XML(open("order_teri.xml"))
		#file_handle.close
		#puts "Here are the XML keys"
		
		#A NodeSet of the child elements - The DOE WebService names the elements "elements"
		@ns = doc.root.children
		
		#iterate through the orders (elements marked "elements")
		@ns.each do |node|
			puts node.name
			puts order_count++
			#iterate through the element details
			node.first.children.each do |node|
				puts node.name
				puts child_count++
			end
		end
			
		
		#Connect to S2K via ODBC
		#@database_handle = RDBI.connect :ODBC, :db => "S2K"
		#if @database_handle.connected
		#	puts "We're connected to S2K"
		#else
		#	puts "We're not connected to S2K"
		#end
		
		#Connect to local sqlite3 database for preferences and local processing
		@db_local = RDBI.connect(RDBI::Driver::SQLite3, :database => '/tmp/obtest.sqlite3')
		if @db_local.connected
			puts "We're connected to SQLite3"
		else
			puts "We're not connected to SQLite3"
		end
				
		#Get Customer Item number details						
		#@cust_items = @database_handle.execute("select ficdel. ficdonated.oncitm,onitem from vcoitem 																					inner join finitem on onitem=ficitem where oncust=100000")
		
		@db_local.execute("delete from orders")
		@db_local.execute("insert into orders(mie,delivery_date,purchase_order,spec_num,quantity)
							values(2135,'03/29/12',123456,'BF FS001', 10)")

		@database_handle.execute("insert into nickr.orders(custnum,shipto,delivery_date,purchase_order,
												spec_num,itemnum,quantity) values(2999,2135,'2012-03-29',123456,'BF FS001', 925125,10)")
		
	end
	
	def process
		puts "Process has been called"
		puts @db_local.execute("select * from orders").fetch(:all)
		#return @db_result.fetch(:all)
		puts @database_handle.execute("select * from nickr.orders")
	end
	
	def close
		@database_handle.disconnect
		@db_local.disconnect
	end
			
end
		

