require "inspec/plugin/v1"
require "inspec/base_cli"

module Supermarket
  class SupermarketCLI < Inspec::BaseCLI
    namespace "supermarket"

    # TODO: find another solution, once https://github.com/erikhuda/thor/issues/261 is fixed.
    def self.banner(command, _namespace = nil, _subcommand = false)
      "#{basename} #{subcommand_prefix} #{command.usage}"
    end

    def self.subcommand_prefix
      namespace
    end

    desc "profiles", "list all available profiles in Chef Supermarket"
    supermarket_options
    def profiles
      o = config
      diagnose(o)
      configure_logger(o)

      # display profiles in format user/profile
      supermarket_profiles =  if o["supermarket_url"]
                                Supermarket::API.profiles(o["supermarket_url"])
                              else
                                Supermarket::API.profiles
                              end
      headline("Available profiles:")
      supermarket_profiles.each do |p|
        li("#{p["tool_name"]} #{mark_text(p["tool_owner"] + "/" + p["slug"])}")
      end
    end

    desc "exec PROFILE", "execute a Supermarket profile"
    exec_options
    def exec(*tests)
      o = config
      diagnose(o)
      configure_logger(o)

      # iterate over tests and add compliance scheme
      tests = tests.map { |t| "supermarket://" + t }

      runner = Inspec::Runner.new(o)
      tests.each { |target| runner.add_target(target) }

      exit runner.run
    rescue ArgumentError, RuntimeError, Train::UserError => e
      $stderr.puts e.message
      exit 1
    end

    desc "info PROFILE", "display Supermarket profile details"
    supermarket_options
    def info(profile)
      o = config
      diagnose(o)
      configure_logger(o)

      # check that the profile is available
      supermarket_profiles =  if o["supermarket_url"]
                                Supermarket::API.profiles(o["supermarket_url"])
                              else
                                Supermarket::API.profiles
                              end
      found = supermarket_profiles.select do |p|
        profile == "#{p["tool_owner"]}/#{p["slug"]}"
      end

      if found.empty?
        puts "#{mark_text(profile)} is not available on Supermarket"
        return
      end

      # load details for the specific profile
      info = Supermarket::API.info(profile)
      puts "#{mark_text("name: ")}  #{info["slug"]}"
      puts "#{mark_text("owner:")}  #{info["owner"]}"
      puts "#{mark_text("url:  ")}  #{info["source_url"]}"
      puts
      puts "#{mark_text("description:  ")} #{info["description"]}"
    end
  end

  # register the subcommand to InSpec CLI registry
  Inspec::Plugins::CLI.add_subcommand(SupermarketCLI, "supermarket", "supermarket SUBCOMMAND ...", "Supermarket commands", {})
end
