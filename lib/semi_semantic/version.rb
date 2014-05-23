module SemiSemantic
  class Version
    include Comparable

    PRE_RELEASE_PREFIX = '-'
    POST_RELEASE_PREFIX = '+'

    attr_reader :release, :pre_release, :post_release

    def self.parse(version_string)
      matches = /^(?<release>[^-+]+)(\-(?<pre_release>[^-+]+))?(\+(?<post_release>[^-+]+))?$/.match(version_string)
      raise ArgumentError.new "Invalid Version Format: #{version_string}" if matches.nil?

      release = VersionCluster.parse matches[:release]
      pre_release = nil
      if matches[:pre_release]
        pre_release = VersionCluster.parse matches[:pre_release]
      end
      post_release = nil
      if matches[:post_release]
        post_release = VersionCluster.parse matches[:post_release]
      end
      self.new(release, pre_release, post_release)
    end

    def initialize(release, pre_release=nil, post_release=nil)
      raise ArgumentError.new 'Invalid Release: nil' if release.nil?
      @release = release
      @pre_release = pre_release
      @post_release = post_release
    end

    def <=>(other)
      result = (@release <=> other.release)
      return result unless result == 0

      unless @pre_release.nil? && other.pre_release.nil?
        return 1 if @pre_release.nil?
        return -1 if other.pre_release.nil?
        result = (@pre_release <=> other.pre_release)
        return result unless result == 0
      end

      unless @post_release.nil? && other.post_release.nil?
        return -1 if @post_release.nil?
        return 1 if other.post_release.nil?
        result = (@post_release <=> other.post_release)
        return result unless result == 0
      end

      0
    end

    def to_s
      str = @release.to_s
      str += PRE_RELEASE_PREFIX + @pre_release.to_s unless @pre_release.nil?
      str += POST_RELEASE_PREFIX + @post_release.to_s unless @post_release.nil?
      str
    end
  end
end
