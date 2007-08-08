module ExemplarBuilder
  def exemplify(klass, options = {})
    count_var_name = "@@#{klass.to_s.underscore}_exemplar_count"
    klass.send :class_variable_set, count_var_name, 0
    
    (class << klass; self; end).class_eval do
      default_exemplar = klass.new options
      yield(default_exemplar) if block_given?
      
      define_method(:exemplar) do |*overrides|
        class_variable_set count_var_name, (class_variable_get(count_var_name) + 1)
        default_exemplar.attributes = *overrides
        default_exemplar
      end
      
      define_method(:create_exemplar) do |*overrides|
        returning(exemplar(*overrides)) {|e| e.save }
      end
      
      define_method(:create_exemplar!) do |*overrides|
        returning(exemplar(*overrides)) {|e| e.save! }
      end
    end
  end
end