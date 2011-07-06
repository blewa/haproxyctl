require 'csv'

module Rhapr
  class Interface
    include Rhapr::Environment

    EMPTY = "\n"

    # @param [String, #to_s] message The message to be sent to HAProxy
    # return [Array<String>] All of the output from HAProxy, read in.
    # @see Rhapr::Interface#write, Rhapr::Interface#read_full
    def send(message)
      sock = socket

      write(sock, message)
      read_full(sock)
    end

    # @return [true, false] Whether or not the 'clear counters' command was successful
    def clear_counters
      resp = send 'clear counters'
      resp == EMPTY
    end
    alias :clear :clear_counters

    # @return [Hash{String => String}] The 'show info' attributes, from HAProxy, parsed into a Hash.
    def show_info
      resp = send 'show info'

      attrs = resp.split("\n")

      attrs.map! {|line|
        _attr, *_val = line.split(/: /)
        [ _attr, _val.join ]
      }

      Hash[ attrs ]
    end
    alias :info :show_info

    # @return [Array<Hash{String => String}>] The 'show stat' response, from HAProxy, parsed into an Array of Hashes.
    def show_stat
      resp = send 'show stat'
      resp.gsub!(/^# /, '')

      csv = CSV.parse(resp, :headers => true)
      out = csv.map(&:to_a)

      out.map!{|row| Hash[ row ]}

      return(out)
    end
    alias :stat :show_stat

    # @todo: Implement. I do not know the possible errors that may be present, nor how HAProxy will render them.
    def show_errors
    end
    alias :errors :show_errors

    # @todo: Implement. Not sure how this should look. It's likely that I will want to 'interpret' the data that is spit out.
    def show_sess(id)
    end
    alias :session :show_sess

    # @return [String] The raw response from HAProxy.
    # @todo: Allow the numeric id to be used as a parameter?
    def get_weight(backend, server)
      resp = send "get weight #{backend}/#{server}"
    end

    def set_weight(backend, server, weight)
    end

    def disable(backend, server)
    end

    def enable(backend, server)
    end

   protected
    # @param [UNIXSocket]
    # @param [String]
    # @return [nil]
    def write(socket, message)
      socket.puts message
    end

    # @return [String]
    def read(socket)
      socket.gets
    end

    # @return [Array<String>] All of the output from HAProxy, read in.
    # @see Rhapr::Interface#read
    def read_full(socket)
      output = []
      output << read(socket) until(sock.eof?)
    end
  end
end
