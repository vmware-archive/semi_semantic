require 'spec_helper'
require 'semi_semantic/version'
require 'semi_semantic/version_cluster'

module SemiSemantic
  describe Version do

    describe 'release' do
      it 'returns the first VersionCluster' do
        expect(described_class.parse('1.0').release).to eq VersionCluster.parse '1.0'
        expect(described_class.parse('1.0-alpha').release).to eq VersionCluster.parse '1.0'
        expect(described_class.parse('1.0+dev').release).to eq VersionCluster.parse '1.0'
        expect(described_class.parse('1.0-alpha+dev').release).to eq VersionCluster.parse '1.0'
      end
    end

    describe 'pre_release' do
      it 'returns the VersionCluster following the "-"' do
        expect(described_class.parse('1.0').pre_release).to be_nil
        expect(described_class.parse('1.0-alpha').pre_release).to eq VersionCluster.parse 'alpha'
        expect(described_class.parse('1.0+dev').pre_release).to be_nil
        expect(described_class.parse('1.0-alpha+dev').pre_release).to eq VersionCluster.parse 'alpha'
      end
    end

    describe 'post_release' do
      it 'returns the VersionCluster following the "+"' do
        expect(described_class.parse('1.0').post_release).to be_nil
        expect(described_class.parse('1.0-alpha').post_release).to be_nil
        expect(described_class.parse('1.0+dev').post_release).to eq VersionCluster.parse 'dev'
        expect(described_class.parse('1.0-alpha+dev').post_release).to eq VersionCluster.parse 'dev'
      end
    end

    describe 'parse' do
      #TODO
    end

    describe 'to string' do
      it 'joins the version clusters with separators' do
        release = VersionCluster.parse '1.1.1.1'
        pre_release = VersionCluster.parse '2.2.2.2'
        post_release = VersionCluster.parse '3.3.3.3'

        expect(described_class.new(release).to_s).to eq '1.1.1.1'
        expect(described_class.new(release, pre_release).to_s).to eq '1.1.1.1-2.2.2.2'
        expect(described_class.new(release, nil, post_release).to_s).to eq '1.1.1.1+3.3.3.3'
        expect(described_class.new(release, pre_release, post_release).to_s).to eq '1.1.1.1-2.2.2.2+3.3.3.3'
      end
    end

    describe 'compare' do
      it 'handles equivalence' do
        expect(described_class.parse('1.0')).to eq described_class.parse('1.0')
        expect(described_class.parse('1.0')).to eq described_class.parse('1.0.0')
        expect(described_class.parse('1-1+1')).to eq described_class.parse('1-1+1')

        expect(described_class.parse('1-1+0')).to_not eq described_class.parse('1-1')
      end

      it 'treats nil pre/post-release as distinct from zeroed pre/post-release' do
        expect(described_class.parse('1-0+1')).to_not eq described_class.parse('1+1')
        expect(described_class.parse('1-1+0')).to_not eq described_class.parse('1-1')
      end

      it 'treats pre-release as less than release' do
        expect(described_class.parse('1.0-alpha')).to be < described_class.parse('1.0')
      end

      it 'treats post-release as greater than release' do
        expect(described_class.parse('1.0+dev')).to be > described_class.parse('1.0')
      end
    end

  end
end
