require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    (class_name + 's').downcase
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || (name.to_s + '_id').to_sym
    @class_name = options[:class_name]   || name.to_s.camelcase
    @primary_key = options[:primary_key] || 'id'.to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || (self_class_name +'_id').downcase.to_sym
    @class_name = options[:class_name]   || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] || 'id'.to_sym
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name,options)
    assoc_options[name] = options
    define_method(name) do
      fork_key = self.send(options.foreign_key)
      return nil if fork_key.nil?
      klass = options.model_class
      num = DBConnection.execute(<<-SQL)
      SELECT
        #{klass.table_name}.*
      FROM
        #{klass.table_name}
      WHERE
        id = #{fork_key}
      SQL
      klass.parse_all(num).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name,self.to_s,options)
    assoc_options[name] = options
    define_method(name) do
      klass = options.model_class
      fork_key = options.foreign_key
      return nil if fork_key.nil?
      nums = DBConnection.execute(<<-SQL)
      SELECT
        #{klass.table_name}.*
      FROM
        #{klass.table_name}
      WHERE
        #{fork_key} = #{self.id}
      SQL
      klass.parse_all(nums)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
