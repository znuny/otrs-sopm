require 'nokogiri'
require 'base64'
require 'otrs/sopm/version'

# General OTRS class, for later/other purposes maybe. Should handle more OTRS related stuff
class OTRS
  # Handles all SOPM and OPM related stuff
  class SOPM

    attr_reader :sopm
    attr_reader :structure

    # Creates an instance based on a given SOPM file path.
    #
    # @param sopm_file [String] the path to the SOPM file.
    # @return (see #parse)
    def initialize(sopm_file)

      @sopm_file = sopm_file

      sopm_read_handle = File.open(@sopm_file)
      @sopm            = Nokogiri::XML(sopm_read_handle)
      sopm_read_handle.close

      parse
    end

    # Adds a new version and the changelog to the SOPM file.
    #
    # @param version [String] the version number.
    # @param change_log [String] the changelog.
    # @return (see #parse)
    def version(version, change_log)
      
      raise ArgumentError, 'Version has to be a string' unless version.is_a? String 
      raise ArgumentError, 'Change_log hast to be a string' unless change_log.is_a? String 

      # change Version
      @sopm.xpath('/otrs_package/Version').children[0].content = version

      # append ChangeLog
      change_log_nodes = @sopm.xpath('/otrs_package/ChangeLog')
      if change_log_nodes.length == 0
        change_log_nodes = @sopm.xpath('/otrs_package/Framework')
      end

      # remove tabs from ChangeLog
      change_log.gsub!(/\t/, '  ')

      # strip whitespaces
      change_log.strip!

      new_change_log_entry            = Nokogiri::XML::Node.new 'ChangeLog', sopm
      new_change_log_entry['Version'] = version
      new_change_log_entry['Date']    = Time.now
      new_change_log_entry.content    = change_log

      change_log_nodes.first.previous = new_change_log_entry.to_xml + "\n    "

      store
    end

    # Adds the buildhost and builddate to the SOPM file.
    #
    # @param build_host [String] build host on which the OPM file was created.
    # @return (see #parse)
    def add_build_information(build_host)
      raise ArgumentError, 'Build_host has to be a string' unless build_host.is_a? String 

      # add BuildHost
      if @sopm.xpath('/otrs_package/BuildHost').children.length == 0

        new_build_host_entry                                 = Nokogiri::XML::Node.new 'BuildHost', sopm
        new_build_host_entry.content                         = build_host
        @sopm.xpath('/otrs_package/Filelist').first.previous = new_build_host_entry.to_xml + "\n    "
      else
        @sopm.xpath('/otrs_package/BuildHost').children[0].content = build_host
      end

      # add BuildDate
      if @sopm.xpath('/otrs_package/BuildDate').children.length == 0

        new_build_date_entry                                 = Nokogiri::XML::Node.new 'BuildDate', sopm
        new_build_date_entry.content                         = Time.zone.now
        @sopm.xpath('/otrs_package/Filelist').first.previous = new_build_date_entry.to_xml + "\n    "
      else
        @sopm.xpath('/otrs_package/BuildDate').children[0].content = Time.zone.now
      end

      store
    end

    # Adds a new file to the filelist of the SOPM file.
    #
    # @param location [String] the file location.
    # @param permission [Integer] the permissions with which the files should get created.
    # @return (see #parse)
    def add_file( location, permission = 644 )

      files_nodes = @sopm.xpath('/otrs_package/Filelist/File')

      update = true
      files_nodes.each { |files_node|

        next if files_node['Location'] != location
        next if files_node['Permission'] != permission

        update = false

        break
      }

      return if !update

      # append Filelist/File
      new_file_entry               = Nokogiri::XML::Node.new 'File', sopm
      new_file_entry['Permission'] = permission
      new_file_entry['Location']   = location

      files_nodes.last.next = "\n        " + new_file_entry.to_xml

      store
    end

    # Stores the changes to the SOPM file.
    #
    # @return (see #parse)
    def store

      File.open(@sopm_file, 'w') { |file|
        file.write( @sopm.to_xml )
      }

      parse
    end

    # Parses the given SOPM file.
    #
    # @return [Hash] the parsed SOPM structure.
    def parse

      @structure = {}

      # Name
      @structure['name'] = @sopm.xpath('/otrs_package/Name').children[0].content

      # Version
      @structure['version'] = @sopm.xpath('/otrs_package/Version').children[0].content

      # Vendor
      @structure['vendor'] = @sopm.xpath('/otrs_package/Vendor').children[0].content

      # License
      @structure['license'] = @sopm.xpath('/otrs_package/License').children[0].content

      # URL
      # TODO: Remove! URL should be required
      if @sopm.xpath('/otrs_package/URL').children.length > 0
        @structure['url'] = @sopm.xpath('/otrs_package/URL').children[0].content
      end

      # BuildDate
      if @sopm.xpath('/otrs_package/BuildDate').children.length > 0
        @structure['build_date'] = @sopm.xpath('/otrs_package/BuildDate').children[0].content
      end

      # BuildHost
      if @sopm.xpath('/otrs_package/BuildHost').children.length > 0
        @structure['build_host'] = @sopm.xpath('/otrs_package/BuildHost').children[0].content
      end

      # PackageIs* blocks (optional)
      %w(Visible Downloadable Removable).each { |is_type|

        next if @sopm.xpath('/otrs_package/PackageIs' + is_type).children.length == 0

        flag = @sopm.xpath('/otrs_package/PackageIs' + is_type).children[0].content

        is_type.downcase!

        @structure['package_is_' + is_type] = flag == '1' ? true : false
      }

      # ChangeLog (optional)
      change_log_nodes = @sopm.xpath('/otrs_package/ChangeLog')
      if change_log_nodes.length > 0
        @structure['change_log'] = []
        change_log_nodes.each { |change_log_node|

          change_log_entry            = {}
          change_log_entry['version'] = change_log_node['Version']
          change_log_entry['date']    = change_log_node['Date']
          change_log_entry['log']     = change_log_node.children[0].content

          @structure['change_log'].push change_log_entry
        }
      end

      # OS (optional)
      os_nodes = @sopm.xpath('/otrs_package/OS')
      if os_nodes.length > 0
        @structure['os'] = []
        os_nodes.each { |os_node|

          @structure['os'].push os_node.children[0].content
        }
      end

      # Framework
      @structure['framework'] = []
      framework_nodes = @sopm.xpath('/otrs_package/Framework')
      framework_nodes.each { |framework_node|
        @structure['framework'].push framework_node.children[0].content
      }

      # PackageRequired (optional)
      package_required_nodes = @sopm.xpath('/otrs_package/PackageRequired')
      if package_required_nodes.length > 0
        @structure['package_required'] = []
        package_required_nodes.each { |package_required_node|

          package_required_entry            = {}
          package_required_entry['version'] = package_required_node['Version']
          package_required_entry['name']    = package_required_node.children[0].content

          @structure['package_required'].push package_required_entry
        }
      end

      # ModuleRequired (optional)
      module_required_nodes = @sopm.xpath('/otrs_package/ModuleRequired')
      if module_required_nodes.length > 0
        @structure['module_required'] = []
        module_required_nodes.each { |module_required_node|

          module_required_entry            = {}
          module_required_entry['version'] = module_required_node['Version']
          module_required_entry['name']    = module_required_node.children[0].content

          @structure['module_required'].push module_required_entry
        }
      end

      # Description
      @structure['description'] = []
      description_nodes = @sopm.xpath('/otrs_package/Description')
      description_nodes.each { |description_node|

        description_entry             = {}
        description_entry['language'] = description_node['Lang']
        description_entry['text']     = description_node.children[0].content

        @structure['description'].push description_entry
      }

      # Filelist/File
      @structure['files'] = []
      files_nodes = @sopm.xpath('/otrs_package/Filelist/File')
      files_nodes.each { |files_node|

        files_entry               = {}
        files_entry['permission'] = files_node['Permission']
        files_entry['location']   = files_node['Location']

        if files_node['Encode'] == 'Base64'
          files_entry['content'] = Base64.decode64( files_node.children[0].content )
        end

        @structure['files'].push files_entry
      }

      # Code blocks (optional)
      %w(Install Upgrade Reinstall Uninstall).each { |block_type|

        code_block_nodes = @sopm.xpath('/otrs_package/Code' + block_type)

        next if code_block_nodes.length == 0

        # convert to lowercase
        block_type.downcase!

        @structure[ 'code_' + block_type ] = []
        code_block_nodes.each { |code_block_node|

          code_block_entry         = {}
          code_block_entry['type'] = code_block_node['Type']
          code_block_entry['code'] = code_block_node.children[0].content

          # optional
          if code_block_node['Version']
            code_block_entry['version'] = code_block_node['Version']
          end
          if code_block_node['IfPackage']
            code_block_entry['if_package'] = code_block_node['IfPackage']
          end
          if code_block_node['IfNotPackage']
            code_block_entry['if_not_package'] = code_block_node['IfNotPackage']
          end

          @structure[ 'code_' + block_type ].push code_block_entry
        }
      }

      # Intro blocks (optional)
      %w(Install Upgrade Reinstall Uninstall).each { |block_type|

        intro_block_nodes = @sopm.xpath('/otrs_package/Intro' + block_type)

        next if intro_block_nodes.length == 0

        # convert to lowercase
        block_type.downcase!

        @structure[ 'code_' + block_type ] = []
        intro_block_nodes.each { |intro_block_node|

          intro_block_entry          = {}
          intro_block_entry['type']  = intro_block_node['Type']
          intro_block_entry['intro'] = intro_block_node.children[0].content

          # optional
          if intro_block_node['Version']
            intro_block_entry['version'] = intro_block_node['Version']
          end
          if intro_block_node['Lang']
            intro_block_entry['language'] = intro_block_node['Lang']
          end
          if intro_block_node['Title']
            intro_block_entry['title'] = intro_block_node['Title']
          end
          if intro_block_node['Format']
            intro_block_entry['format'] = intro_block_node['Format']
          end

          @structure[ 'code_' + block_type ].push intro_block_entry
        }
      }

      # Database blocks (optional)
      %w(Install Upgrade Reinstall Uninstall).each { |block_type|

        intro_block_nodes = @sopm.xpath('/otrs_package/Database' + block_type)

        next if intro_block_nodes.length == 0

        # convert to lowercase
        block_type.downcase!

        @structure[ 'database_' + block_type ] = []
        intro_block_nodes.each { |intro_block_node|

          @structure[ 'database_' + block_type ].push intro_block_node.children[0].content
        }
      }

      @structure
    end

    # Creates an OPM string out of the SOPM file.
    #
    # @return [String] OPM XML content with Base64 encoded files.
    def opm

      opm = @sopm

      folder = File.dirname(@sopm_file)

      files_nodes = opm.xpath('/otrs_package/Filelist/File')
      files_nodes.each { |files_node|

        file_location = files_node['Location']
        file          = File.open("#{folder}/#{file_location}", 'r')
        file_content  = file.read
        file.close

        files_node['Encode'] = 'Base64'
        files_node.content   = Base64.strict_encode64( file_content )
      }

      opm.to_xml
    end
  end
end
