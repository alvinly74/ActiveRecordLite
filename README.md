ActiveRecord Lite

It's like ActiveRecord, but lite.

ActiveRecord is an ORM system for Ruby on Rails.
it's primary functions include Model persistence, querying, and association.

I created this as a means to further understand what goes on in the background of
ActiveRecord.


# Features:

* SQLObject
  * #columns returns column titles as an array of symbols.
  * #finalize! creates getter and setter methods for columns
  * #table_name= changes the table name
  * #table_name returns the table name
  * #all returns all of the same SQLObjects
  * #parse_all returns SQLObjects of your result
  * #find returns the SQLObject whose ID matches it's argument
  * #initialize initializes the SQLObject and populates it's columns.
  * #attributes returns it's attributes or a new hash
  * #attribute_values returns all of the SQLObject values
  * #insert creates a new SQLObject in the database
  * #update updates the record in the database
  * #save determines whether to create, or update the record into the database.
* Searchable module
  * #where takes in a hash and returns SQLObjects that match it's params
* Associable Module
  * #belongs_to returns another SQLObject whose ID matches itself's foreign key
  * #has_many returns multiple SQLObjects whose foreign key matches itself's ID
  * #has_one_through traverses through one SQLObject's belongs_to, to one of it's belongs_to.
