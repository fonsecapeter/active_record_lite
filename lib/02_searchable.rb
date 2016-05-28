require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    table = table_name

    wheres = []
    criteria = []
    params.each do |col, val|
      wheres << "#{col} = ?"
      criteria << val
    end

    where_statement = wheres.join(' AND ')

    data = DBConnection.execute(<<-SQL, *criteria)
    SELECT
      *
    FROM
      #{table}
    WHERE
      #{where_statement}
    SQL

      parse_all(data)
  end
end

class SQLObject
  extend Searchable
end
