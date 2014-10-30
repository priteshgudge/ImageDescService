module RepositoryChooser
  require 'local_repository'
  require 's3_repository'

  def self.choose klass_name=nil
    if (Rails.env.test? || ((defined? ENV['POET_LOCAL_STORAGE_DIR']) && ENV['POET_LOCAL_STORAGE_DIR'].length > 0)) || (klass_name == LocalRepository.name)
      return LocalRepository
    else
      return S3Repository
    end
  end
end