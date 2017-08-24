require 'opennebula/document_pool_json'

module OpenNebula
  class ResourceDocumentPool < DocumentPoolJSON
    # Using an unlikely number to avoid collisions
    DOCUMENT_TYPE = 999

    # @see `::OpenNebula::DocumentPoolJSON`
    def factory(element_xml)
      s_template = ResourceDocument.new(element_xml, @client)
      s_template.load_body
      s_template
    end

    def empty_document
      ResourceDocument.new(ResourceDocument.build_xml, @client)
    end

    def include_name?(resource_document_name)
      detect { |rd| rd['NAME'] == resource_document_name }
    end
  end
end
