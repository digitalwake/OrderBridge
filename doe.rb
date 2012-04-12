require 'rubygems'
require 'savon'

class DoeOrders

@@current_log_file = "tmp/current_orders.xml"
@@advanced_log_file = "tmp/advanced_orders.xml"
@@wsdl_info = "tmp/info.txt"

	def initialize
		@vendor_id = ""
		@pass = ""
		@date = ""
		@end_date = ""
		@locked_flag = 0
		@boro = ""
	end

attr_writer :vendor_id, :pass, :date, :to_date, :locked_flag, :boro

	def GetCurrentOrders
		client = Savon::Client.new do 
		wsdl.document = "http://www.opt-osfns.org/osfns/resources/sfordering/SFWebService.asmx?WSDL"
		end

		File.open(@@wsdl_info,'w') do |f|
			f.puts "WSDL query started at #{Time.now}"
			#f.prints "Namespace: "
			f.puts client.wsdl.namespace
			#f.prints "Endpoint: "
			f.puts client.wsdl.endpoint
			#f.prints "Actions: "
			f.puts client.wsdl.soap_actions
		end

		#client.http.headers["Cookie"] = response.http.headers["Set-Cookie"]

		response = client.request :get_orders_xml do
			soap.version = 2
			soap.input = ["GetOrdersXML", {"xmlns" => "http://www.opt-osfns.org/"}]
			soap.body = {
				"vendorId" => @vendor_id,
				"pwd"      => @pass,
				"deliveryDate" => @date,
				"boro" => @boro,
				"finalDownload" => @locked_flag
			}
			soap.element_form_default = :unqualified
			soap.namespaces = {
				"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
				"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
				"xmlns:soap12" => "http://www.w3.org/2003/05/soap-envelope"
			}
			soap.env_namespace = 'soap12'
		end

		File.open(@@current_log_file,'w') do |f|
			#f.puts "test started at #{Time.now}"
			#f.puts response.http
			f.puts response.to_xml
		end
		return response.to_xml
	end
	
	def GetAdvancedOrders
		client = Savon::Client.new do 
		wsdl.document = "http://www.opt-osfns.org/osfns/resources/sfordering/SFWebService.asmx?WSDL"
		end

		File.open(@@wsdl_info,'w') do |f|
			f.puts "WSDL query started at #{Time.now}"
			#f.prints "Namespace: "
			f.puts client.wsdl.namespace
			#f.prints "Endpoint: "
			f.puts client.wsdl.endpoint
			#f.prints "Actions: "
			f.puts client.wsdl.soap_actions
		end

		#client.http.headers["Cookie"] = response.http.headers["Set-Cookie"]

		response = client.request :get_orders_date_range_xml do
			soap.version = 2
			soap.input = ["GetOrdersXML", {"xmlns" => "http://www.opt-osfns.org/"}]
			soap.body = {
				"vendorId" => @vendor_id,
				"pwd"      => @pass,
				"startDate" => @date,
				"endDate" => @to_date,
				"boro" => @boro
			}
			soap.element_form_default = :unqualified
			soap.namespaces = {
				"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
				"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
				"xmlns:soap12" => "http://www.w3.org/2003/05/soap-envelope"
			}
			soap.env_namespace = 'soap12'
		end

		File.open(@@advanced_log_file,'w') do |f|
			#f.puts "test started at #{Time.now}"
			#f.puts response.http
			f.puts response.to_xml
		end
		return response.to_xml
	end
end
