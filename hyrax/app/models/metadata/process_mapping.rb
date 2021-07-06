module Metadata
  module ProcessMapping
    def process_mapping(xml, field, mapping)
      if mapping.present?
        if mapping.is_a?(Array)
          mapping.each do |mapping_item|
            # recurse and process each item in the array
            process_mapping(xml, field, mapping_item)
          end

        elsif mapping.is_a?(Hash)
          if mapping[:field].present?
            Array.wrap(self[mapping[:field]]).each do |unparsed_value|
              value = self.send(mapping[:'function'], unparsed_value, mapping[:'argument'] || '.')
              xml.tag! field, value if value.present?
            end
          elsif mapping[:function].present?
            puts "Calling #{mapping[:'function']} with params"
            value = self.send(mapping[:'function'], field, xml)
          else
            puts "WARNING: mapping #{mapping.inspect} is ignored"
          end

        elsif mapping.is_a?(String)
          Array.wrap(self[mapping]).each do |value|
            xml.tag! field, value
          end
        end

      end
    end
  end
end