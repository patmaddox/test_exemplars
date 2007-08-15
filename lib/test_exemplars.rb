module ExemplarBuilder
  def exemplify(klass, options = {})
    count_var_name = "@@#{klass.to_s.underscore}_exemplar_count"
    klass.send :class_variable_set, count_var_name, 0
    
    class_auto_field_name = "@@#{klass.to_s.underscore}_exemplar_auto_field"
    klass.send :class_variable_set, class_auto_field_name, options.delete(:auto_id)
    
    (class << klass; self; end).class_eval do
      default_exemplar = klass.new options
      yield(default_exemplar) if block_given?
      
      define_method(:exemplar) do |*overrides|
        new_exemplar = default_exemplar.clone
        
        class_variable_set count_var_name, (class_variable_get(count_var_name) + 1)
        if class_variable_get(class_auto_field_name)
          new_exemplar.send "#{class_variable_get(class_auto_field_name)}=", "#{klass}#{class_variable_get(count_var_name)}"
        end
        
        new_exemplar.attributes = *overrides
        new_exemplar
      end
      
      define_method(:create_exemplar) do |*params|
        overrides = *params
        perform_validation = true
        if overrides && overrides.has_key?(:perform_validation)
          perform_validation = !!overrides.delete(:perform_validation)
        end
        returning(exemplar(overrides)) {|e| e.save perform_validation }
      end
      
      define_method(:create_exemplar!) do |*overrides|
        returning(exemplar(*overrides)) {|e| e.save! }
      end
    end
  end
end