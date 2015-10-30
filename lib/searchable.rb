require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    keys = params.keys.map{|key| "#{key} = ?"}.join(" AND ")
    hash = DBConnection.execute(<<-SQL, *params.values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{keys}
    SQL
    self.parse_all(hash)
  end
end

class SQLObject
  extend Searchable
end
