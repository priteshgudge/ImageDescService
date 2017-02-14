class UpdateAuditDynamicDescribtionId < ActiveRecord::Migration
  def self.up
    #history of description before audit set up
    change_audits = Audited::Adapters::ActiveRecord::Audit.where("audited_changes like ? ", '%SimpleAudit%').all   
    image_id = nil
    
    change_audits.each do |audit|  
      meta_data= audit.audited_changes.meta_data
      
      meta_data.each do |elem| 
        image_id = elem[1] if elem[0] == 'dynamic_image_id'       
      end
      
      if image_id 
        dyn_description = DynamicDescription.where(:dynamic_image_id => image_id).first
        if dyn_description
          audit.auditable_id = dyn_description.id 
        else
          audit.auditable_id = -1
        end
        audit.save 
      end
    end
  end

  def self.down
  end
end
