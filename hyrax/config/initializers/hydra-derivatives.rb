# frozen_string_literal: true
# Monkey-patch hydra-derivatives until we're able to upgrade
Hydra::Derivatives::Processors::Image.class_eval do
  def create_resized_image
    create_image do |xfrm|
      if size
        xfrm.combine_options do |i|
          i.flatten
          i.resize(size)
        end
      end
    end
  end
end