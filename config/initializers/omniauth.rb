Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], {
    scope: "userinfo.email, userinfo.profile",
    prompt: "select_account", # 👈 esta línea fuerza el cambio de cuenta. Si pongo "select_account consent", el consent obliga preguntar.
    access_type: 'online',

    image_aspect_ratio: "square",
    image_size: 50,

    include_granted_scopes: 'true'
  }
  OmniAuth.config.allowed_request_methods = [:post, :get]
  OmniAuth.config.silence_get_warning = true
end
