# Hecatae, the three-in-one 
# validator, that is
#--
#-- Time-stamp: </Users/noah/Documents/n_s/tools/foo_tool/validation/hecatae-gem/hecatae2/hecatae.rb last changed by Noah Sussman on noah.local/Textarcana Thursday 08 January 2009 at EST 12:57:43>
require 'rubygems'
require 'open3'
require 'mechanize'
require 'raakt'
require 'uri'
require 'net/http'
#++

#$pathHere = File.dirname(File.expand_path($0))

module Hecatae

  # Simple HTTP request agent, like Perl's LWP::Request.
  class Request
    # Get a url and return the response text
    def get (uri)
      url = URI.parse(uri)
      page = Net::HTTP.get(url)
      return page
    end
  end

  # Set up mechanized agent that understands a lot about the context of a Web page.
  class Agent

    # Get a url and return a WWW::Mechanize object
    # (yay for polymorphism)
    def get (url)
      agent = WWW::Mechanize.new
      page = agent.get(url)
      return page
    end
  end

  # a11y (accessibility, pronounced A-eleven-Y) agent
  # Set up the RAAKT test and pass html and headers
  # Using the basic RAAKT invocation by P. Krantz
  # See http://www.peterkrantz.com/raakt/wiki/examples/commandline
  class Accessibility < Agent
    # = Ruby Accessibility Analysis Kit (Raakt) wrapper
    # ==Run Raakt against a URL
    # Given a URL, run Raakt on the page at that location.
    def raakt (url)
      page = get(url)
      return raakt_o(page)
    end

    # ==Run Raakt on a Mechanize object
    # Given a WWW::Mechanize object,
    # Run all of Raakt's checks
    # return the output (if any) as one big string
    def raakt_o(page) #raakt
      raakttest = Raakt::Test.new(page.body, page.header.to_hash)
      result = raakttest.all
      if result.length > 0
        #    puts "Accessibility problems detected:"
        return result
      else 
        return ""
      end
    end
  end

  # XHTML and HTML validation wrappers
  # Use Tidy and onsgmls (OpenJade) to evaluate markup.
  # These are the same algorithms used by the Firefox HTML Validator Extension in serial mode.  
  # Output should be nearly identical to that from the extension.
  class WebStandards < Request
    # =Tidy wrapper
    # ==Validate a Web page with Tidy
    # Given a URL, validate the HTML page at that location
    # Return the list of problems (if any) as one big string.
    def tidy(url)
      page = get(url)
      result = tidy_s(page)
      problems = result[1]
      return problems
    end

    # ==Run Tidy on string-ified HTML
    # Given HTML in a multiline string, format it so it looks nice.
    # Also check whether the input string is a valid (X)HTML document.
    # Return a 2-item array of the prettied HTML and the validation problems (if any).
    #   [tidy_htmlString, errMessageString]
    #--
    # Note that this is the pattern for when you want to pipe a string into a shell command, then pipe the output from that back into your program.
    #++
    def tidy_s (htmlString)
      #This hardcoded path is relative from the ECL build directory to the tidy config, within my SVN repo
      tidyResult, tidyErr = Open3.popen3("tidy -q -config #{$pathHere}/tidy-config.txt") { |stdin, stdout, stderr| 
        #    tidyResult, tidyErr = Open3.popen3('tidy -q -access 1') { |stdin, stdout, stderr| 
        stdin.puts htmlString
        stdin.close_write	#without this the script will hang
        [stdout.read, stderr.read]
      }
    end

    # =OpenJade wrapper for XHTML
    # ==Validate an XHTML Web page with onsgmls (OpenJade)
    def xhtmlp(url)
      page = get(url)
      return xhtmlp_s(page)
    end

    # ==Run OpenJade on string-ified XHTML
    # Returns stderr as a string
    # This hardcoded path only works on Arithromancy!
    # The jade config needs to be moved into the repo
    # For HTML instead of XHTML use 
    #     /sgml-lib/ISO-HTML/15445.dcl
    # Note the dash at the end of the Jade command.  Without it Jade won't process string arguments.
    # When using my preferred doctype, OpenJade requests the XHTML DTD from the W3 every time it is called.  This has resulted in my IP being banned from w3.org.  For now the workaround is to change the DTD /in the HTML/ to refer to a locally cached DTD (it is included with the validator distro needed to run openjade).



    def xhtmlp_s (htmlString)
      jadeResult, jadeErr = Open3.popen3("onsgmls -E0 -s #{$pathHere}/w3/validator-0.8.2/htdocs/sgml-lib/xml.dcl -") { |stdin, stdout, stderr| 
        stdin.puts htmlString
        stdin.close_write	#without this the script will hang  
        stderr.read
      }
    end

    # =OpenJade Wrapper for HTML
    # ==Validate a Web page with onsgmls (OpenJade)
    def htmlp(url)
      page = get(url)
      return htmlp_s(page)
    end

    # ==Run OpenJade on string-ified HTML
    def htmlp_s (htmlString)
      jadeResult, jadeErr = Open3.popen3("onsgmls -E0 -s #{$pathHere}/w3/validator-0.8.2/htdocs/sgml-lib/ISO-HTML/15445.dcl -") { |stdin, stdout, stderr| 
        stdin.puts htmlString
        stdin.close_write
        stderr.read
      }
    end
  end


end
