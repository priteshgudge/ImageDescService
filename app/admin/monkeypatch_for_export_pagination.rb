# Workaround for until https://github.com/gregbell/active_admin/issues/2449 is resolved
module ActiveAdmin
  class ResourceController < BaseController
    module DataAccess
      alias original_apply_pagination apply_pagination
      def apply_pagination(chain)
        ["text/csv", "application/xml", "application/json"].include?(request.format) ? chain.limit(10000) : original_apply_pagination(chain)
      end
    end
  end
end