# Rack attack protection
module Rack
  class Attack
    throttle('req/ip', limit: 360, period: 1.minute, &:ip)

    blocklist('req/no-token') do |req|
      Allow2Ban.filter(req.ip, maxretry: 120, findtime: 1.minute, bantime: 24.hours) do
        req.env[Tokenator::TOKEN_HEADER_KEY].blank?
      end
    end
  end
end

Rack::Attack.throttled_response = lambda do |env|
  now = Time.current
  match_data = env['rack.attack.match_data']

  headers = {
    'X-RateLimit-Limit' => match_data[:limit],
    'X-RateLimit-Remaining' => 0,
    'X-RateLimit-Reset' => now + (match_data[:period] - now.to_i % match_data[:period])
  }

  [429, headers, ['Too Many Requests']]
end

ActiveSupport::Notifications.subscribe('rack.attack') do |_, _, _, _, req|
  case req.env['rack.attack.matched']
  when 'req/ip'
    Rails.logger.warn "[Rack::Attack] Throttling #{req.ip} after #{req.env['rack.attack.match_data'][:count]} requests"
  when 'req/no-token'
    Rails.logger.warn "[Rack::Attack] Blocking #{req.ip} after too many attempts without authorization"
  end
end

Rails.application.config.middleware.use Rack::Attack if Rails.env.production?
