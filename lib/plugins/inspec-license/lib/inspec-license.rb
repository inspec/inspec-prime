module InspecPlugins
  module License
    class Plugin < ::Inspec.plugin(2)
      include Inspec::Dist
      plugin_name :"inspec-license"

      if EXEC_NAME == "inspec"
        cli_command :license do
          require_relative "inspec-license/cli"
          InspecPlugins::License::CLI
        end
      end
    end
  end
end
