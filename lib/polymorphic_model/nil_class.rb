class PolymorphicModel::NilClass
  def initialize(model_class, polymorphic_column, type)
    instance_eval %[
      def create(defaults={})
        args = {:#{polymorphic_column} => "#{type}"}.merge(defaults)
        #{model_class.name}.create(args)
      end

      def create!(defaults={})
        args = {:#{polymorphic_column} => "#{type}"}.merge(defaults)
        #{model_class.name}.create!(args)
      end

      def new(defaults={})
        args = {:#{polymorphic_column} => "#{type}"}.merge(defaults)
        #{model_class.name}.new(args)
      end
    ]
  end
  
  def ===(other)
    other === nil
  end

  def ==(other)
    other == nil
  end

  def nil?
    return true
  end
end