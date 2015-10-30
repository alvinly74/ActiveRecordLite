require_relative 'associatable'
module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options
      num = DBConnection.execute(<<-SQL)
        SELECT
          #{source_options[source_name].model_class.table_name}.*
        FROM
          #{through_options.model_class.table_name}
        JOIN
          #{source_options[source_name].model_class.table_name} ON #{through_options.model_class.table_name}.#{source_options[source_name].foreign_key} = #{source_options[source_name].model_class.table_name}.id
        WHERE
          #{through_options.model_class.table_name}.id = #{self.send(through_options.foreign_key)}
      SQL
      source_options[source_name].model_class.parse_all(num).first
    end
  end
end
