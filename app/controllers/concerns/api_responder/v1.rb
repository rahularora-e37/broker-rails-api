module ApiResponder
  # Api V1 lib to deal with some responses
  module V1
    extend ActiveSupport::Concern

    PARAMS_BLACKLIST = %i(controller action password access_token).freeze

    included do
      rescue_from 'ActiveRecord::RecordNotFound',
                  with: :return_404
      rescue_from 'ActionController::ParameterMissing',
                  'ActionController::UnpermittedParameters',
                  'ActiveRecord::RecordInvalid',
                  'Lim::Errors::AasmInvalid',
                  'Lim::Errors::AvailabilityError',
                  with: :return_422
      rescue_from 'Lim::Errors::MissingHeaderError',
                  with: :return_400
    end

    def api_response(options = {})
      options.reverse_merge!(data: {}, errors: {}, meta: {})
      options[:meta][:api_version] ||= '1'
      options[:meta][:deprecation_information] ||= {}
      options
    end

    def error_message(default_message, object)
      object.errors ? object.errors.messages : default_message
    end

    def render_errors_response(errors, status)
      render json: api_response(errors: errors), status: status
    end

    def render_success_response(data, options = {})
      render_options = { json: data }.merge(options)
      render_options[:status] = 200
      render render_options
    end

    private

    def build_errors(message)
      {
        base: [{
          message: message,
          params:  params.except(*PARAMS_BLACKLIST)
        }]
      }
    end

    def render_error_message(message, status)
      errors = build_errors(message)
      render_errors_response(errors, status)
    end

    def log_exception(exception)
      return unless logger.present?
      logger.warn "#{exception.class}: '#{exception.message}'"\
                  " thrown from: #{exception.backtrace[0..10]}"
    end

    def return_400(exception)
      log_exception(exception)
      render_error_message(exception.message, 400)
    end

    def return_401(exception)
      log_exception(exception)
      render_error_message(exception.message, 401)
    end

    def return_404(exception)
      log_exception(exception)
      render_error_message('Resource not found', 404)
    end

    def return_422(exception)
      log_exception(exception)

      errors =
        if exception.respond_to? :record
          translate_exception(exception, :v1)
        else
          build_errors(exception.message)
        end
      render_errors_response(errors, 422)
    end
  end
end
