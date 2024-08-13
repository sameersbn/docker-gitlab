#!/usr/bin/env ruby

require "optparse"
require "set"

# sameersbn/docker-gitlab
# Ruby script to configure feature flags via CLI
# Intended to be executed in the context of Rails Runner of Gitlab application
# (to get valid "Feature" module, defined in (gitlab root)/lib/feature.rb)
# https://guides.rubyonrails.org/command_line.html#bin-rails-runner
#   bundle exec rails runner <path to this script> -- --enable <enable target> --disable <disable target>

class FeatureFlagCLI
  def available_feature_flags()
    # Feature flag lists are stored in (Gitlab root directory)/config/feature_flags/
    # We can get the directory by accessing "root" property of "Gitlab" Module
    # (may returns /home/git/gitlab for sameersbn/docker-gitlab)
    feature_flag_yamls = Dir.glob("#{Gitlab.root}/config/feature_flags/**/*.yml")

    if Gitlab.ee?
      feature_flag_yamls.concat(Dir.glob("#{Gitlab.root}/ee/config/feature_flags/**/*.yml"))
    end if

    list = feature_flag_yamls.map { |p| File.basename(p, File.extname(p)) }
    list
  end

  def parse_options(argv = ARGV)
    op = OptionParser.new

    opts = {
      to_be_disabled: [],
      to_be_enabled: [],
    # TODO support "opt out", "opt out removed"
    # to_be_opted_out: [],
    # opt_out_removed: [],
    }

    op.on("-d", "--disable feature_a,feature_b,feature_c", Array, "comma-separated list of feature flags to be disabled (defaults: ${opts[:to_be_disabled]})") { |v|
      opts[:to_be_disabled] = v.uniq
      puts "- Specified feature flags to be disabled"
      puts opts[:to_be_disabled].map { |f| format("--- %<opt>s", opt: f) }
    }
    op.on("-e", "--enable feature_a,feature_b,feature_c", Array, "comma-separated list of feature flags to be enabled (defaults: ${opts[:to_be_enabled]})") { |v|
      opts[:to_be_enabled] = v.uniq
      puts "- Specified feature flags to be enabled"
      puts opts[:to_be_enabled].map { |f| format("--- %<opt>s", opt: f) }
    }

    begin
      args = op.parse(argv)
      succeed = true
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
      puts e.message
      puts op.help
      succeed = false
    end

    [succeed, opts, args]
  end

  def run
    succeed, opts, args = parse_options
    if succeed
      available_flags = self.available_feature_flags
      disable_targets = available_flags & opts[:to_be_disabled]
      enable_targets = available_flags & opts[:to_be_enabled]

      disable_targets.each do |feature|
        Feature.disable(feature)
      end

      enable_targets.each do |feature|
        Feature.enable(feature)
      end

      invalid_enable_targets = opts[:to_be_enabled] - enable_targets
      invalid_disable_targets = opts[:to_be_disabled] - disable_targets
      invalid_targets = invalid_disable_targets | invalid_enable_targets
      if invalid_targets.length > 0
        puts "- Following flags are probably invalid and have been ignored"
        puts invalid_targets.map { |f| format("--- %<name>s", name: f) }
      end
    end

    Feature.all
  end
end

features = FeatureFlagCLI.new.run
puts features.map { |f|
  format("- feature %<name>s : %<state>s", name: f.name, state: f.state)
}
