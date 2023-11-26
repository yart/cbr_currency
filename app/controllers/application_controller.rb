class ApplicationController < ActionController::Base
  def render_404
    render file: 'public/404.html', status: :not_found, layout: false
  end
end
