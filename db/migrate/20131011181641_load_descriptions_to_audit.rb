class LoadDescriptionsToAudit < ActiveRecord::Migration
  def self.up    
    
    dynamic_descriptions = DynamicDescription.all

    dynamic_descriptions.each do |dyn_description|
        simple = SimpleAudit.new
        simple.audit_source = 'diagram'    
        simple.meta_data << ['ID', dyn_description.id]
        simple.meta_data << ['body', dyn_description.body]
        simple.meta_data << ['is_current', dyn_description.is_current]
        simple.meta_data << ['date_approved', dyn_description.date_approved]
        simple.meta_data << ['dynamic_image_id', dyn_description.dynamic_image_id]
        simple.meta_data << ['created_at', dyn_description.created_at]
        simple.meta_data << ['updated_at', dyn_description.updated_at]
        simple.meta_data << ['book_id', dyn_description.book_id]
        simple.meta_data << ['summary', dyn_description.summary]
        simple.meta_data << ['simplified_language_description', dyn_description.simplified_language_description]
        simple.meta_data << ['target_age_start', dyn_description.target_age_start]
        simple.meta_data << ['target_age_end', dyn_description.target_age_end]
        simple.meta_data << ['target_grade_start', dyn_description.target_grade_start]
        simple.meta_data << ['target_grade_end', dyn_description.target_grade_end]
        simple.meta_data << ['description_quality', dyn_description.description_quality]
        simple.meta_data << ['submitter_id', dyn_description.submitter_id]
        simple.meta_data << ['language', dyn_description.language]
        simple.meta_data << ['repository', dyn_description.repository]
        simple.meta_data << ['credentials', dyn_description.credentials]
        simple.meta_data << ['annotation', dyn_description.annotation]
        simple.meta_data << ['tactile_src', dyn_description.tactile_src]
        simple.meta_data << ['tactile_tour', dyn_description.tactile_tour]
        simple.meta_data << ['simplified_image_src', dyn_description.simplified_image_src]
        simple.meta_data << ['simplified_image_tour', dyn_description.simplified_image_tour]
        simple.meta_data << ['repository', dyn_description.repository]
        
       audit_record = Audited::Adapters::ActiveRecord::Audit.new(:action => 'create', :audited_changes => simple, :created_at => dyn_description.created_at)
       audit_record.auditable_type = 'DynamicDescription'
       audit_record.auditable_id = dyn_description.id
       audit_record.save :validate => false                              
     end
     
     dynamic_images = DynamicImage.all 
     dynamic_images.each do | image| 
       dynamic_descriptions = DynamicDescription.where(:dynamic_image_id => image.id).order('created_at asc').all
       dynamic_descriptions.pop #remove the last description
       if !dynamic_descriptions.empty?
          dynamic_descriptions.each do |dy_image|
             dy_image.destroy
          end
       end
     end
  
  end

  def self.down

  end
end
