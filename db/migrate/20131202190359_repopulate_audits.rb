require 'yaml'

class RepopulateAudits < ActiveRecord::Migration
  def self.up
  	# empty out the audits table
  	ActiveRecord::Base.connection.execute("TRUNCATE TABLE audits;")
  	puts "Flushed existing audit information."

  	# rebuild audits
  	image_description_ids = self.fetchFinalDescriptionIds
  	puts "Fetched IDs of most up-to-date image descriptions"
  	puts "Found " + image_description_ids.length.to_s + " in total."

  	# loop through descriptions to build audit inserts
  	image_versions = Hash.new
  	fields = [
				"body", 
				"is_current", 
				"date_approved", 
				"dynamic_image_id", 
				"created_at", 
				"updated_at", 
				"book_id", 
				"summary", 
				"simplified_language_description", 
				"target_age_start", 
				"target_age_end", 
				"target_grade_start", 
				"target_grade_end", 
				"description_quality", 
				"language", 
				"repository", 
				"credentials", 
				"annotation", 
				"tactile_src", 
				"tactile_tour", 
				"simplified_image_src", 
				"simplified_image_tour", 
				"submitter_id"
			]

  	descriptions = ActiveRecord::Base.connection.execute("SELECT " + fields.map {|f| 'dynamic_descriptions.' + f }.join(',') + ", users.username FROM dynamic_descriptions LEFT JOIN users ON submitter_id = users.id order by updated_at;")
  	rowcount = descriptions.count
  	puts "Fetched dynamic description records, " + rowcount.to_s + " in total."
  	fieldIndex = descriptions.fields
  	count = 0
    descriptions.each do |d|

    	count = count + 1
		puts count.to_s + "/" + rowcount.to_s

    	if image_description_ids.has_key? d[fieldIndex.index('dynamic_image_id')]
	    	userId = d[fieldIndex.index('submitter_id')]
	    	username = d[fieldIndex.index('username')]
	    	auditTimestamp = d[fieldIndex.index('created_at')]
	    	imageId = d[fieldIndex.index('dynamic_image_id')]
	    	descriptionId = image_description_ids[imageId]

	    	# build audit map
	    	metadata = Hash.new
	    	fields.each do |f|
	    		metadata[f] = d[fieldIndex.index(f)]
			end

			# set create/update field and versions
			if image_versions.has_key? imageId
				action = 'update'
				version = image_versions[imageId] + 1
			else
				action = 'create'
				version = 1
			end

			image_versions[imageId] = version

			puts "Processed " + action + " to version " + version.to_s + " on image " + imageId.to_s

			ActiveRecord::Base.connection.execute DynamicDescription.send(:sanitize_sql_array, ["INSERT INTO audits(auditable_id, auditable_type, user_id, user_type, username, action, audited_changes, version, created_at) " +
				  "VALUES(?, 'DynamicDescription', ?, 'User', ?, ?, ?, ?, ?)", descriptionId, userId, username, action, YAML.dump(metadata), version, auditTimestamp])
		end

	end

	# test to see if we've got audits
	ActiveRecord::Base.connection.execute("select count(0) from audits;").each do |x|
		if x[0] > 0
			puts 'Audit table contains ' + x[0].to_s + " entries; should be safe to delete."
			ActiveRecord::Base.connection.execute DynamicDescription.send(:sanitize_sql_array, ["DELETE FROM dynamic_descriptions WHERE id NOT IN (?)", image_description_ids.values])
  		else
			puts 'Audit table contains no entries. Do not continue with delete.'
		end
		break
	end

  end

  def self.down
  end

  def self.fetchFinalDescriptionIds
  	retVal = Hash.new
  	results = ActiveRecord::Base.connection.execute("select distinct a.dynamic_image_id, (select b.id from dynamic_descriptions as b where b.dynamic_image_id = a.dynamic_image_id order by updated_at desc limit 1) as description_id from dynamic_descriptions as a;")
  	results.each do |r|
  		retVal[r[0]] = r[1]
	end
	retVal
  end
end
