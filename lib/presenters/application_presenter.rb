# frozen_string_literal: true

class ApplicationPresenter
  attr_reader :object

  def initialize(object)
    @object = object
  end

  private

  def method_missing(method, *args, &block)
    if object.respond_to?(method)
      object.public_send(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    super || object.respond_to?(method)
  end
end
