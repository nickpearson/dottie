require 'spec_helper'
require 'dottie/ext'

describe Hash do
  
  describe 'Dottie extensions' do
    before :each do
      @hash = { 'a' => 'b', 'c' => { 'd' => 'e' } }
    end
    
    context 'untouched' do
      it "should not have Dottie's behavior" do
        expect(@hash['a.b']).to be_nil
      end
    end
    
    context 'wrapped' do
      let(:freckle) { @hash.dottie }
      
      it 'is no longer a Hash' do
        expect(freckle).to_not be_a Hash
      end
      it 'wraps a Hash in a Dottie::Freckle' do
        expect(freckle).to be_a Dottie::Freckle
      end
      it 'acts like a regular Hash for standard keys' do
        expect(freckle['a']).to eq 'b'
      end
      it "has Dottie's behavior" do
        expect(freckle['c.d']).to eq 'e'
      end
      it "does not add Dottie's behavior to the original Hash" do
        expect(@hash['a.b']).to be_nil
      end
    end
    
    context 'mixed in' do
      before :each do
        @hash.dottie!
      end
      
      it 'is still a Hash' do
        expect(@hash).to be_a Hash
      end
      it 'acts like a regular Hash for standard keys' do
        expect(@hash['a']).to eq 'b'
      end
      it "adds Dottie's behavior to a Hash" do
        expect(@hash['c.d']).to eq 'e'
      end
    end
    
  end
  
end
