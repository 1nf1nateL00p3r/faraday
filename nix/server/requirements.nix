# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -r ../../requirements_server.txt -r ../../requirements_dev.txt -E libffi -E openssl -E postgresql -E pkgconfig -E zlib -E libjpeg -E openjpeg -E libtiff -E freetype -E lcms2 -E libwebp -E tcl -V 2.7
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python27Full;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            sed -i \
              -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"  \
              -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"  \
                $out/${pkgs.python35.sitePackages}/pip/req/req_install.py
          '';
        });
      };
  };

  commonBuildInputs = with pkgs; [ libffi openssl postgresql pkgconfig zlib libjpeg openjpeg libtiff freetype lcms2 libwebp tcl ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python27Full-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter} \
              $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "
              (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -x "$prog" ] && [ -f "$prog" ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable} \
              python2
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (
          drv.drvAttrs // f drv.drvAttrs // { meta = drv.meta; }
        );
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {
    "Automat" = python.mkDerivation {
      name = "Automat-0.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/de/05/b8e453085cf8a7f27bb1226596f4ccf5cc9e758377d60284f990bbdc592c/Automat-0.6.0.tar.gz"; sha256 = "3c1fd04ecf08ac87b4dd3feae409542e9bf7827257097b2b6ed5692f69d6f6a8"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Twisted"
      self."attrs"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/glyph/Automat";
        license = licenses.mit;
        description = "Self-service finite-state machines for the programmer on the go.";
      };
    };

    "Babel" = python.mkDerivation {
      name = "Babel-2.5.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0e/d5/9b1d6a79c975d0e9a32bd337a1465518c2519b14b214682ca9892752417e/Babel-2.5.3.tar.gz"; sha256 = "8ce4cb6fdd4393edd323227cba3a077bceb2a6ce5201c902c65e730046f41f14"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://babel.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "Internationalization utilities";
      };
    };

    "Faker" = python.mkDerivation {
      name = "Faker-0.8.13";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/4a/28395bebd1d42834e4ff3d08253a081e36f6765c0ff4c87fa8b503373e31/Faker-0.8.13.tar.gz"; sha256 = "48fed4b4a191e2b42ad20c14115f1c6d36d338b80192075d7573f0f42d7fb321"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."ipaddress"
      self."python-dateutil"
      self."six"
      self."text-unidecode"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/joke2k/faker";
        license = licenses.mit;
        description = "Faker is a Python package that generates fake data for you.";
      };
    };

    "Flask" = python.mkDerivation {
      name = "Flask-0.12.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/eb/12/1c7bd06fcbd08ba544f25bf2c6612e305a70ea51ca0eda8007344ec3f123/Flask-0.12.2.tar.gz"; sha256 = "49f44461237b69ecd901cc7ce66feea0319b9158743dd27a2899962ab214dac1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Jinja2"
      self."Werkzeug"
      self."click"
      self."itsdangerous"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/pallets/flask/";
        license = licenses.bsdOriginal;
        description = "A microframework based on Werkzeug, Jinja2 and good intentions";
      };
    };

    "Flask-BabelEx" = python.mkDerivation {
      name = "Flask-BabelEx-0.9.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/80/ad/cc2b0becd98050eed775ca85d6e5fa784547acff69f968183098df8a52b3/Flask-BabelEx-0.9.3.tar.gz"; sha256 = "cf79cdedb5ce860166120136b0e059e9d97b8df07a3bc2411f6243de04b754b4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."Flask"
      self."Jinja2"
      self."speaklater"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mrjoes/flask-babelex";
        license = licenses.bsdOriginal;
        description = "Adds i18n/l10n support to Flask applications";
      };
    };

    "Flask-Classful" = python.mkDerivation {
      name = "Flask-Classful-0.14.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b7/2a/26d548a19ce7411f49ddb0abd3c3319f4ab47354cc4354225e5a7a91a6bf/Flask-Classful-0.14.0.tar.gz"; sha256 = "036589065f0f6e35e37c1146616cb1b82b2bf1111f68e02a8939478b32bf524d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/teracyhq/flask-classful";
        license = licenses.bsdOriginal;
        description = "Class based views for Flask";
      };
    };

    "Flask-Login" = python.mkDerivation {
      name = "Flask-Login-0.4.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c1/ff/bd9a4d2d81bf0c07d9e53e8cd3d675c56553719bbefd372df69bf1b3c1e4/Flask-Login-0.4.1.tar.gz"; sha256 = "c815c1ac7b3e35e2081685e389a665f2c74d7e077cb93cecabaea352da4752ec"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/maxcountryman/flask-login";
        license = licenses.mit;
        description = "User session management for Flask";
      };
    };

    "Flask-Mail" = python.mkDerivation {
      name = "Flask-Mail-0.9.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/05/2f/6a545452040c2556559779db87148d2a85e78a26f90326647b51dc5e81e9/Flask-Mail-0.9.1.tar.gz"; sha256 = "22e5eb9a940bf407bcf30410ecc3708f3c56cc44b29c34e1726fe85006935f41"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
      self."blinker"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/rduplain/flask-mail";
        license = licenses.bsdOriginal;
        description = "Flask extension for sending email";
      };
    };

    "Flask-Principal" = python.mkDerivation {
      name = "Flask-Principal-0.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/14/c7/2531aca6ab7baa3774fde2dfc9c9dd6d5a42576a1013a93701bfdc402fdd/Flask-Principal-0.4.0.tar.gz"; sha256 = "f5d6134b5caebfdbb86f32d56d18ee44b080876a27269560a96ea35f75c99453"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
      self."blinker"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://packages.python.org/Flask-Principal/";
        license = licenses.mit;
        description = "Identity management for flask";
      };
    };

    "Flask-SQLAlchemy" = python.mkDerivation {
      name = "Flask-SQLAlchemy-2.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d0/24/fb7c9d97f0f2ac2f484b867796f6fde1b5064ec753eaa68ce49ac8584b5e/Flask-SQLAlchemy-2.3.1.tar.gz"; sha256 = "ab879cf88d30f2961dd9b4d709dcd31a25e0306855324c7d9a74fca6ad6ef8c3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
      self."SQLAlchemy"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mitsuhiko/flask-sqlalchemy";
        license = licenses.bsdOriginal;
        description = "Adds SQLAlchemy support to your Flask application";
      };
    };

    "Flask-Security" = python.mkDerivation {
      name = "Flask-Security-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ba/c1/16e460fec7961509b10aaf8cc986fa7a1df5dced2844f42cd46732621211/Flask-Security-3.0.0.tar.gz"; sha256 = "d61daa5f5a48f89f30f50555872bdf581b2c65804668b0313345cd7beff26432"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
      self."Flask-BabelEx"
      self."Flask-Login"
      self."Flask-Mail"
      self."Flask-Principal"
      self."Flask-SQLAlchemy"
      self."Flask-WTF"
      self."SQLAlchemy"
      self."bcrypt"
      self."coverage"
      self."itsdangerous"
      self."mock"
      self."passlib"
      self."pytest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/mattupstate/flask-security";
        license = licenses.mit;
        description = "Simple security for Flask apps.";
      };
    };

    "Flask-Session" = python.mkDerivation {
      name = "Flask-Session-0.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2e/9f/b138521d0416b001469bcdc79a3619f013c0563204f7251ba978eb3e69d5/Flask-Session-0.3.1.tar.gz"; sha256 = "a31c27e0c3287f00c825b3d9625aba585f4df4cccedb1e7dd5a69a215881a731"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/fengsp/flask-session";
        license = licenses.bsdOriginal;
        description = "Adds server-side session support to your Flask application";
      };
    };

    "Flask-WTF" = python.mkDerivation {
      name = "Flask-WTF-0.14.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ba/15/00a9693180f214225a2c0b1bb9077f3b0b21f2e86522cbba22e8ad6e570c/Flask-WTF-0.14.2.tar.gz"; sha256 = "5d14d55cfd35f613d99ee7cba0fc3fbbe63ba02f544d349158c14ca15561cc36"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
      self."WTForms"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/lepture/flask-wtf";
        license = licenses.bsdOriginal;
        description = "Simple integration of Flask and WTForms.";
      };
    };

    "IPy" = python.mkDerivation {
      name = "IPy-0.83";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/88/28/79162bfc351a3f1ab44d663ab3f03fb495806fdb592170990a1568ffbf63/IPy-0.83.tar.gz"; sha256 = "61da5a532b159b387176f6eabf11946e7458b6df8fb8b91ff1d345ca7a6edab8"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/autocracy/python-ipy";
        license = licenses.bsdOriginal;
        description = "Class and tools for handling of IPv4 and IPv6 addresses and networks";
      };
    };

    "Jinja2" = python.mkDerivation {
      name = "Jinja2-2.10";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"; sha256 = "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."MarkupSafe"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://jinja.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "A small but fast and easy to use stand-alone template engine written in pure python.";
      };
    };

    "MarkupSafe" = python.mkDerivation {
      name = "MarkupSafe-1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"; sha256 = "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/pallets/markupsafe";
        license = licenses.bsdOriginal;
        description = "Implements a XML/HTML/XHTML Markup safe string for Python";
      };
    };

    "Pillow" = python.mkDerivation {
      name = "Pillow-4.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/aa/f7f983fb72710a9daa4b3374b7c160091d3f94f5c09221f9336ade9027f3/Pillow-4.2.1.tar.gz"; sha256 = "c724f65870e545316f9e82e4c6d608ab5aa9dd82d5185e5b2e72119378740073"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."olefile"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://python-pillow.org";
        license = "Standard PIL License";
        description = "Python Imaging Library (Fork)";
      };
    };

    "Pygments" = python.mkDerivation {
      name = "Pygments-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/71/2a/2e4e77803a8bd6408a2903340ac498cb0a2181811af7c9ec92cb70b0308a/Pygments-2.2.0.tar.gz"; sha256 = "dbae1046def0efb574852fab9e90209b23f556367b5a320c0bcb871c77c3e8cc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pygments.org/";
        license = licenses.bsdOriginal;
        description = "Pygments is a syntax highlighting package written in Python.";
      };
    };

    "SQLAlchemy" = python.mkDerivation {
      name = "SQLAlchemy-1.2.0b2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/59/11/f7877b47db0df1576568846f06dca8fc403bb404118c641418c3183a0eeb/SQLAlchemy-1.2.0b2.tar.gz"; sha256 = "2a01c36941b87cdc5ab32aec5b0f315f1a3dfb8d8b8efc97be0419cfd78fc590"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."psycopg2"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.sqlalchemy.org";
        license = licenses.mit;
        description = "Database Abstraction Library";
      };
    };

    "Twisted" = python.mkDerivation {
      name = "Twisted-17.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/31/bf/7f86a8f8b9778e90d8b2921e9f442a8c8aa33fd2489fc10f236bc8af1749/Twisted-17.5.0.tar.bz2"; sha256 = "f198a494f0df2482f7c5f99d7f3eef33d22763ffc76641b36fec476b878002ea"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Automat"
      self."constantly"
      self."cryptography"
      self."hyperlink"
      self."idna"
      self."incremental"
      self."pyOpenSSL"
      self."pyasn1"
      self."service-identity"
      self."zope.interface"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://twistedmatrix.com/";
        license = licenses.mit;
        description = "An asynchronous networking framework written in Python";
      };
    };

    "Unidecode" = python.mkDerivation {
      name = "Unidecode-1.0.22";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9d/36/49d0ee152b6a1631f03a541532c6201942430060aa97fe011cf01a2cce64/Unidecode-1.0.22.tar.gz"; sha256 = "8c33dd588e0c9bc22a76eaa0c715a5434851f726131bd44a6c26471746efabf5"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.gpl2Plus;
        description = "ASCII transliterations of Unicode text";
      };
    };

    "WTForms" = python.mkDerivation {
      name = "WTForms-2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bf/91/2e553b86c55e9cf2f33265de50e052441fb753af46f5f20477fe9c61280e/WTForms-2.1.zip"; sha256 = "ffdf10bd1fa565b8233380cb77a304cd36fd55c73023e91d4b803c96bc11d46f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://wtforms.simplecodes.com/";
        license = licenses.bsdOriginal;
        description = "A flexible forms validation and rendering library for python web development.";
      };
    };

    "Werkzeug" = python.mkDerivation {
      name = "Werkzeug-0.14.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9f/08/a3bb1c045ec602dc680906fc0261c267bed6b3bb4609430aff92c3888ec8/Werkzeug-0.14.1.tar.gz"; sha256 = "c3fd7a7d41976d9f44db327260e263132466836cef6f91512889ed60ad26557c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."coverage"
      self."pytest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.palletsprojects.org/p/werkzeug/";
        license = licenses.bsdOriginal;
        description = "The comprehensive WSGI web application library.";
      };
    };

    "asn1crypto" = python.mkDerivation {
      name = "asn1crypto-0.24.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz"; sha256 = "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/wbond/asn1crypto";
        license = licenses.mit;
        description = "Fast ASN.1 parser and serializer with definitions for private keys, public keys, certificates, CRL, OCSP, CMS, PKCS#3, PKCS#7, PKCS#8, PKCS#12, PKCS#5, X.509 and TSP";
      };
    };

    "attrs" = python.mkDerivation {
      name = "attrs-17.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8b/0b/a06cfcb69d0cb004fde8bc6f0fd192d96d565d1b8aa2829f0f20adb796e5/attrs-17.4.0.tar.gz"; sha256 = "1c7960ccfd6a005cd9f7ba884e6316b5e430a3f1a6c37c5f87d8b43f83b54ec9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."coverage"
      self."hypothesis"
      self."pytest"
      self."six"
      self."zope.interface"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.attrs.org/";
        license = licenses.mit;
        description = "Classes Without Boilerplate";
      };
    };

    "autobahn" = python.mkDerivation {
      name = "autobahn-17.10.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e4/2e/01a64212b1eb580d601fa20f146c962235e3493795f46e3b254597ec635d/autobahn-17.10.1.tar.gz"; sha256 = "8cf74132a18da149c5ea3dcbb5e055f6f4fe5a0238b33258d29e89bd276a8078"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Twisted"
      self."mock"
      self."pyOpenSSL"
      self."pytest"
      self."service-identity"
      self."six"
      self."txaio"
      self."zope.interface"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://crossbar.io/autobahn";
        license = licenses.mit;
        description = "WebSocket client & server library, WAMP real-time framework";
      };
    };

    "backports.csv" = python.mkDerivation {
      name = "backports.csv-1.0.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6a/0b/2071ad285e87dd26f5c02147ba13abf7ec777ff20416a60eb15ea204ca76/backports.csv-1.0.5.tar.gz"; sha256 = "8c421385cbc6042ba90c68c871c5afc13672acaf91e1508546d6cda6725ebfc6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/ryanhiebert/backports.csv";
        license = "";
        description = "Backport of Python 3 csv module";
      };
    };

    "bcrypt" = python.mkDerivation {
      name = "bcrypt-3.1.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/ec/bb6b384b5134fd881b91b6aa3a88ccddaad0103857760711a5ab8c799358/bcrypt-3.1.4.tar.gz"; sha256 = "67ed1a374c9155ec0840214ce804616de49c3df9c5bc66740687c1c9b1cd9e8d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cffi"
      self."pytest"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/bcrypt/";
        license = licenses.asl20;
        description = "Modern password hashing for your software and your servers";
      };
    };

    "beautifulsoup4" = python.mkDerivation {
      name = "beautifulsoup4-4.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fa/8d/1d14391fdaed5abada4e0f63543fef49b8331a34ca60c88bd521bcf7f782/beautifulsoup4-4.6.0.tar.gz"; sha256 = "808b6ac932dccb0a4126558f7dfdcf41710dd44a4ef497a0bb59a77f9f078e89"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.crummy.com/software/BeautifulSoup/bs4/";
        license = licenses.mit;
        description = "Screen-scraping library";
      };
    };

    "blinker" = python.mkDerivation {
      name = "blinker-1.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1b/51/e2a9f3b757eb802f61dc1f2b09c8c99f6eb01cf06416c0671253536517b6/blinker-1.4.tar.gz"; sha256 = "471aee25f3992bd325afa3772f1063dbdbbca947a041b8b89466dc00d606f8b6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/blinker/";
        license = licenses.mit;
        description = "Fast, simple object-to-object and broadcast signaling";
      };
    };

    "certifi" = python.mkDerivation {
      name = "certifi-2018.4.16";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4d/9c/46e950a6f4d6b4be571ddcae21e7bc846fcbb88f1de3eff0f6dd0a6be55d/certifi-2018.4.16.tar.gz"; sha256 = "13e698f54293db9f89122b0581843a782ad0934a4fe0172d2a980ba77fc61bb7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };

    "cffi" = python.mkDerivation {
      name = "cffi-1.11.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e7/a7/4cd50e57cc6f436f1cc3a7e8fa700ff9b8b4d471620629074913e3735fb2/cffi-1.11.5.tar.gz"; sha256 = "e90f17980e6ab0f3c2f3730e56d1fe9bcba1891eeea58966e89d352492cc74f4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pycparser"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://cffi.readthedocs.org";
        license = licenses.mit;
        description = "Foreign Function Interface for Python calling C code.";
      };
    };

    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl2;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };

    "cli-helpers" = python.mkDerivation {
      name = "cli-helpers-1.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d5/13/3783ef3fa23ab76b56d4b8f96ee90808d2c167bafc5eaa4ad3c78b75abe6/cli_helpers-1.0.2.tar.gz"; sha256 = "f77837c5fbcbea39e0cb782506515459a0da75465489bae35e46da7f51c5b9fc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Pygments"
      self."backports.csv"
      self."tabulate"
      self."terminaltables"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/dbcli/cli_helpers";
        license = licenses.bsdOriginal;
        description = "Helpers for building command-line apps";
      };
    };

    "click" = python.mkDerivation {
      name = "click-6.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/95/d9/c3336b6b5711c3ab9d1d3a80f1a3e2afeb9d8c02a7166462f6cc96570897/click-6.7.tar.gz"; sha256 = "f15516df478d5a56180fbf80e68f206010e6d160fc39fa508b65e035fd75130b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mitsuhiko/click";
        license = licenses.bsdOriginal;
        description = "A simple wrapper around optparse for powerful command line utilities.";
      };
    };

    "colorama" = python.mkDerivation {
      name = "colorama-0.3.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e6/76/257b53926889e2835355d74fec73d82662100135293e17d382e2b74d1669/colorama-0.3.9.tar.gz"; sha256 = "48eb22f4f8461b1df5734a074b57042430fb06e1d61bd1e11b078c0fe6d7a1f1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/tartley/colorama";
        license = licenses.bsdOriginal;
        description = "Cross-platform colored terminal text.";
      };
    };

    "configobj" = python.mkDerivation {
      name = "configobj-5.0.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/64/61/079eb60459c44929e684fa7d9e2fdca403f67d64dd9dbac27296be2e0fab/configobj-5.0.6.tar.gz"; sha256 = "a2f5650770e1c87fb335af19a9b7eb73fc05ccf22144eb68db7d00cd2bcb0902"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/DiffSK/configobj";
        license = licenses.bsdOriginal;
        description = "Config file reading, writing and validation.";
      };
    };

    "constantly" = python.mkDerivation {
      name = "constantly-15.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/95/f1/207a0a478c4bb34b1b49d5915e2db574cadc415c9ac3a7ef17e29b2e8951/constantly-15.1.0.tar.gz"; sha256 = "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/twisted/constantly";
        license = licenses.mit;
        description = "Symbolic constants in Python";
      };
    };

    "cookies" = python.mkDerivation {
      name = "cookies-2.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/95/b66a0ca09c5ec9509d8729e0510e4b078d2451c5e33f47bd6fc33c01517c/cookies-2.2.1.tar.gz"; sha256 = "d6b698788cae4cfa4e62ef8643a9ca332b79bd96cb314294b864ae8d7eb3ee8e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/sashahart/cookies";
        license = licenses.mit;
        description = "Friendlier RFC 6265-compliant cookie parser/renderer";
      };
    };

    "couchdbkit" = python.mkDerivation {
      name = "couchdbkit-0.6.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a1/13/9e9ff695a385c44f62b4766341b97f2bd8b596962df2a0beabf358468b70/couchdbkit-0.6.5.tar.gz"; sha256 = "9b607f509727e6ada2dbd576a4120c214b1c54f3bb8bf6e2e0eb2cfbb11a0e00"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."restkit"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://couchdbkit.org";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python couchdb kit";
      };
    };

    "coverage" = python.mkDerivation {
      name = "coverage-4.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/35/fe/e7df7289d717426093c68d156e0fd9117c8f4872b6588e8a8928a0f68424/coverage-4.5.1.tar.gz"; sha256 = "56e448f051a201c5ebbaa86a5efd0ca90d327204d8b059ab25ad0f35fbfd79f1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/ned/coveragepy";
        license = licenses.asl20;
        description = "Code coverage measurement for Python";
      };
    };

    "cryptography" = python.mkDerivation {
      name = "cryptography-2.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ec/b2/faa78c1ab928d2b2c634c8b41ff1181f0abdd9adf9193211bd606ffa57e2/cryptography-2.2.2.tar.gz"; sha256 = "9fc295bf69130a342e7a19a39d7bbeb15c0bcaabc7382ec33ef3b2b7d18d2f63"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."asn1crypto"
      self."cffi"
      self."enum34"
      self."hypothesis"
      self."idna"
      self."ipaddress"
      self."pytest"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/cryptography";
        license = licenses.bsdOriginal;
        description = "cryptography is a package which provides cryptographic recipes and primitives to Python developers.";
      };
    };

    "deprecation" = python.mkDerivation {
      name = "deprecation-1.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8c/e3/e5c66eba8fa2fd567065fa70ada98b990f449f74fb812b408fa7aafe82c9/deprecation-1.0.1.tar.gz"; sha256 = "b9bff5cc91f601ef2a8a0200bc6cde3f18a48c2ed3d1ecbfc16076b14b3ad935"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://deprecation.readthedocs.io/";
        license = licenses.asl20;
        description = "A library to handle automated deprecations";
      };
    };

    "enum34" = python.mkDerivation {
      name = "enum34-1.1.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bf/3e/31d502c25302814a7c2f1d3959d2a3b3f78e509002ba91aea64993936876/enum34-1.1.6.tar.gz"; sha256 = "8ad8c4783bf61ded74527bffb48ed9b54166685e4230386a9ed9b1279e2df5b1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/stoneleaf/enum34";
        license = licenses.bsdOriginal;
        description = "Python 3.4 Enum backported to 3.3, 3.2, 3.1, 2.7, 2.6, 2.5, and 2.4";
      };
    };

    "factory-boy" = python.mkDerivation {
      name = "factory-boy-2.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ea/b6/d94a2df8981af1698f7bc14820033cf288263212fc97980dea1a1a5a7eed/factory_boy-2.10.0.tar.gz"; sha256 = "bd5a096d0f102d79b6c78cef1c8c0b650f2e1a3ecba351c735c6d2df8dabd29c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Faker"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/FactoryBoy/factory_boy";
        license = licenses.mit;
        description = "A versatile test fixtures replacement based on thoughtbot's factory_bot for Ruby.";
      };
    };

    "filedepot" = python.mkDerivation {
      name = "filedepot-0.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/75/89/c744b5326d956dd1e8b2e591cb50759965d16ccfd49e7d3124a85a821069/filedepot-0.5.0.tar.gz"; sha256 = "e319a2b163c37fa1f3da21ad7c81a49a12de66da87d1af428fb143f092b96e5d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Pillow"
      self."SQLAlchemy"
      self."Unidecode"
      self."coverage"
      self."mock"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/amol-/depot";
        license = licenses.mit;
        description = "Toolkit for storing files and attachments in web applications";
      };
    };

    "filteralchemy" = python.mkDerivation {
      name = "filteralchemy-0.1.0";
      src = pkgs.fetchgit { url = "https://github.com/sh4r3m4n/filteralchemy"; sha256 = "0zq1hnnsbvm004r4gq44c2ld2axzh0k4692vzxf74ip5g9fq4kka"; rev = "9ecc951c74786a8174a1d1c278a2c932945e1906"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."marshmallow-sqlalchemy"
      self."six"
      self."webargs"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jmcarp/filteralchemy";
        license = "Copyright 2015 Joshua Carp";
        description = "Declarative query builder for SQLAlchemy";
      };
    };

    "funcsigs" = python.mkDerivation {
      name = "funcsigs-1.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/94/4a/db842e7a0545de1cdb0439bb80e6e42dfe82aaeaadd4072f2263a4fbed23/funcsigs-1.0.2.tar.gz"; sha256 = "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://funcsigs.readthedocs.org";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python function signatures from PEP362 for Python 2.6, 2.7 and 3.2+";
      };
    };

    "http-parser" = python.mkDerivation {
      name = "http-parser-0.8.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/07/c4/22e3c76c2313c26dd5f84f1205b916ff38ea951aab0c4544b6e2f5920d64/http-parser-0.8.3.tar.gz"; sha256 = "e2aff90a60def3e476bd71694d8757c0f95ebf2fedf0a8ae34ee306e0b20db83"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/benoitc/http-parser";
        license = licenses.mit;
        description = "http request/response parser";
      };
    };

    "humanize" = python.mkDerivation {
      name = "humanize-0.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8c/e0/e512e4ac6d091fc990bbe13f9e0378f34cf6eecd1c6c268c9e598dcf5bb9/humanize-0.5.1.tar.gz"; sha256 = "a43f57115831ac7c70de098e6ac46ac13be00d69abbf60bdcac251344785bb19"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/jmoiron/humanize";
        license = licenses.mit;
        description = "python humanize utilities";
      };
    };

    "hyperlink" = python.mkDerivation {
      name = "hyperlink-18.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/41/e1/0abd4b480ec04892b1db714560f8c855d43df81895c98506442babf3652f/hyperlink-18.0.0.tar.gz"; sha256 = "f01b4ff744f14bc5d0a22a6b9f1525ab7d6312cb0ff967f59414bbac52f0a306"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python-hyper/hyperlink";
        license = licenses.mit;
        description = "A featureful, immutable, and correct URL for Python.";
      };
    };

    "hypothesis" = python.mkDerivation {
      name = "hypothesis-3.48.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c7/0b/64a7db8a09397ab3be1c2bf77ca74b6f494758010049003c63573a0e6ca0/hypothesis-3.48.0.tar.gz"; sha256 = "b3c1e6fb2f2e88b3957687e5e05c2385c4c509173539d72cfb4c808a5dff3dcd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Faker"
      self."attrs"
      self."coverage"
      self."enum34"
      self."pytest"
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/HypothesisWorks/hypothesis-python";
        license = licenses.mpl20;
        description = "A library for property based testing";
      };
    };

    "idna" = python.mkDerivation {
      name = "idna-2.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f4/bd/0467d62790828c23c47fc1dfa1b1f052b24efdf5290f071c7a91d0d82fd3/idna-2.6.tar.gz"; sha256 = "2c6a5de3089009e3da7c5dde64a141dbc8551d5b7f6cf4ed7c2568d0cc520a8f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };

    "incremental" = python.mkDerivation {
      name = "incremental-17.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8f/26/02c4016aa95f45479eea37c90c34f8fab6775732ae62587a874b619ca097/incremental-17.5.0.tar.gz"; sha256 = "7b751696aaf36eebfab537e458929e194460051ccad279c72b755a167eebd4b3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Twisted"
      self."click"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/twisted/incremental";
        license = licenses.mit;
        description = "UNKNOWN";
      };
    };

    "inflection" = python.mkDerivation {
      name = "inflection-0.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d5/35/a6eb45b4e2356fe688b21570864d4aa0d0a880ce387defe9c589112077f8/inflection-0.3.1.tar.gz"; sha256 = "18ea7fb7a7d152853386523def08736aa8c32636b047ade55f7578c4edeb16ca"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/jpvanhal/inflection";
        license = licenses.mit;
        description = "A port of Ruby on Rails inflector to Python";
      };
    };

    "ipaddress" = python.mkDerivation {
      name = "ipaddress-1.0.22";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/8d/77b8cedcfbf93676148518036c6b1ce7f8e14bf07e95d7fd4ddcb8cc052f/ipaddress-1.0.22.tar.gz"; sha256 = "b146c751ea45cad6188dd6cf2d9b757f6f4f8d6ffb96a023e6f2e26eea02a72c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/phihag/ipaddress";
        license = licenses.psfl;
        description = "IPv4/IPv6 manipulation library";
      };
    };

    "itsdangerous" = python.mkDerivation {
      name = "itsdangerous-0.24";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dc/b4/a60bcdba945c00f6d608d8975131ab3f25b22f2bcfe1dab221165194b2d4/itsdangerous-0.24.tar.gz"; sha256 = "cbb3fcf8d3e33df861709ecaf89d9e6629cff0a217bc2848f1b41cd30d360519"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mitsuhiko/itsdangerous";
        license = licenses.bsdOriginal;
        description = "Various helpers to pass trusted data to untrusted environments and back.";
      };
    };

    "marshmallow" = python.mkDerivation {
      name = "marshmallow-2.15.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dc/34/b99d68c78378783c96254cebdf82b6ffa887a1f0e955ec5362eff2f1b2c2/marshmallow-2.15.0.tar.gz"; sha256 = "d3f31fe7be2106b1d783cbd0765ef4e1c6615505514695f33082805f929dd584"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."python-dateutil"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/marshmallow-code/marshmallow";
        license = licenses.mit;
        description = "A lightweight library for converting complex datatypes to and from native Python datatypes.";
      };
    };

    "marshmallow-sqlalchemy" = python.mkDerivation {
      name = "marshmallow-sqlalchemy-0.13.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/22/e4/47fbf458292cab8a17641b69cec3d77b127bd2400139164838a0b67133e7/marshmallow-sqlalchemy-0.13.2.tar.gz"; sha256 = "9804ef2829f781f469a06528d107c2a763f109c687266ab8b1f000f9684184ae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."SQLAlchemy"
      self."marshmallow"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/marshmallow-code/marshmallow-sqlalchemy";
        license = licenses.mit;
        description = "SQLAlchemy integration with the marshmallow (de)serialization library";
      };
    };

    "mock" = python.mkDerivation {
      name = "mock-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0c/53/014354fc93c591ccc4abff12c473ad565a2eb24dcd82490fae33dbf2539f/mock-2.0.0.tar.gz"; sha256 = "b158b6df76edd239b8208d481dc46b6afd45a846b7812ff0ce58971cf5bc8bba"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Jinja2"
      self."Pygments"
      self."funcsigs"
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/testing-cabal/mock";
        license = licenses.bsdOriginal;
        description = "Rolling backport of unittest.mock for all Pythons";
      };
    };

    "more-itertools" = python.mkDerivation {
      name = "more-itertools-4.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/db/0b/f5660bf6299ec5b9f17bd36096fa8148a1c843fa77ddfddf9bebac9301f7/more-itertools-4.1.0.tar.gz"; sha256 = "c9ce7eccdcb901a2c75d326ea134e0886abfbea5f93e91cc95de9507c0816c44"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/erikrose/more-itertools";
        license = licenses.mit;
        description = "More routines for operating on iterables, beyond itertools";
      };
    };

    "nplusone" = python.mkDerivation {
      name = "nplusone-0.8.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b0/9a/8f8bf4dfed57ee26d16c4ddcf38ff4ffee38048e15f4e1a6686e1fbeeadb/nplusone-0.8.1.tar.gz"; sha256 = "6edfa3bea1a99bb22e3b218bcafdefeddb55ebc3b362dc8921844b3b5000e29d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."blinker"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jmcarp/nplusone";
        license = "Copyright 2016 Joshua Carp";
        description = "Detecting the n+1 queries problem in Python";
      };
    };

    "olefile" = python.mkDerivation {
      name = "olefile-0.45.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d3/8a/e0f0e56d6a542dd987f9290ef7b5164636ee597ce8c2932c19c78292d5ec/olefile-0.45.1.zip"; sha256 = "2b6575f5290de8ab1086f8c5490591f7e0885af682c7c1793bdaf6e64078d385"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.decalage.info/python/olefileio";
        license = licenses.bsdOriginal;
        description = "Python package to parse, read and write Microsoft OLE2 files (Structured Storage or Compound Document, Microsoft Office) - Improved version of the OleFileIO module from PIL, the Python Image Library.";
      };
    };

    "passlib" = python.mkDerivation {
      name = "passlib-1.7.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/25/4b/6fbfc66aabb3017cd8c3bd97b37f769d7503ead2899bf76e570eb91270de/passlib-1.7.1.tar.gz"; sha256 = "3d948f64138c25633613f303bcc471126eae67c04d5e3f6b7b8ce6242f8653e0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."bcrypt"
      self."cryptography"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/ecollins/passlib";
        license = licenses.bsdOriginal;
        description = "comprehensive password hashing framework supporting over 30 schemes";
      };
    };

    "pbr" = python.mkDerivation {
      name = "pbr-4.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c6/46/f414e7d9ba9621c8acd3e7a82e08c47e0de34ad3e213c16e458b6c04d432/pbr-4.0.2.tar.gz"; sha256 = "dae4aaa78eafcad10ce2581fc34d694faa616727837fd8e55c1a00951ad6744f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/pbr/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python Build Reasonableness";
      };
    };

    "pgcli" = python.mkDerivation {
      name = "pgcli-1.8.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/91/84/e3be2851c87a9550cc747ba85ade36d1b51bb9a747ac93025a01a25baa41/pgcli-1.8.2.tar.gz"; sha256 = "79b32cb0a44e03fc6c26d43080459d48d39d6d81391eb09062a82c940b61441c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Pygments"
      self."cli-helpers"
      self."click"
      self."configobj"
      self."humanize"
      self."pgspecial"
      self."prompt-toolkit"
      self."psycopg2"
      self."setproctitle"
      self."sqlparse"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pgcli.com";
        license = licenses.bsdOriginal;
        description = "CLI for Postgres Database. With auto-completion and syntax highlighting.";
      };
    };

    "pgspecial" = python.mkDerivation {
      name = "pgspecial-1.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d5/d8/cd12f64c42b9878e3e677ba2c43f7abdc87eadba5f18b640f8efda555b55/pgspecial-1.10.0.tar.gz"; sha256 = "eadb0108cdbcf8b38a69bcc9e403b352dbd6d30622e417f48e659180150ee1b6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."click"
      self."sqlparse"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.dbcli.com";
        license = licenses.bsdOriginal;
        description = "Meta-commands handler for Postgres Database.";
      };
    };

    "pluggy" = python.mkDerivation {
      name = "pluggy-0.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/11/bf/cbeb8cdfaffa9f2ea154a30ae31a9d04a1209312e2919138b4171a1f8199/pluggy-0.6.0.tar.gz"; sha256 = "7f8ae7f5bdf75671a718d2daf0a64b7885f74510bcd98b1a0bb420eb9a9d0cff"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pytest-dev/pluggy";
        license = licenses.mit;
        description = "plugin and hook calling mechanisms for python";
      };
    };

    "prompt-toolkit" = python.mkDerivation {
      name = "prompt-toolkit-1.0.15";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8a/ad/cf6b128866e78ad6d7f1dc5b7f99885fb813393d9860778b2984582e81b5/prompt_toolkit-1.0.15.tar.gz"; sha256 = "858588f1983ca497f1cf4ffde01d978a3ea02b01c8a26a8bbc5cd2e66d816917"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
      self."wcwidth"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jonathanslenders/python-prompt-toolkit";
        license = licenses.bsdOriginal;
        description = "Library for building powerful interactive command lines in Python";
      };
    };

    "psycopg2" = python.mkDerivation {
      name = "psycopg2-2.7.3.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dd/47/000b405d73ca22980684fd7bd3318690cc03cfa3b2ae1c5b7fff8050b28a/psycopg2-2.7.3.2.tar.gz"; sha256 = "5c3213be557d0468f9df8fe2487eaf2990d9799202c5ff5cb8d394d09fad9b2a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://initd.org/psycopg/";
        license = licenses.lgpl2;
        description = "psycopg2 - Python-PostgreSQL Database Adapter";
      };
    };

    "py" = python.mkDerivation {
      name = "py-1.5.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f7/84/b4c6e84672c4ceb94f727f3da8344037b62cee960d80e999b1cd9b832d83/py-1.5.3.tar.gz"; sha256 = "29c9fab495d7528e80ba1e343b958684f4ace687327e6f789a94bf3d1915f881"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://py.readthedocs.io/";
        license = licenses.mit;
        description = "library with cross-python path, ini-parsing, io, code, log facilities";
      };
    };

    "pyOpenSSL" = python.mkDerivation {
      name = "pyOpenSSL-17.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b0/9e/7088f6165c40c46416aff434eb806c1d64ad6ec6dbc201f5ad4d0484704e/pyOpenSSL-17.2.0.tar.gz"; sha256 = "5d617ce36b07c51f330aa63b83bf7f25c40a0e95958876d54d1982f8c91b4834"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cryptography"
      self."pytest"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pyopenssl.org/";
        license = licenses.asl20;
        description = "Python wrapper module around the OpenSSL library";
      };
    };

    "pyasn1" = python.mkDerivation {
      name = "pyasn1-0.4.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/eb/3d/b7d0fdf4a882e26674c68c20f40682491377c4db1439870f5b6f862f76ed/pyasn1-0.4.2.tar.gz"; sha256 = "d258b0a71994f7770599835249cece1caef3c70def868c4915e6e5ca49b67d15"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/etingof/pyasn1";
        license = licenses.bsdOriginal;
        description = "ASN.1 types and codecs";
      };
    };

    "pyasn1-modules" = python.mkDerivation {
      name = "pyasn1-modules-0.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ab/76/36ab0e099e6bd27ed95b70c2c86c326d3affa59b9b535c63a2f892ac9f45/pyasn1-modules-0.2.1.tar.gz"; sha256 = "af00ea8f2022b6287dc375b2c70f31ab5af83989fc6fe9eacd4976ce26cd7ccc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyasn1"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/etingof/pyasn1-modules";
        license = licenses.bsdOriginal;
        description = "A collection of ASN.1-based protocols modules.";
      };
    };

    "pycparser" = python.mkDerivation {
      name = "pycparser-2.18";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8c/2d/aad7f16146f4197a11f8e91fb81df177adcc2073d36a17b1491fd09df6ed/pycparser-2.18.tar.gz"; sha256 = "99a8ca03e29851d96616ad0404b4aad7d9ee16f25c9f9708a11faf2810f7b226"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/eliben/pycparser";
        license = licenses.bsdOriginal;
        description = "C parser in Python";
      };
    };

    "pydot" = python.mkDerivation {
      name = "pydot-1.2.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c3/f1/e61d6dfe6c1768ed2529761a68f70939e2569da043e9f15a8d84bf56cadf/pydot-1.2.4.tar.gz"; sha256 = "92d2e2d15531d00710f2d6fb5540d2acabc5399d464f2f20d5d21073af241eb6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyparsing"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/erocarrera/pydot";
        license = licenses.mit;
        description = "Python interface to Graphviz's Dot";
      };
    };

    "pyparsing" = python.mkDerivation {
      name = "pyparsing-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3c/ec/a94f8cf7274ea60b5413df054f82a8980523efd712ec55a59e7c3357cf7c/pyparsing-2.2.0.tar.gz"; sha256 = "0832bcf47acd283788593e7a0f542407bd9550a55a8a8435214a1960e04bcb04"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyparsing.wikispaces.com/";
        license = licenses.mit;
        description = "Python parsing module";
      };
    };

    "pytest" = python.mkDerivation {
      name = "pytest-3.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2d/56/6019153cdd743300c5688ab3b07702355283e53c83fbf922242c053ffb7b/pytest-3.5.0.tar.gz"; sha256 = "fae491d1874f199537fd5872b5e1f0e74a009b979df9d53d1553fd03da1703e1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."attrs"
      self."colorama"
      self."funcsigs"
      self."more-itertools"
      self."pluggy"
      self."py"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pytest.org";
        license = licenses.mit;
        description = "pytest: simple powerful testing with Python";
      };
    };

    "pytest-factoryboy" = python.mkDerivation {
      name = "pytest-factoryboy-2.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/80/15/294f84a4d3159f6be5524b8f02b70aae82c86e2341c27ac00fdd26b0d44f/pytest-factoryboy-2.0.1.tar.gz"; sha256 = "ad438d191d2b2a0f26956d437c1963875db573147a84ffd85d7bbeaefae22458"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."factory-boy"
      self."inflection"
      self."pytest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pytest-dev/pytest-factoryboy";
        license = licenses.mit;
        description = "Factory Boy support for pytest.";
      };
    };

    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/51/fc/39a3fbde6864942e8bb24c93663734b74e281b984d1b8c4f95d64b0c21f6/python-dateutil-2.6.0.tar.gz"; sha256 = "62a2f8df3d66f878373fd0072eacf4ee52194ba302e00082828e0d263b0418d2"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.io";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };

    "python-slugify" = python.mkDerivation {
      name = "python-slugify-1.2.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9f/b0/2723356c20fb01b0e09f6ee03c0c629f4e30811e7d92ebd15453d648e5f0/python-slugify-1.2.4.tar.gz"; sha256 = "57a385df7a1c6dbd15f7666eaff0ff29d3f60363b228b1197c5308ed3ba5f824"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Unidecode"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/un33k/python-slugify";
        license = licenses.mit;
        description = "A Python Slugify application that handles Unicode";
      };
    };

    "pytz" = python.mkDerivation {
      name = "pytz-2018.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/76/52efda4ef98e7544321fd8d5d512e11739c1df18b0649551aeccfb1c8376/pytz-2018.4.tar.gz"; sha256 = "c06425302f2cf668f1bba7a0a03f3c1d34d4ebeef2c72003da308b3947c7f749"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };

    "requests" = python.mkDerivation {
      name = "requests-2.18.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b0/e1/eab4fc3752e3d240468a8c0b284607899d2fbfb236a56b7377a329aa8d09/requests-2.18.4.tar.gz"; sha256 = "9c443e7324ba5b85070c4a818ade28bfabedf16ea10206da1132edaa6dda237e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."cryptography"
      self."idna"
      self."pyOpenSSL"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };

    "responses" = python.mkDerivation {
      name = "responses-0.9.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/67/cb/0a5390f7b8944cfa7e4079a839adba964d858d27a60af7b2683248148339/responses-0.9.0.tar.gz"; sha256 = "c6082710f4abfb60793899ca5f21e7ceb25aabf321560cc0726f8b59006811c9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cookies"
      self."coverage"
      self."mock"
      self."pytest"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/getsentry/responses";
        license = licenses.asl20;
        description = "A utility library for mocking out the `requests` Python library.";
      };
    };

    "restkit" = python.mkDerivation {
      name = "restkit-4.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/76/b9/d90120add1be718f853c53008cf5b62d74abad1d32bd1e7097dd913ae053/restkit-4.2.2.tar.gz"; sha256 = "c0bda8eb7c643b5e818b612dab49121393abc8589c6cbe9b84085079d598599d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."http-parser"
      self."socketpool"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://benoitc.github.com/restkit";
        license = licenses.mit;
        description = "Python REST kit";
      };
    };

    "service-identity" = python.mkDerivation {
      name = "service-identity-17.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/de/2a/cab6e30be82c8fcd2339ef618036720eda954cf05daef514e386661c9221/service_identity-17.0.0.tar.gz"; sha256 = "4001fbb3da19e0df22c47a06d29681a398473af4aa9d745eca525b3b2c2302ab"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."attrs"
      self."idna"
      self."pyOpenSSL"
      self."pyasn1"
      self."pyasn1-modules"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://service-identity.readthedocs.io/";
        license = licenses.mit;
        description = "Service identity verification for pyOpenSSL.";
      };
    };

    "setproctitle" = python.mkDerivation {
      name = "setproctitle-1.1.10";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5a/0d/dc0d2234aacba6cf1a729964383e3452c52096dc695581248b548786f2b3/setproctitle-1.1.10.tar.gz"; sha256 = "6283b7a58477dd8478fbb9e76defb37968ee4ba47b05ec1c053cb39638bd7398"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/dvarrazzo/py-setproctitle";
        license = licenses.bsdOriginal;
        description = "A Python module to customize the process title";
      };
    };

    "six" = python.mkDerivation {
      name = "six-1.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"; sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/six/";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };

    "socketpool" = python.mkDerivation {
      name = "socketpool-0.5.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d1/39/fae99a735227234ffec389b252c6de2bc7816bf627f56b4c558dc46c85aa/socketpool-0.5.3.tar.gz"; sha256 = "a06733434a56c4b60b8fcaa168102d2386253d36425804d55532a6bbbda6e2ec"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/benoitc/socketpool";
        license = licenses.mit;
        description = "Python socket pool";
      };
    };

    "speaklater" = python.mkDerivation {
      name = "speaklater-1.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/11/92/5ae1effe0ccb8561c034a0111d53c8788660ddb7ed4992f0da1bb5c525e5/speaklater-1.3.tar.gz"; sha256 = "59fea336d0eed38c1f0bf3181ee1222d0ef45f3a9dd34ebe65e6bfffdd6a65a9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mitsuhiko/speaklater";
        license = licenses.bsdOriginal;
        description = "implements a lazy string for python useful for use with gettext";
      };
    };

    "sqlalchemy-schemadisplay" = python.mkDerivation {
      name = "sqlalchemy-schemadisplay-1.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ac/6a/de5911b2837278f3cf89b99b0fd94461f789b8f083537ff14ff9aa6d3397/sqlalchemy_schemadisplay-1.3.tar.gz"; sha256 = "0a9f26d77be9d92c9564d87cc17668fe141a816036c5f5d7c8cb053b253957e0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pydot"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/fschulze/sqlalchemy_schemadisplay";
        license = licenses.mit;
        description = "Turn SQLAlchemy DB Model into a graph";
      };
    };

    "sqlparse" = python.mkDerivation {
      name = "sqlparse-0.2.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/79/3c/2ad76ba49f9e3d88d2b58e135b7821d93741856d1fe49970171f73529303/sqlparse-0.2.4.tar.gz"; sha256 = "ce028444cfab83be538752a2ffdb56bc417b7784ff35bb9a3062413717807dec"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/andialbrecht/sqlparse";
        license = licenses.bsdOriginal;
        description = "Non-validating SQL parser";
      };
    };

    "tabulate" = python.mkDerivation {
      name = "tabulate-0.8.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/12/c2/11d6845db5edf1295bc08b2f488cf5937806586afe42936c3f34c097ebdc/tabulate-0.8.2.tar.gz"; sha256 = "e4ca13f26d0a6be2a2915428dc21e732f1e44dad7f76d7030b2ef1ec251cf7f2"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."wcwidth"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/astanin/python-tabulate";
        license = licenses.mit;
        description = "Pretty-print tabular data";
      };
    };

    "terminaltables" = python.mkDerivation {
      name = "terminaltables-3.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9b/c4/4a21174f32f8a7e1104798c445dacdc1d4df86f2f26722767034e4de4bff/terminaltables-3.1.0.tar.gz"; sha256 = "f3eb0eb92e3833972ac36796293ca0906e998dc3be91fbe1f8615b331b853b81"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Robpol86/terminaltables";
        license = licenses.mit;
        description = "Generate simple tables in terminals from a nested list of strings.";
      };
    };

    "text-unidecode" = python.mkDerivation {
      name = "text-unidecode-1.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f0/a2/40adaae7cbdd007fb12777e550b5ce344b56189921b9f70f37084c021ca4/text-unidecode-1.2.tar.gz"; sha256 = "5a1375bb2ba7968740508ae38d92e1f889a0832913cb1c447d5e2046061a396d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kmike/text-unidecode/";
        license = licenses.artistic2;
        description = "The most basic Text::Unidecode port";
      };
    };

    "tqdm" = python.mkDerivation {
      name = "tqdm-4.15.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/01/f7/2058bd94a903f445e8ff19c0af64b9456187acab41090ff2da21c7c7e193/tqdm-4.15.0.tar.gz"; sha256 = "6ec1dc74efacf2cda936b4a6cf4082ce224c76763bdec9f17e437c8cfcaa9953"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/tqdm/tqdm";
        license = licenses.mpl20;
        description = "Fast, Extensible Progress Meter";
      };
    };

    "txaio" = python.mkDerivation {
      name = "txaio-2.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b8/87/efcae4040c2a0af9c871116a6dbf02ee582b396e6de3797fb30cdcc4a7e4/txaio-2.10.0.tar.gz"; sha256 = "4797f9f6a9866fe887c96abc0110a226dd5744c894dc3630870542597ad30853"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Twisted"
      self."mock"
      self."pytest"
      self."six"
      self."zope.interface"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/crossbario/txaio";
        license = licenses.mit;
        description = "Compatibility API between asyncio/Twisted/Trollius";
      };
    };

    "urllib3" = python.mkDerivation {
      name = "urllib3-1.22";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ee/11/7c59620aceedcc1ef65e156cc5ce5a24ef87be4107c2b74458464e437a5d/urllib3-1.22.tar.gz"; sha256 = "cc44da8e1145637334317feebd728bd869a35285b93cbb4cca2577da7e62db4f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."cryptography"
      self."idna"
      self."ipaddress"
      self."pyOpenSSL"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };

    "wcwidth" = python.mkDerivation {
      name = "wcwidth-0.1.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/11/e4a2bb08bb450fdbd42cc709dd40de4ed2c472cf0ccb9e64af22279c5495/wcwidth-0.1.7.tar.gz"; sha256 = "3df37372226d6e63e1b1e1eda15c594bca98a22d33a23832a90998faa96bc65e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jquast/wcwidth";
        license = licenses.mit;
        description = "Measures number of Terminal column cells of wide-character codes";
      };
    };

    "webargs" = python.mkDerivation {
      name = "webargs-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9c/9b/a6dce2167bf86d65f1055d9f4f62b523c5891a7beeb15c8fe63f8948a37f/webargs-2.1.0.tar.gz"; sha256 = "d15d81531b7c0f73dec140bf0cd45c15f061f88eb08fcc29854d94682fd3911c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."marshmallow"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/sloria/webargs";
        license = licenses.mit;
        description = "A friendly library for parsing and validating HTTP request arguments, with built-in support for popular web frameworks, including Flask, Django, Bottle, Tornado, Pyramid, webapp2, Falcon, and aiohttp.";
      };
    };

    "websocket-client" = python.mkDerivation {
      name = "websocket-client-0.46.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/83/91/162f2c76729633d1dc36b09746895c7766bc183bba94cb4d2ec398676060/websocket_client-0.46.0.tar.gz"; sha256 = "933f6bbf08b381f2adbca9e93d7e7958ba212b42c73acb310b18f0fbe74f3738"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/websocket-client/websocket-client.git";
        license = licenses.lgpl2;
        description = "WebSocket client for python. hybi13 is supported.";
      };
    };

    "zope.interface" = python.mkDerivation {
      name = "zope.interface-4.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ac/8a/657532df378c2cd2a1fe6b12be3b4097521570769d4852ec02c24bd3594e/zope.interface-4.5.0.tar.gz"; sha256 = "57c38470d9f57e37afb460c399eb254e7193ac7fb8042bd09bdc001981a9c74c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."coverage"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/zopefoundation/zope.interface";
        license = licenses.zpl21;
        description = "Interfaces for Python";
      };
    };
  };
  localOverridesFile = ./requirements_override.nix;
  overrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [
    
  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [overrides] else [] ) ++ commonOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )