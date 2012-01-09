module Citier
  module ClassMethods
    # any method placed here will apply to classes
    def acts_as_citier(options = {})
      set_acts_as_citier(true)

      # Option for setting the inheritance columns, default value = 'type'
      db_type_field = (options[:db_type_field] || :type).to_s

      #:table_name = option for setting the name of the current class table_name, default value = 'tableized(current class name)'
      table_name = (options[:table_name] || self.name.tableize.gsub(/\//,'_')).to_s

      self.inheritance_column = "#{db_type_field}"

      if(self.superclass!=ActiveRecord::Base)
        # Non root-class

        citier_debug("Non Root Class")
        citier_debug("table_name -> #{table_name}")

        # Set up the table which contains ALL attributes we want for this class
        self.table_name = "view_#{table_name}"

        citier_debug("tablename (view) -> #{self.table_name}")

        # The the Writable. References the write-able table for the class because
        # save operations etc can't take place on the views
        self.const_set("Writable", create_class_writable(self))
        
        after_initialize do
          self.id = nil if self.new_record? && self.id == 0
        end

        # Add the functions required for children only
        send :include, Citier::ChildInstanceMethods
      else
      # Root class

        citier_debug("Root Class")

        self.table_name = "#{table_name}"

        citier_debug("table_name -> #{self.table_name}")

        # Add the functions required for root classes only
        send :include, Citier::RootInstanceMethods
      end
    end
  end
end
