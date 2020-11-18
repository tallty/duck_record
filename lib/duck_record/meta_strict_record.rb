class MetaStrictRecord < DuckRecord::Base
  attr_accessor :raw_attributes

  def serializable_hash(options = {})
    options = (options || {}).reverse_merge include: self.class._embeds_reflections.keys
    super options
  end

  class << self
    def _embeds_reflections
      _reflections.select { |_, v| v.is_a? DuckRecord::Reflection::EmbedsAssociationReflection }
    end

    def dump(obj)
      serializable_hash =
        if obj.respond_to?(:serializable_hash)
          obj.serializable_hash
        elsif obj.respond_to?(:to_hash)
          obj.to_hash
        else
          raise ArgumentError, "`obj` required can be cast to `Hash` -- #{obj.class}"
        end.stringify_keys
      return serializable_hash
    end

    def load(hash)
      case hash
      when Hash
        record = new hash
        record.raw_attributes = hash.with_indifferent_access
        return record
      else
        new
      end
    end
  end
end

