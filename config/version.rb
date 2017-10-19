module ROCCIServer
  MAJOR_VERSION = 2                # Major update constant
  MINOR_VERSION = 0                # Minor update constant
  PATCH_VERSION = 2                # Patch/Fix version constant
  STAGE_VERSION = nil              # use `nil` for production releases

  unless defined?(::ROCCIServer::VERSION)
    VERSION = [
      MAJOR_VERSION,
      MINOR_VERSION,
      PATCH_VERSION,
      STAGE_VERSION
    ].compact.join('.').freeze
  end

  ROCCI_VERSION = ::Occi::Core::VERSION if defined?(::Occi::Core::VERSION)
end
