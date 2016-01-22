# Be sure to restart your server when you modify this file.

FantasyEvaluator::Application.config.session_store :cookie_store, key: "fantasy-evaluator-session#{if (false == Rails.env.production?); "-#{Rails.env}"; end}"
