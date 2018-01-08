# This class is inherited by the has_many and has_many_and_belongs_to_many association classes
module DuckRecord::Associations::Builder # :nodoc:
  class CollectionAssociation < Association #:nodoc:
    CALLBACKS = [:before_add, :after_add, :before_remove, :after_remove]

    def self.valid_options(_options)
      super + [:index_errors] + CALLBACKS
    end

    def self.define_callbacks(model, reflection)
      super
      name    = reflection.name
      options = reflection.options
      CALLBACKS.each { |callback_name|
        define_callback(model, callback_name, name, options)
      }
    end

    def self.define_extensions(model, name)
      if block_given?
        extension_module_name = "#{model.name.demodulize}#{name.to_s.camelize}AssociationExtension"
        extension = Module.new(&Proc.new)
        model.parent.const_set(extension_module_name, extension)
      end
    end

    def self.define_callback(model, callback_name, name, options)
      full_callback_name = "#{callback_name}_for_#{name}"

      # TODO : why do i need method_defined? I think its because of the inheritance chain
      model.class_attribute full_callback_name unless model.method_defined?(full_callback_name)
      callbacks = Array(options[callback_name.to_sym]).map do |callback|
        case callback
        when Symbol
          ->(_method, owner, record) { owner.send(callback, record) }
        when Proc
          ->(_method, owner, record) { callback.call(owner, record) }
        else
          ->(method, owner, record) { callback.send(method, owner, record) }
        end
      end
      model.send "#{full_callback_name}=", callbacks
    end
  end
end