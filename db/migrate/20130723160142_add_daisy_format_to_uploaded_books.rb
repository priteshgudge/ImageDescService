class AddDaisyFormatToUploadedBooks < ActiveRecord::Migration
  def self.up
      execute "update books
         set file_type = 'Daisy'
         where 
         file_type is null";
  end

  def self.down
  end
end
