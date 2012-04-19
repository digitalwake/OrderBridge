require 'rdbi-driver-sqlite3'

class Preferences

	def initialize
		Dir.mkdir('./data') unless Dir.exists?('./data')
		#Database.new('./data/orderbridge.sqlite3') unless File.exists?('./data/orderbridge.sqlite3')
		
		#Connect to local sqlite3 database for preferences and local processing
		@db_local = RDBI.connect(RDBI::Driver::SQLite3, :database => './data/orderbridge.sqlite3')
		if @db_local.connected
			puts "We're connected to SQLite3"
			@db_local.execute("create table if not exists items_to_break (item integer)")
			@db_local.execute("create table if not exists items_to_weight (item integer)")
			@db_items_to_break = @db_local.execute("select * from items_to_break").fetch(:all,:Struct)
			@db_items_weight_to_qty = @db_local.execute("select * from items_to_weight").fetch(:all,:Struct)
		else
			puts "We're not connected to SQLite3"
		end
	end
	
	def maintenance(parms = {})
		puts "Maintenace type is: #{parms[:type]}"
	end
	
	def get_items_to_break
		return @db_items_to_break
	end
	
	def get_items_weight_to_qty
		return @db_items_weight_to_qty
	end
	
	def item_to_break(item)
		#stub
		@db_items_to_break.item.each do |x|
			return true if item == x
		end			
	end
	
	def item_weight_to_qty(item, qty, weight)
		@db_items_weight_to_qty.item.each do |x|
			if item == x
				quantity = qty/weight
				if qty % weight > 0
					quantity += 1
				end
				return quantity
			else		
				return qty
			end
		end
	end
end
