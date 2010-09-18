class Tableless < ActiveRecord::Base
#----------------------------------------------------
# create an array of columns
#----------------------------------------------------
  def self.columns()
    @columns ||= [];
  end
#----------------------------------------------------
# add new column to columns array
#----------------------------------------------------
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s,
    default,
    sql_type.to_s,
    null)
  end
#----------------------------------------------------
# override the save method to prevent exceptions
#----------------------------------------------------
  def save(validate = true)
    validate ? valid? : true
  end
end #class
