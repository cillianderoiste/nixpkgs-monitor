module DistroPackage

  # Generic distro package
  class Package
    attr_accessor :internal_name, :name, :version, :url


    def initialize(internal_name, name = internal_name, version = '0', url = "" )
      @internal_name = internal_name
      @name = name.downcase
      @version = version
      @url = url
    end


    def serialize
      return "#{@internal_name} #{@name} #{@version} #{@url}"
    end


    def self.http_agent
      agent = Mechanize.new
      agent.user_agent = 'NixPkgs software update checker'
      return agent
    end

  end


  class Arch < Package

    # FIXME: support multi-output PKGBUILDs
    def self.parse_pkgbuild(entry, path)
      dont_expand = [ 'pidgin' ]
      override = {
        'lzo2'	=> 'lzo',
        'grep'	=> 'gnugrep',
        'make'	=> 'gnumake',
        'gnuplot '	=> 'gnuplot',
        'tar'	=> 'gnutar',
        'grep'	=> 'gnugrep',
        'sed'	=> 'gnused',
        'tidyhtml'	=> 'html-tidy',
        'apache'	=> 'apache-httpd',
        'bzr'	=> 'bazaar',
        'libmp4v2'	=> 'mp4v2',
        '"gummiboot"'	=> 'gummiboot',
        'lm_sensors'	=> 'lm-sensors',
      }

      pkgbuild = File.read(path, :encoding => 'ISO-8859-1') 
      pkg_name = (pkgbuild =~ /pkgname=(.*)/ ? $1 : nil)
      pkg_ver = (pkgbuild =~ /pkgver=(.*)/ ? $1 : nil)

      pkg_name = entry if dont_expand.include? entry
      if pkg_name.include? "("
        puts "skipping #{entry}: unsupported multi-package PKGBUILD"
        return nil
      end
      pkg_name = override[pkg_name] if override[pkg_name]

      pkg_name = $1 if pkg_name =~ /xorg-(.*)/
      pkg_name = $1 if pkg_name =~ /kdeedu-(.*)/
      pkg_name = $1 if pkg_name =~ /kdemultimedia-(.*)/
      pkg_name = $1 if pkg_name =~ /kdeutils-(.*)/
      pkg_name = $1 if pkg_name =~ /kdegames-(.*)/
      pkg_name = $1 if pkg_name =~ /kdebindings-(.*)/
      pkg_name = $1 if pkg_name =~ /kdegraphics-(.*)/
      pkg_name = $1 if pkg_name =~ /kdeaccessibility-(.*)/

      pkg_name = "aspell-dict-#{$1}" if pkg_name =~ /aspell-(.*)/
      pkg_name = "haskell-#{$1}-ghc7.6.3" if pkg_name =~ /haskell-(.*)/
      pkg_name = "ktp-#{$1}" if pkg_name =~ /telepathy-kde-(.*)/

      url = %x(bash -c 'source #{path} && echo $source').split("\n").first
      return Arch.new(entry, pkg_name, pkg_ver, url)
    end


    def self.deserialize(val)
      if val =~/(\S*) (\S*) (\S*) (\S*)/
        return Arch.new($1, $2, $3, $4)
      else
        raise" failed to parse #{val}"
      end
    end


    def self.list
      unless @list
        @list = {}
        File.readlines('arch.cache',:encoding => "ASCII").each do |line|
          package = Arch.deserialize(line)
          @list[package.name] = package
        end
      end

      return @list
    end


    def self.generate_list
      arch_list = {}

      puts "Cloning / pulling repos."
      puts %x(git clone git://projects.archlinux.org/svntogit/packages.git)
      puts %x(cd packages && git pull --rebase)
      puts %x(git clone git://projects.archlinux.org/svntogit/community.git)
      puts %x(cd community && git pull --rebase)
      
      puts "Scanning Arch Core, Extra (packages.git) repositories..."
      Dir.entries("packages").each do |entry|
        next if entry == '.' or entry == '..'

        pkgbuild_name = File.join("packages", entry, "repos", "extra-i686", "PKGBUILD")
        pkgbuild_name = File.join("packages", entry, "repos", "core-i686", "PKGBUILD") unless File.exists? pkgbuild_name

        if File.exists? pkgbuild_name
          package = Arch.parse_pkgbuild(entry, pkgbuild_name)
          arch_list[package.name] = package if package
        end
      end

      puts "Scanning Arch Community repository..."
      Dir.entries("community").each do |entry|
        next if entry == '.' or entry == '..'

        pkgbuild_name = File.join("community", entry, "repos", "community-i686", "PKGBUILD")

        if File.exists? pkgbuild_name
          package = Arch.parse_pkgbuild(entry, pkgbuild_name)
          arch_list[package.name] = package if package
        end
      end

      file = File.open("arch.cache", "w")
      arch_list.each_value do |package|
        file.puts package.serialize
      end
      file.close

      return arch_list
    end

  end


  class Gentoo < Package
    attr_accessor :version_overlay, :version_upstream

    def version
      return version_upstream if version_upstream
      return version_overlay if version_overlay and not(version_overlay.end_with?('9999'))
      return @version
    end


    def serialize
      return "#{super} #{@version_overlay} #{@version_upstream}"
    end


    def self.deserialize(val)
      if val =~/(\S*) (\S*) (\S*) (\S*) (\S*) (\S*)/
        pkg = Gentoo.new($1, $2, $3, $4)
        pkg.version_overlay = $5
        pkg.version_upstream = $6
        return pkg
      else
        raise " failed to parse #{val}"
      end
    end


    def self.list
      unless @list
        @list = {}
        File.readlines('gentoo.cache',:encoding => "ASCII").each do |line|
          package = Gentoo.deserialize(line)
          @list[package.name] = package
        end
      end

      return @list
    end


    def self.generate_list
      gentoo_list = {}

      categories_json = http_agent.get('http://euscan.iksaif.net/api/1.0/categories.json').body
      JSON.parse(categories_json)["categories"].each do |cat|
        puts cat["category"]
        packages_json = http_agent.get("http://euscan.iksaif.net/api/1.0/packages/by-category/#{cat["category"]}.json").body
        JSON.parse(packages_json)["packages"].each do |pkg|
          name = pkg["name"]
          gentoo_list[name] = Gentoo.new(cat["category"] + '/' + name, name) unless gentoo_list[name]
          if pkg["last_version_gentoo"]
            gentoo_list[name].version = pkg["last_version_gentoo"]["version"]
          end
          if pkg["last_version_overlay"]
            gentoo_list[name].version_overlay = pkg["last_version_overlay"]["version"]
          end
          if pkg["last_version_upstream"]
            gentoo_list[name].version_upstream = pkg["last_version_upstream"]["version"]
          end
        end
      end

      file = File.open("gentoo.cache", "w")
      gentoo_list.each_value do |package|
        file.puts package.serialize
      end
      file.close

      return gentoo_list
    end

  end


  # FIXME: nixpkgs often override package versions with suffixes such as -gui
  # which break matching because nixpks keeps only 1 of the packages
  # with the same name
  class Nix < Package

    def version
      @version.gsub(/-profiling$/, "").gsub(/-gimp-2.6.\d+-plugin$/,"")
    end


    def self.instantiate(attr, name)
      url = 'none'
      if %x(nix-instantiate --eval-only --xml --strict -A #{attr}.src.urls /etc/nixos/nixpkgs) =~ /string value="([^"]*)"/
        url = $1
      else 
        puts "failed to get url for #{attr} #{name}"
      end

      if name =~ /(.*?)-([^A-Za-z].*)/
        return Nix.new(attr, $1, $2, url)
      else
        puts "failed to parse name for #{attr} #{name}"
        return nil
      end
    end


    def self.deserialize(val)
      if val =~/(\S*) (\S*) (\S*) (\S*)/
        return Nix.new($1, $2, $3, $4)
      else
        raise" failed to parse #{val}"
      end
    end


    def self.list
      unless @list
        @list = {}
        File.readlines('nix.cache',:encoding => "ASCII").each do |line|
          package = Nix.deserialize(line)
          @list[package.name] = package
        end
      end

      return @list
    end


    def self.generate_list
      blacklist = []
      nix_list = {}

      %x(nix-env -qa '*' --attr-path -I /etc/nixos/|uniq).split("\n").each do|entry|
        next if blacklist.include? entry
        if entry =~ /(\S*)\s*(.*)/
          attr = $1
          name = $2
          if attr.start_with? "nixos.pkgs."
            attr.sub!("nixos.pkgs.", "")
            package = Nix.instantiate(attr, name)
            nix_list[package.name] = package if package
          end
        else
          puts "failed to parse #{entry}"
        end
      end

      file = File.open("nix.cache", "w")
      nix_list.each_value do |package|
        file.puts package.serialize
      end
      file.close

      return nix_list
    end

  end


  class Debian < Package

    def self.list
      result = {}
      File.readlines('debian.cache',:encoding => "ASCII").each do |line|
        package = Debian.deserialize(line)
        result[package.name] = package
      end
      return result
    end


    def self.normalize_name(name)
      result = name    
      result = "xf86-#{$1}" if name =~ /xserver-xorg-(.*)/
      return result
    end


    def self.generate_list
      deb_list = {}

      puts "Downloading repository metadata"
      %x(curl http://ftp.debian.org/debian/dists/sid/main/source/Sources.bz2 -o debian-main.bz2)
      %x(curl http://ftp.debian.org/debian/dists/sid/contrib/source/Sources.bz2 -o debian-contrib.bz2)
      %x(curl http://ftp.debian.org/debian/dists/sid/non-free/source/Sources.bz2 -o debian-non-free.bz2)
      %x(bzcat debian-main.bz2 debian-contrib.bz2 debian-non-free.bz2 >debian-sources)

      File.read('debian-sources').split("\n\n").each do |pkgmeta|
        pkg_name = $1 if pkgmeta =~ /Package:\s*(.*)/
        pkg_version = $1 if pkgmeta =~ /Version:\s*(.*)/
        if pkg_name and pkg_version
          package = Debian.new(pkg_name, pkg_name, pkg_version, 'none')
          deb_list[Debian.normalize_name(package.name)] = package if package
        end
      end

      return deb_list
    end

  end

end