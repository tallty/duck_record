class MetaRecord < MetaStrictRecord
  def _assign_attribute(k, v)
    if respond_to?("#{k}=")
      public_send("#{k}=", v)
    end
  end
end
