require 'rdbi-driver-sqlite3'

class Preferences

	def initialize
		Dir.mkdir('./data') unless Dir.exists?('./data')
		#Database.new('./data/orderbridge.sqlite3') unless File.exists?('./data/orderbridge.sqlite3')
		
		#Connect to local sqlite3 database for preferences and local processing
		@db_local = RDBI.connect(RDBI::Driver::SQLite3, :database => './data/orderbridge.sqlite3')
		if @db_local.connected
			puts "We're connected to SQLite3"
			@db_local.execute("create table if not exists items_to_break (item string)")
			@db_local.execute("create table if not exists items_to_weight (item string)")
		else
			puts "We're not connected to SQLite3"
		end
	end
	
	def maintenance(parms = {})
		puts "Maintenace type is: #{parms[:type]}"
		puts "Adding or Deleting? (A/D):"
		flag = gets.chomp.upcase
		case parms[:type]
			when "broken" then
				table = "items_to_break"
			when "weight" then
				table = "items_to_weight"
		end
		puts "Enter your items. Type X to quit:"
		input = gets.chomp.upcase
			while input != 'X'
				maintain(input,table,flag)
				puts "Enter your items. Type X to quit:"
				input = gets.chomp.upcase
			end
	end
	
	def maintain(input,tbl,flag)
		case flag
			when "A" then add_to_pref_table(input,tbl)
			when "D" then delete_from_pref_table(input,tbl)
		end
	end
	
	def get_items_to_break
		rs = @db_local.execute("select * from items_to_break").fetch(:all,:Struct)
		return rs
	end
	
	def get_items_weight_to_qty
		rs = @db_local.execute("select * from items_to_weight").fetch(:all,:Struct)
		return rs
	end
	
	def item_to_break(item,uom)
		rs = self.get_items_to_break
		unless rs.empty? 
			rs.item.each do |x|
				if item == x
				 	uom='EA'
				 	broken_item = true
				else
					uom = 'CS'
					broken_item = false
				end
			end
		end
		return (defined? broken_item).nil? ? false : broken_item		
	end
	
	def item_weight_to_qty(item, qty, weight)
		rs = self.get_items_weight_to_qty
		unless rs.empty?
			rs.item.each do |x|
				if item == x
					new_qty = qty/(weight*100)
					if qty % (weight*100) > 0
						quantity += 1
					end
					qty = new_qty
				end
			end
		end			
		return qty
	end
	
	protected
	def delete_from_pref_table(input,tbl)
		rs = @db_local.execute("delete from #{tbl} where item = #{input}")
	end
	
	def add_to_pref_table(input,tbl)
		rs = @db_local.execute("insert into #{tbl} (item) values(#{input})")
	end
	
end
