class ActiveAdmin::Views::Pages::Base < Arbre::HTML::Document

  private

  # Renders the content for the footer
  def build_footer
    render "shared/footer"
  end

  def build_header
  	render "shared/header"
  end
end

