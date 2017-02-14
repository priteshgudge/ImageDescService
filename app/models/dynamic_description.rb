class DynamicDescription < ActiveRecord::Base
  audited  :allow_mass_assignment => true
  validates :body, :length => { :minimum => 0, :maximum => 16384, :allow_blank => true } 
  validates :dynamic_image_id, :presence => true

  belongs_to :dynamic_image
  belongs_to :book
  belongs_to :submitter, :class_name => 'User', :foreign_key => :submitter_id
  before_save :remove_body_tag
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
  accepts_nested_attributes_for :dynamic_image, :allow_destroy => true
  
  # index_name 'dynamic_description'
  # TO RUN THE INDEX: bundle exec rake environment tire:import CLASS='DynamicDescription' FORCE=true --trace
  
  # tire do
  #   mapping do
  #     indexes :body, :type => 'string'
  #   end
  # end
  
  settings :analysis => {
                      poet_analyzer: {
                         tokenizer: "standard",
                         # note, this lowercase filter is now redundant with the ElasticSearchable.ascii_folding logic
                         filter: ["standard","lowercase"],
                         char_filter: 'html_strip'
                       }
            }  do
    mapping do
      indexes :is_not_deleted, :as => 'DynamicDescription.connection.select_value("select (select id from books b where b.deleted_at is null limit 1) = dynamic_descriptions.book_id from dynamic_descriptions where id = #{self.id}")'
      indexes :submitter_by, :as => 'DynamicDescription.connection.select_value("select user.id from users user, dynamic_descriptions dyn_des where dyn_des.submitter_id = user.id and user.deleted_at is null and dyn_des.id = #{self.id}")' 
      indexes :image_type, :as => 'DynamicDescription.connection.select_value("select dynamic_image.image_category_id from dynamic_images dynamic_image, dynamic_descriptions dyn_des where dyn_des.dynamic_image_id = dynamic_image.id and dyn_des.id = #{self.id}")'      
      indexes :dynamic_image_id, :type => 'integer'  
      indexes :isbn, :type => 'string', :as => 'DynamicDescription.connection.select_value("select book.isbn from books book, dynamic_descriptions dyn_des where dyn_des.book_id = book.id  and dyn_des.id = #{self.id}")'
      indexes :title, :type => 'string', :as => 'DynamicDescription.connection.select_value("select book.title from books book, dynamic_descriptions dyn_des where dyn_des.book_id = book.id and dyn_des.id = #{self.id}")'
      indexes :authors, :type => 'string', :as => 'DynamicDescription.connection.select_value("select book.authors from books book, dynamic_descriptions dyn_des where dyn_des.book_id = book.id and dyn_des.id = #{self.id}")'
      indexes :body, :type => 'string'
      indexes :dynamic_description_library_id, :as => 'DynamicDescription.connection.select_value("select book.library_id from books book, dynamic_descriptions dyn_des where dyn_des.book_id = book.id and dyn_des.id = #{self.id}")'
      indexes :is_last_approved, :as => 'DynamicDescription.connection.select_value("select (select id from dynamic_descriptions inner_dd where inner_dd.dynamic_image_id = dynamic_descriptions.dynamic_image_id and date_approved is not null order by date_approved desc limit 1) = dynamic_descriptions.id from dynamic_descriptions where id = #{self.id}")'
    end
  end
  
  
  def as_json(options={})
    { :body => body # just use the attribute when no helper is needed
    }
  end
  
  def remove_body_tag
     self.body.gsub!(/&lt;body&gt;/i, '')
     self.body.gsub!(/&lt;\/body&gt;/i, '')
     self.body.gsub!(/&nbsp;/i , '&#160') 
  end
  
  def submitter_name
    if submitter 
      if !submitter.full_name.blank?
        submitter.full_name
      elsif !submitter.username.blank?
        submitter.username
      else 
        submitter.email
      end
    end
  end

  def description_history
     audits.map {|changes| changes.audited_changes['body']}
  end
end