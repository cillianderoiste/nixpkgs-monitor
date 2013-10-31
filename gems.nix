# WARNING: automatically generated file
# Generated by 'gem nix' command that comes from 'nix' gem
g: # Get dependencies from patched gems
{
  aliases = {
    haml = g.haml_4_0_3;
    rack = g.rack_1_5_2;
    rack_protection = g.rack_protection_1_5_0;
    sequel = g.sequel_4_0_0;
    sinatra = g.sinatra_1_4_3;
    sqlite3 = g.sqlite3_1_3_7;
    tilt = g.tilt_1_4_1;
  };
  gem_nix_args = [ ''haml'' ''sequel'' ''sinatra'' ''sqlite3'' ];
  gems = {
    haml_4_0_3 = {
      basename = ''haml'';
      meta = {
        description = ''An elegant, structured (X)HTML/XML templating engine.'';
        homepage = ''http://haml.info/'';
        longDescription = ''Haml (HTML Abstraction Markup Language) is a layer on top of HTML or XML that's
designed to express the structure of documents in a non-repetitive, elegant, and
easy way by using indentation rather than closing tags and allowing Ruby to be
embedded with ease. It was originally envisioned as a plugin for Ruby on Rails,
but it can function as a stand-alone templating engine.
'';
      };
      name = ''haml-4.0.3'';
      requiredGems = [ g.tilt_1_4_1 ];
      sha256 = ''1l9zhfdk9z7xjfdp108r9fw4xa55hflin7hh3lpafbf9bdz96knr'';
    };
    rack_1_5_2 = {
      basename = ''rack'';
      meta = {
        description = ''a modular Ruby webserver interface'';
        homepage = ''http://rack.github.com/'';
        longDescription = ''Rack provides a minimal, modular and adaptable interface for developing
web applications in Ruby.  By wrapping HTTP requests and responses in
the simplest way possible, it unifies and distills the API for web
servers, web frameworks, and software in between (the so-called
middleware) into a single method call.

Also see http://rack.github.com/.
'';
      };
      name = ''rack-1.5.2'';
      requiredGems = [  ];
      sha256 = ''19szfw76cscrzjldvw30jp3461zl00w4xvw1x9lsmyp86h1g0jp6'';
    };
    rack_protection_1_5_0 = {
      basename = ''rack_protection'';
      meta = {
        description = ''You should use protection!'';
        homepage = ''http://github.com/rkh/rack-protection'';
        longDescription = ''You should use protection!'';
      };
      name = ''rack-protection-1.5.0'';
      requiredGems = [ g.rack_1_5_2 ];
      sha256 = ''10wm67f2mp9pryg0s8qapbyxd2lcrpb8ywsbicg29cv2xprhbl4j'';
    };
    sequel_4_0_0 = {
      basename = ''sequel'';
      meta = {
        description = ''The Database Toolkit for Ruby'';
        homepage = ''http://sequel.rubyforge.org'';
        longDescription = ''The Database Toolkit for Ruby'';
      };
      name = ''sequel-4.0.0'';
      requiredGems = [  ];
      sha256 = ''17kqm0vd15p9qxbgcysvmg6a046fd7zvxl3xzpsh00pg6v454svm'';
    };
    sinatra_1_4_3 = {
      basename = ''sinatra'';
      meta = {
        description = ''Classy web-development dressed in a DSL'';
        homepage = ''http://www.sinatrarb.com/'';
        longDescription = ''Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort.'';
      };
      name = ''sinatra-1.4.3'';
      requiredGems = [ g.rack_1_5_2 g.tilt_1_4_1 g.rack_protection_1_5_0 ];
      sha256 = ''1a9qp7wrsyz8p1d8fkhw9kixmlpjchd2k8nfs2hkfkp56jkdyq8m'';
    };
    sqlite3_1_3_7 = {
      basename = ''sqlite3'';
      meta = {
        description = ''This module allows Ruby programs to interface with the SQLite3 database engine (http://www.sqlite.org)'';
        homepage = ''http://github.com/luislavena/sqlite3-ruby'';
        longDescription = ''This module allows Ruby programs to interface with the SQLite3
database engine (http://www.sqlite.org).  You must have the
SQLite engine installed in order to build this module.

Note that this module is only compatible with SQLite 3.6.16 or newer.'';
      };
      name = ''sqlite3-1.3.7'';
      requiredGems = [  ];
      sha256 = ''0qlr9f4l57cbcf66gdswip9qcx8l21yhh0fsrqz9k7mad7jia4by'';
    };
    tilt_1_4_1 = {
      basename = ''tilt'';
      meta = {
        description = ''Generic interface to multiple Ruby template engines'';
        homepage = ''http://github.com/rtomayko/tilt/'';
        longDescription = ''Generic interface to multiple Ruby template engines'';
      };
      name = ''tilt-1.4.1'';
      requiredGems = [  ];
      sha256 = ''00sr3yy7sbqaq7cb2d2kpycajxqf1b1wr1yy33z4bnzmqii0b0ir'';
    };
  };
}
