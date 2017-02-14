module DaisyUtils

  EXPECTED_DTD_FILES = ['dtbook-2005-2.dtd', 'dtbook-2005-3.dtd']

  def valid_daisy_zip?(file)
    DaisyUtils.valid_daisy_zip?(file)
  end
  
  def self.valid_daisy_zip?(file)
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if EXPECTED_DTD_FILES.include? entry.name
            return true
          end
        end
      end
    return false
  end
  
  def self.extract_book_uid(doc)
    xpath_uid = "//xmlns:meta[@name='dtb:uid']"
    matches = doc.xpath(doc, xpath_uid)
    if matches.size != 1
      raise MissingBookUIDException.new
    end
    node = matches.first
    return node.attributes['content'].content.gsub(/[^a-zA-Z0-9\-\_]/, '-')
  end

  def self.extract_book_title(doc)
    xpath_title = "//xmlns:meta[@name='dc:Title']"
    matches = doc.xpath(doc, xpath_title)
    if matches.size != 1
      return ""
    end
    node = matches.first
    return node.attributes['content'].content
  end

  def caller_info
    return "#{request.remote_addr}"
  end

  def get_contents_xml_name(book_directory) 
    DaisyUtils.get_contents_xml_name(book_directory)
  end
  
  def self.get_contents_xml_name(book_directory) 
    return Dir.glob(File.join(book_directory, '*.xml'))[0]
  end
  
  def self.get_opf_name(book_directory)
    return Dir.glob(File.join(book_directory, '*.opf'))[0]
  end
  
  def get_opf_from_dir(book_directory)
    DaisyUtils.get_opf_from_dir(book_directory)
  end
  
  def self.get_opf_from_dir (book_directory)
    opf_filename = get_opf_name(book_directory)
    File.read(opf_filename)
  end
  
  def extract_images_prod_notes_for_daisy doc
      prodnotes = doc.xpath("//xmlns:imggroup//xmlns:prodnote")
      @prodnotes_hash = Hash.new()
      prodnotes.each do |node|
        @prodnotes_hash[node['imgref']] = node.inner_text
      end
      images = nil;
      
      captions = doc.xpath("//xmlns:imggroup//xmlns:caption")
      @captions_hash = Hash.new()
      captions.each do |node|
        @captions_hash[node['imgref']] = node.inner_text
      end
      captions = nil;

      images = doc.xpath("//xmlns:img")
      @num_images = images.size()
      @alt_text_hash = Hash.new()
      images.each do |node|
        alt_text =  node['alt']
        id = node['id']
        if alt_text.size > 1
          @alt_text_hash[id] = alt_text
        end
      end
      images = nil;

      maths = doc.xpath('//mathml:math', 'mathml' => 'http://www.w3.org/1998/Math/MathML')
      #maths = doc.css("math")
      @num_maths = maths.size()
      @maths_hash = Hash.new()
      maths.each_with_index do |node, index|
        @maths_hash[index] = node.to_s
      end
      maths = nil;
  end
  
end