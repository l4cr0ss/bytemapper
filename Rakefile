require 'date'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  desc "Run tests"
end

# Upgrade the gem, bumping its version, its date, rebuilding, and reinstalling.
task :upgrade do |t|
  old_spec = File.open('bytemapper.gemspec').readlines
  new_spec = []

  # Copy over the first line ('Gem::Specficiation.new do... etc')
  new_spec << old_spec.shift

  # Save the tail for later ('end')
  tail = old_spec.pop

  # Walk through the remaining key/val pairs.
  old_spec.each do |l|
    key, value = l.strip.split('=').map(&:strip)
    case key.strip.split('.').last
    when 'version'
      # Extract the current (now old) version numbers and bump as appropriate.
      OLD_VERSION = value.lstrip.delete("'")
      v = OLD_VERSION.split('.').map(&:to_i)
      if v[-1] == 99 && v[-2] == 99
        v[0] += 1; v[1] = 0; v[2] = 0
      elsif v[-2] == 99
        v[1] += 1; v[2] = 0
      else
        v[2] += 1
      end
      NEW_VERSION = "'#{v.join('.')}'"
      v = NEW_VERSION
    when 'date'
      # Set the date to today's date
      v = "'#{Time.now.strftime("%Y-%m-%d")}'"
    else
      # Otherwise keep the previous value
      v = value
    end
    # Stuff it into the new gemspec
    new_spec << "  #{key} = #{v}\n"
  end

  # Move it and the old gemfile into ./old
  system("mv bytemapper.gemspec bytemapper-#{OLD_VERSION}.gemspec")
  system("mv *.gem* ./old")

  # Open up the new gemspec
  File.open('bytemapper.gemspec','w') do |f|
    # Write out the gemspec
    new_spec.each do |line|
      f << line
    end
    # Write out the tail ('end')
    f << tail
  end

  # Build the new gem and install it 
  system("gem build && gem install bytemapper")

  # Push the new gem to rubygems
  system("gem push bytemapper-#{NEW_VERSION}.gem")
end

task :default => :test
