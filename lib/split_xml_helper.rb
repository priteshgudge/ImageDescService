module SplitXmlHelper
  class AbstractNodeTreeBuilder < Nokogiri::XML::SAX::Document

    attr_accessor :root, :active_element, :num_images

    def initialize
      super()
      @num_images = 0
    end

    def characters string
      # the string passed to characters is unescaped.  If this is not CDATA, let's re-escape it
      string = string.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;") if string && !(string =~ /$\!\[CDATA\[/)
        
      @active_element.add_child(TextNode.new(string))
    end

    def end_element name
      @active_element.is_closed=true
      end_element_post_processing name
      @active_element = @active_element.parent
    end

    def start_element name, attrs = []
      if name == "img"
        @num_images += 1
      end

      e = create_element_node(name, attrs)
      if @root == nil
        @root = e
      else
        @active_element.add_child(e)
      end
      @active_element = e
    end

    def create_element_node name, attrs
      ElementNode.new(name, attrs)
    end


  end

  class DTBookSplitter < AbstractNodeTreeBuilder

    LEVEL_BOUNDARY_TAGS = %w(level level1 level2 level3 level4 level5 level6 pagenum)

    @segments #List<String>
    @target_size #int

    def initialize target_size
      super()
      @target_size = target_size
      @segments = Array.new
    end

    def end_document
      store_segment
    end

    def end_element_post_processing name
      if LEVEL_BOUNDARY_TAGS.include?(name) || (name == 'section' && @active_element.id_attribute_value.present? && LEVEL_BOUNDARY_TAGS.any?{|tag_name| (@active_element.id_attribute_value =~ /^#{tag_name}/) == 0})
       
        if should_split
          active_element.include_in_scoop=false
          store_segment
          active_element.include_in_scoop=true
          self.num_images= 0
        end
      end
    end

    def should_split
      num_images > @target_size
    end

    def segments
      @segments
    end

    def store_segment
      @segments << root.scoop
    end

  end

  class AbstractScoopableNode

    attr_accessor :parent, :include_in_scoop, :is_closed


    def initialize
      @include_in_scoop = true
      @is_closed = false
    end

    def scoop
      render_content
    end

    def path
      s = self
      result = "/" + s.path_fragment
      while s.parent do
        s = s.parent
        result.insert(0, s.path_fragment())
        result.insert(0, "/")
      end
      result
    end

    def escape_attr s
      s.gsub!("&", "&amp;")
      s.gsub!("<", "&lt;")
      s.gsub!(">", "&gt;")
      
      if s.include?('"')
        s.gsub!('"', "&quot;")
      else
        s
      end
    end

  end

  class TextNode < AbstractScoopableNode
    @text

    def initialize text
      super()
      @text = text
      is_closed=true
      include_in_scoop=true
    end

    def render_content
      @text
    end

    def path_fragment
      ""
    end

    def children?
      false
    end

    def children
      nil
    end

    def add_child child
      nil
    end

    def remove_child child
      nil
    end

  end

  class ElementNode < AbstractScoopableNode
    HEAD_PATH = "/dtbook/head"

    LENGTH_SELF_TERMINATOR = 2
    LENGTH_CLOSING_BRACKETS = 3
    LENGTH_ATTRIBUTE_QUOTING = 4

    @name #string
    @attribute_names #String[]
    @attribute_values #String[]
    @children #List<AbstractScoopableNode>
    
    @id_attribute_value 
    def id_attribute_value
      @id_attribute_value 
    end

    def initialize name, attributes
      super()
      @name = name
      @attribute_names = Array.new
      @attribute_values = Array.new
      if attributes.size > 0
        i = 0
        attributes.each do |element|
          @attribute_names[i] = element[0]
          @attribute_values[i] = escape_attr(element[1])
          @id_attribute_value = @attribute_values[i] if @attribute_names[i].try(:downcase) == 'id'
          i += 1
        end
        
      end
      @children = Array.new
    end

    def render_content
      if children?
        result = String.new
        remove_after_scoop = Array.new
        result << render_open_tag
        @children.each do |s|
          if s.include_in_scoop
            result << s.scoop
            if s.is_closed && (s.is_a?(TextNode) || (! s.path.start_with?(HEAD_PATH)))
              remove_after_scoop << s
            end
          end
        end
        result << render_close_tag

        #cleanup
        remove_after_scoop.each do |r|
          remove_child(r)
        end

        result
      else
        render_open_tag_and_terminate true
      end

    end


    def path_fragment
      @name
    end

    def children?
      @children.length > 0
    end

    def children
      @children
    end

    def add_child child
      @children << child
      child.parent = self
      child
    end

    def remove_child child
      @children.delete child
      child.parent = nil
      child
    end

    def attribute_value name
      index = find_attribute_index name
      if index == -1
        nil
      else
        @attribute_values[index]
      end
    end

    def set_attribute_value name, value
      index = find_attribute_index name
      if index != -1
        @attribute_values[index] = value
      end
    end


    private

    def find_attribute_index name
      result = -1
      arr_size = @attribute_names.length
      (0..arr_size).each { |i|
        if name == @attribute_names[i]
          result = i
          break
        end
      }
      result
    end

    def render_open_tag
      render_open_tag_and_terminate(false)
    end

    def render_open_tag_and_terminate self_terminate
      result = "<"
      result << @name

      number_of_attributes = @attribute_names.length
      (0..number_of_attributes).each { |i|
        result << " "
        unless @attribute_names[i].nil?
          result << @attribute_names[i]
          result << "=\""
          unless @attribute_values[i].nil?
            result << @attribute_values[i]
          end
          result << "\""
        end
      }
      if self_terminate
        result << " /"
      end
      result << ">"
      result
    end

    def render_close_tag
      "</" + @name + ">"
    end


  end
end