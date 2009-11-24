require 'spec'
require 'spec/rails/mocks'

module Spec
  module Rails
    module Mocks
      
      class InvalidPolymorphicModelTypeError < Exception; end
      
      def mock_polymorphic_model(model_class, model_type, options_and_stubs={})
        raise InvalidPolymorphicModelTypeError unless model_class.types.include?(model_type)
        if block_given?
          m = mock_model(model_class, options_and_stubs, &block)
        else
          m = mock_model(model_class, options_and_stubs)
        end

        model_class.types.each do |t|
          m.stub!(:"#{t}?").and_return(t == model_type ? true : false)
        end  
        polymorphic_column = model_class.instance_eval { @_polymorphic_column }
        m.stub!(polymorphic_column).and_return(model_type.to_s)
        return m 
      end
    end
  end
end