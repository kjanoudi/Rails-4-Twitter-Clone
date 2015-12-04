class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from StandardError, with: :dispatch_error unless Rails.env.development?

  def dispatch_error(exception)
    case exception
    when ActiveRecord::RecordNotFound, ActionController::RoutingError
      render_404(exception)
    else
      render_500(exception)
    end
  end

  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception} #{exception.message}"
    end
    render template: "errors/error_404", status: 404, layout: 'application'
  end

  def render_500(exception = nil)
    if exception
      logger.info "Rendering 500 with exception: #{exception.inspect}"
    end
    render template: "errors/error_500", status: 500, layout: 'application'
  end

  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:slug, :name, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) << :name
  end
  
end
