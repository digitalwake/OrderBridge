require 'rdbi-driver-odbc'

dbh = RDBI.connect :ODBC, :db => "S2K"

rs = dbh.execute "SELECT count(*) FROM r37files.vwmpalet where wfstat = 'A'"
puts rs.fetch(:first)

dbh.disconnect
